package ;

import adobe.cep.CSInterface;
import flatomo.DocumentStatus;
import flatomo.ExportClassKind;
import flatomo.ExtensionItem;
import flatomo.ExtensionLibrary;
import flatomo.Section;
import flatomo.SectionKind;
import haxe.Serializer;
import haxe.Template;
import haxe.Unserializer;
import js.JQuery;
import js.JQuery.JqEvent;

using Lambda;
using flatomo.JQueryTools;

class Main {
	
	public static function main() { new Main(); }
	
	private function new() {
		invoke(ScriptApi.ValidationTest, function(validDocument_raw:Serialization) {
			var status:DocumentStatus = Unserializer.run(validDocument_raw);
			switch (status) {
				case Enabled: initialize();
				case Disabled: 
					new JQuery('div#warning div').text('Disabled');
					new JQuery('div#warning input#enable_flatomo').click(function (event:JqEvent) {
						invoke(ScriptApi.Enable, null);
						initialize();
					});
				case Invalid:
					new JQuery('div#warning div').text('Invalid');
					new JQuery('div#warning input#enable_flatomo').css('display', 'none');
			}
		});
	}
	
	private function initialize():Void {
		new JQuery('div#warning').css('display', 'none');
		invoke(ScriptApi.GetExtensionLibrary, function(library_raw:Serialization) {
			createLibraryDiv(Unserializer.run(library_raw));
		});
		
		new JQuery('input#save').click(function (event:JqEvent) {
			save();
		});
	}
	
	private function save():Void {
		var sections:Array<Section> = [];
		new JQuery('#section_list').find('select.section_kind').iter(function (query:JQuery) {
			var sectionName:String = query.attr('name');
			var sectionType:Int = Std.parseInt(query.children(':selected').val());
			var gotoSectionName:String = new JQuery('select.goto_section[name=${sectionName}]').val();
			
			sections.push({
				name: sectionName,
				kind: SectionKind.createByIndex(sectionType, if (sectionType == 4) [gotoSectionName] else []),
				begin: -1,
				end: -1,
			});
		});
		
		var item:ExtensionItem = {
			name: new JQuery('div#item_name').text(),
			linkageClassName: new JQuery('input#item_linkage').val(),
			linkageExportForFlatomo: new JQuery('input#item_export_for_flatomo').is(':checked'),
			exportClassKind: ExportClassKind.createByIndex(Std.parseInt(new JQuery('select#item_export_class_kind').val())),
			sections: sections,
		}
		
		invoke(ScriptApi.SetExtensionItem(item), null);
		trace(item);
		trace(sections);
	}
	
	private function createLibraryDiv(extensionLibrary:ExtensionLibrary):Void {
		var library = new JQuery('div#library');
		
		// 'div#library div'を削除
		library.children("div").remove();
		
		// ライブラリを作成
		for (item in extensionLibrary) {
			var element = new JQuery('<div>$item</div>');
			element.click(function (event:JqEvent) {
				var itemPath:String = new JQuery(event.currentTarget).text();
				invoke(ScriptApi.GetExtensionItem(itemPath), function (extensionItem_raw:Serialization) {
					var extensionItem:ExtensionItem = Unserializer.run(extensionItem_raw);
					refreshMainDiv(extensionItem);
				});
			});
			library.append(element);
		}
	}
	
	private function refreshMainDiv(item:ExtensionItem):Void {
		var content = new JQuery('div#main');
		
		// 'div#main'のすべての子を削除
		content.children('*').remove();
		// 'div#main div#item_name'を作成
		createItemProperty(item.name, item.linkageClassName, item);
		createSectionProfile(item.sections);
		
		var exportForFlatomo = new JQuery('input#item_export_for_flatomo');
		exportForFlatomo.click(function (event:JqEvent) {
			var checked = exportForFlatomo.is(':checked');
			var toggle = function (e:JQuery) {
				e.enable(checked);
			};
			toggle(new JQuery('input#item_linkage'));
			toggle(new JQuery('select#item_export_class_kind'));
		});
		
		var option = new JQuery('.section_kind');
		option.change(function (event:JqEvent) {
			var selectedValue:String = new JQuery(event.target).children(':selected').val();
			
			var sectionName:String = event.target.getAttribute('name');
			var x = new JQuery('select.goto_section[name=$sectionName]');
			x.enable(selectedValue == '4');
		});
		
	}
	
