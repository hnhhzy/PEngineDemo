package hxPEngine.utils.loader.parser;

import hxPEngine.ui.utils.*;

/**
 * zip载入解析器
 */
 class UIParser extends BaseParser {

	public static function support(type:String):Bool {
		var ext = type.toLowerCase();
        return ext == "pui";
	}

	override function process() {
		AssetsUtils.loadBytes(getData(), function(data) {
			UIPackage.addPackage(data);


			// 对它进行引用
			this.out(this, UI, data, 1);
		}, error);
	}
}