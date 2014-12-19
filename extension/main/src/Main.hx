package ;

import adobe.cep.CSInterface;
import flatomo.DocumentStatus;
import flatomo.ExportClassKind;
import flatomo.ExtensionItem;
import flatomo.ExtensionLibrary;
import flatomo.PublishProfile;
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
	
	public static function main() {
		new Main();
	}
	
	private function new() {
		// 作業中のドキュメントが有効なドキュメントかどうか
		invoke(ScriptApi.ValidationTest, function(validDocument_raw:Serialization) {
			// 警告オーバーレイ
			var warning = new JQuery('div#warning div');
			// 有効にするボタン
			var enableButton = new JQuery('input#enable_flatomo');
			
			var status:DocumentStatus = Unserializer.run(validDocument_raw);
			switch (status) {
				// 書き込みを許可されたドキュメント
				case Enabled:
					invoke(ScriptApi.GetPublishPath, initialize);
				// 書き込みが禁止されたドキュメント
				case Disabled: 
					warning.text('ドキュメントを操作する権限がありません');
					// 有効にするボタンが押されたら
					enableButton.click(function (event:JqEvent) {
						// ドキュメントを書き込み可能な状態にし初期化する
						invoke(ScriptApi.Enable);
						invoke(ScriptApi.SetPublishPath(''));
						invoke(ScriptApi.GetPublishPath, initialize);
					});
				// 対応していないドキュメントかドキュメントが開かれていない
				case Invalid:
					warning.text('対応していないドキュメントかドキュメントが開かれていません');
					// ボタンを削除して初期化を禁止する
					enableButton.css('display', 'none');
			}
		});
	}
	
	private function initialize(publishPath_raw:String):Void {
		var publishPath:String = Unserializer.run(publishPath_raw);
		
		// 警告オーバーレイを削除
		new JQuery('div#warning').css('display', 'none');
		
		new JQuery('input#filterExportItems').change(function (event:JqEvent) {
			updateLibrary();
		});
		
		// ライブラリを取得
		updateLibrary();
		
		// 仮
		new JQuery('input#export').click(function (event:JqEvent) { invoke(ScriptApi.Export); } );
		
		// 出力先
		var input_publishPath = new JQuery('input#publishPath');
		input_publishPath.val(publishPath);
		input_publishPath.change(publishProfileModified);
		
		// 出力先選択ボタン
		var input_browseExportDirectory = new JQuery('input#browseExportDirectory');
		input_browseExportDirectory.click(function (event:JqEvent) {
			// フォルダ選択ダイアログを表示
			browseForFolderURL("出力先", function (url:String) {
				// 出力先を敵とフィールドに代入し保存（キャンセルが押されたとき戻り値は'null'）
				if (url != null && url != "" && url != "null") {
					input_publishPath.val('${url}');
					publishProfileModified(event);
				}
			});
		});
		
		// アイテムの編集領域
		var div_main = new JQuery('div#main');
		div_main.change(save);
	}
	
	private function updateLibrary():Void {
		invoke(ScriptApi.GetExtensionLibrary(new JQuery('input#filterExportItems').is(':checked')), function(library_raw:Serialization) {
			createLibraryDiv(Unserializer.run(library_raw));
		});
	}
	
	private function save(event:JqEvent):Void {
		var sectionKindList:Iterable<JQuery> = new JQuery('#section_list').find('select.section_kind');
		var sections:List<Section> = sectionKindList.map(function (query:JQuery) {
			// セクション名（select.section_kind@name）
			var sectionName:String = query.attr('name');
			// 選択されているセクションの種類
			var sectionKindIndex:Int = Std.parseInt(query.children(':selected').val());
			// 選択されている遷移先セクション名
			var gotoSectionName:String = new JQuery('select.goto_section[name=${sectionName}]').val();
			
			var sectionKind:SectionKind = SectionKind.createByIndex(
				sectionKindIndex, 
				// SectionKind.Gotoならば引数に遷移先セクション名を取る
				if (sectionKindIndex == 4) [gotoSectionName] else []
			);
			
			// セクションの開始フレームと終了フレームは
			// パブリッシュ時にタイムラインから抽出するのでこの時点では必要ない
			return new Section(sectionName, sectionKind, 0, 0);
		});
		// 編集中のアイテム名
		var itemName:String = new JQuery('div#item_name').text();
		// 出力対象
		var linkageExportForFlatomo:Bool = new JQuery('input#item_export_for_flatomo').is(':checked');
		var areChildrenAccessible:Bool = new JQuery('input#item_areChildrenAccessible').is(':checked');
		// リンケージ設定
		var linkageClassName:String = new JQuery('input#item_linkage').val();
		// 出力形式
		var exportClassKindIndex:Int = Std.parseInt(new JQuery('select#item_export_class_kind').val());
		var exportClassKind:ExportClassKind = ExportClassKind.createByIndex(exportClassKindIndex);
		
		var item:ExtensionItem = {
			name: itemName,
			linkageExportForFlatomo: linkageExportForFlatomo,
			areChildrenAccessible: areChildrenAccessible,
			linkageClassName: linkageClassName,
			exportClassKind: exportClassKind,
			sections: sections.array(),
		}
		
		// ExtensionItemをItemに保存
		invoke(ScriptApi.SetExtensionItem(item));
		
		var onlyExportItems:Bool = new JQuery('input#filterExportItems').is(':checked');
		if (onlyExportItems) {
			updateLibrary();
		}
	}
	
	private function createLibraryDiv(extensionLibrary:ExtensionLibrary):Void {
		var library = new JQuery('div#library');
		
		// 'div#library'のすべての子を削除
		library.empty();
		
		// ライブラリを作成
		for (item in extensionLibrary) {
			var element = new JQuery('<div>$item</div>');
			element.click(libraryItemClicked);
			library.append(element);
		}
	}
	
	private function publishProfileModified(event:JqEvent):Void {
		// 出力先
		var input_publishPath = new JQuery('input#publishPath');
		var publishPath:String = input_publishPath.val();
		invoke(ScriptApi.SetPublishPath(publishPath));
	}
	
	private function libraryItemClicked(event:JqEvent):Void {
		// 選択されたライブラリ項目のテキストノードをアイテムパスとし項目の詳細を取得
		var itemPath:String = new JQuery(event.currentTarget).text();
		invoke(ScriptApi.SelectItem(itemPath));
		invoke(ScriptApi.GetExtensionItem(itemPath), function (extensionItem_raw:Serialization) {
			var extensionItem:ExtensionItem = Unserializer.run(extensionItem_raw);
			// 'div#main'を再構築する
			refreshMainDiv(extensionItem);
		});
	}
	
	private function refreshMainDiv(item:ExtensionItem):Void {
		var content = new JQuery('div#main');
		// 'div#main'のすべての子を削除
		content.empty();
		// 'div#main div#item_name'を作成（出力対象、リンケージ名、出力形式）
		createItemProperty(item.name, item.linkageClassName, item);
		// 'table#section_list'を作成（セクション情報）
		createSectionProfile(item.sections);
		
		// 出力対象かどうかを指定するチェックボックス
		var exportForFlatomo = new JQuery('input#item_export_for_flatomo');
		exportForFlatomo.change(function (event:JqEvent) {
			itemExportForFlatomoChanged();
		});
		itemExportForFlatomoChanged();
		
		// セクションの種類を選択するselect要素
		var sectionKindSelector = new JQuery('.section_kind');
		sectionKindSelector.change(function (event:JqEvent) {
			// 変更があったselect要素が属するセクション名
			var sectionName:String = event.target.getAttribute('name');
			// 選択されているセクションの種類
			var selectedSectionKind:String = new JQuery(event.target).children(':selected').val();
			// セクションの種類の種類をGotoに変更していたら遷移先を指定するselect要素を有効にする
			new JQuery('select.goto_section[name=$sectionName]').enable(selectedSectionKind == '4');
		});
	}
	
	private function itemExportForFlatomoChanged():Void {
		var item_exportForFlatomo = new JQuery('input#item_export_for_flatomo');
		// 出力対象でないときはリンケージ設定と出力形式の編集を禁止する
		var checked = item_exportForFlatomo.is(':checked');
		new JQuery('input#item_linkage').enable(checked);
		new JQuery('select#item_export_class_kind').enable(checked);
	}
	
	private function createItemProperty(itemName:String, linkage:String, item:ExtensionItem):Void {
		var template = new Template('
		<table id="item_profile">
			<tr>
				<td />
				<td><input type="checkbox" id="item_export_for_flatomo" ::if EXPORT_FOR_FLATOMO::checked::end:: />出力対象</td>
			</tr>
			<tr>
				<td />
				<td><input type="checkbox" id="item_areChildrenAccessible" ::if ARE_CHILDREN_ACCESSIBLE::checked::end:: />子オブジェクトをアクセス可能にする</td>
			</tr>
			<tr>
				<td>リンケージ設定</td>
				<td><input type="text" id="item_linkage" value="" /></td>
			</tr>
			<tr>
				<td>出力形式</td>
				<td>
					<select id="item_export_class_kind">
						<option value="0" ::if (DO_TYPE == 0)::selected::end::>コンテナ</option>
						<option value="1" ::if (DO_TYPE == 1)::selected::end::>アニメーション</option>
						<option value="2" ::if (DO_TYPE == 2)::selected::end::>パーツアニメーション</option>
					</select>
				</td>
			</tr>
		</table>
		');
		
		var content = new JQuery('div#main');
		content.append('<div id="item_name">$itemName</div>');
		content.append(template.execute( {
			// 出力対象
			EXPORT_FOR_FLATOMO: item.linkageExportForFlatomo,
			// 子オブジェクトをアクセス可能にする
			ARE_CHILDREN_ACCESSIBLE : item.areChildrenAccessible,
			// 出力形式
			DO_TYPE: item.exportClassKind.getIndex(),
		}));
		
		if (item.linkageClassName != null) {
			new JQuery('input#item_linkage').val(item.linkageClassName);
		}
	}
	
	private function createSectionProfile(sections:Array<Section>):Void {
		var template = new Template('
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
		
		var content = new JQuery('div#main');
		var table = new JQuery('<table id="section_list">');
		content.append(table);
		
		for (section in sections) {
			table.append(template.execute( {
				// セクション名
				SECTION_NAME : section.name,
				// セクションの種類
				SECTION_KIND : section.kind.getIndex(),
				// 遷移先セクション
				GOTO_SECTION : switch (section.kind) {
					case Goto(name) : name;
					case _ : null;
				},
				// すべてのセクションの名前の列挙
				ALL_SECTIONS : Lambda.list(sections.map(function (s) return s.name)),
			}));
		}
		
	}
	
	/**
	 * JSFLを実行します
	 * @param	command
	 * @param	callback
	 */
	private function invoke(command:ScriptApi, callback:Dynamic -> Void = null):Void {
		new CSInterface().evalScript('Script.invoke("' + Serializer.run(command) + '")', callback);
	}
	
	private function browseForFolderURL(description:String, callback:Dynamic -> Void):Void {
		new CSInterface().evalScript('fl.browseForFolderURL("${description}")', callback);
	}
	
}