	private function createItemProperty(itemName:String, linkage:String, item:ExtensionItem):Void {
		var content = new JQuery('div#main');
		content.append('<div id="item_name">$itemName</div>');
		
		var template = new Template('
		<table id="item_profile">
			<tr>
				<td />
				<td><input type="checkbox" id="item_export_for_flatomo" ::if EXPORT_FOR_FLATOMO::checked::end:: />Exports for Flatomo</td>
			</tr>
			<tr>
				<td>Linkage</td>
				<td><input type="text" id="item_linkage" value="::LINKAGE::" ::if !EXPORT_FOR_FLATOMO::disabled::end:: /></td>
			</tr>
			<tr>
				<td>ExportType</td>
				<td>
					<select id="item_export_class_kind" ::if !EXPORT_FOR_FLATOMO::disabled::end::>
						<option value="0" ::if (DO_TYPE == 0)::selected::end::>Container(Parts Animation)</option>
						<option value="1" ::if (DO_TYPE == 1)::selected::end::>Animation</option>
					</select>
				</td>
			</tr>
		</table>
		');
		
		/* Append Item property */
		content.append(template.execute( {
			// Export For Flatomo
			EXPORT_FOR_FLATOMO: item.linkageExportForFlatomo,
			// DisplayObjectType (flatomo.display.Container or flatomo.display.Animation)
			DO_TYPE: item.exportClassKind.getIndex(),
			// Linkage (jsfl.Item.linkageClassName)
			LINKAGE: item.linkageClassName,
		}));
		
	}
	
	private function createSectionProfile(sections:Array<Section>):Void {
		var content = new JQuery('div#main');
		
		var sectionTable = new JQuery('<table id="section_list">');
		content.append(sectionTable);
		
		var rowTemplate = new Template('
		<tr>
			<td>::SECTION_NAME::</td>
			<td>
				<select class="section_kind" name="::SECTION_NAME::">
					<option value="0" ::if (SECTION_KIND == 0)::selected::end::>Loop</option>
					<option value="1" ::if (SECTION_KIND == 1)::selected::end::>Once</option>
					<option value="2" ::if (SECTION_KIND == 2)::selected::end::>Pass</option>
					<option value="3" ::if (SECTION_KIND == 3)::selected::end::>Stop</option>
					<option value="4" ::if (SECTION_KIND == 4)::selected::end::>Goto</option>
				</select>
			</td>
			<td>
				<select class="goto_section" name="::SECTION_NAME::" ::if (SECTION_KIND != 4)::disabled::end::>
					::foreach ALL_SECTIONS::
					<option value="::__current__::" ::if (GOTO_SECTION == __current__)::selected::end::>::__current__::</option>
					::end::
				</select>
			</td>
		</tr>
		');
		
		for (section in sections) {
			sectionTable.append(rowTemplate.execute( {
				SECTION_NAME : section.name,
				SECTION_KIND : section.kind.getIndex(),
				GOTO_SECTION : switch (section.kind) {
					case Goto(name) : name;
					case _ : null;
				},
				ALL_SECTIONS : Lambda.list(sections.map(function (s) return s.name)),
			}));
		}
		
	}
	
	/**
	 * JSFLを実行します
	 * @param	command
	 * @param	callback
	 */
	private function invoke(command:ScriptApi, callback:Dynamic -> Void):Void {
		new CSInterface().evalScript('Script.invoke("' + Serializer.run(command) + '")', callback);
	}
	
}
