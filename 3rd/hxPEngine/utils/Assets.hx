package hxPEngine.utils;

import haxe.io.Bytes;
import hxPEngine.utils.loader.parser.AssetsType;
import hxPEngine.utils.loader.parser.BaseParser;
import hxPEngine.utils.loader.LoaderAssets;

import h2d.Tile;
using Reflect;

/**
 * 资源管理器
 */
 class Assets {
	/**
	 * 加载最大线程
	 */
	public var maxLoadCounts:Int = #if hl 30 #else 10 #end;

	/**
	 * 可提供路径，更改默认的加载路径，它会拼接在所有的加载资源的前面
	 */
	public var repath:String = null;

	/**
	 * 当前已载入的线程
	 */
	private var _currentLoadCounts:Int = 0;

	private var _loadlist:Array<BaseParser> = [];

	private var _loadedData:Map<AssetsType, Map<String, Dynamic>> = [];

	/**
	 * 当前载入进度
	 */
	private var _currentLoadIndex = 0;

	/**
	 * 已载入完成的数量
	 */
	private var _loadedCounts:Int = 0;

	/**
	 * 加载回调
	 */
	private var _onProgress:Float->Void;

	public function new() {}

	/**
	 * 拼接repath的加载路径
	 * @param path 
	 * @return String
	 */
	public function addRepath(path:String):String {
		if (repath == null)
			return path;
		if (!StringTools.endsWith(repath, "/")) {
			return repath + "/" + path;
		}
		return repath + path;
	}

	/**
	 * 加载单个文件
	 * @param file 
	 */
	public function loadFile(file:String):Void {
		var ext = StringUtils.getExtType(file);
		for (parser in LoaderAssets.fileparser) {
			var bool = parser.callMethod(parser.getProperty("support"), [ext]);
			if (bool) {
				_loadlist.push(Type.createInstance(parser, [addRepath(file)]));
				break;
			}
		}
	}

	/**
	 * 加载一个解析器
	 * @param parser 
	 */
	public function loadParser(parser:BaseParser):Void{
		_loadlist.push(parser);
	}

	/**
	 * 用于重写解析路径名称
	 * @param path
	 * @return String
	 */
	dynamic public function onPasingPathName(path:String):String {
		return StringUtils.getName(path);
	}

	/**
	 * 开始加载
	 * @param cb 
	 */
	public function start(cb:Float->Void):Void {
		_onProgress = cb;
		_currentLoadIndex = 0;
		_currentLoadCounts = 0;
		_loadedCounts = 0;
		loadNext();
	}

	/**
	 * 开始加载下一个
	 */
	private function loadNext():Void {
		if (_currentLoadCounts >= maxLoadCounts)
			return;
		if (_loadedCounts >= _loadlist.length) {
			// 加载完成
			_onProgress(1);
			return;
		} else {
			_onProgress((_loadedCounts) / _loadlist.length);
		}
		_currentLoadCounts++;
		_currentLoadIndex++;
		var parser = _loadlist[_currentLoadIndex - 1];
		if (parser == null)
			return;
		parser.out = onAssetsOut;
		parser.error = onError;
		parser.load(this);
		// 发起多个加载
		if (_currentLoadCounts < maxLoadCounts)
			loadNext();
	}

	public function onError(msg:String):Void {
		trace("load fail:", msg);
	}

	/**
	 * 加载完成资源输出
	 * @param parser 
	 * @param type 
	 * @param assetsData 
	 * @param pro 
	 */
	private function onAssetsOut(parser:BaseParser, type:AssetsType, assetsData:Dynamic, pro:Float):Void {
		if (assetsData != null) {
			setTypeAssets(type, parser.getName(), assetsData);
		}
		if (pro == 1) {
			// 下一个
			_loadedCounts++;
			_currentLoadCounts--;
			this.loadNext();
		}
	}

	/**
	 * 判断此类型的资源是否存在
	 * @param type 
	 * @param name 
	 * @return Bool
	 */
	public function hasTypeAssets(type:AssetsType, name:String):Bool {
		if (_loadedData.exists(type)) {
			return _loadedData.get(type).exists(name);
		}
		return false;
	}

	/**
	 * 获取此类型的资源
	 * @param type 
	 * @param name 
	 * @return Dynamic
	 */
	public function getTypeAssets(type:AssetsType, name:String):Any {
		if (_loadedData.exists(type)) {
			return _loadedData.get(type).get(name);
		}
		return null;
	}

	/**
	 * 设置此类型的资源
	 * @param type 
	 * @param name 
	 * @param data 
	 */
	public function setTypeAssets(type:AssetsType, name:String, data:Any):Void {
		if (!_loadedData.exists(type)) {
			_loadedData.set(type, []);
		}
		_loadedData.get(type).set(name, data);
	}

	/**
	 * 获取二进制对象
	 * @param id 
	 * @return Bytes
	 */
	public function getBytes(id:String):Bytes {
		return getTypeAssets(BYTES, id);
	}

	/**
	 * 卸载所有资源
	 */
	public function unloadAll():Void {
		// unloadTypeAssets(AssetsType.ATLAS);
		// unloadTypeAssets(AssetsType.BITMAP);
		// unloadTypeAssets(AssetsType.BITMAP_TILE);
		// unloadTypeAssets(AssetsType.JSON);
		// unloadTypeAssets(AssetsType.SOUND);
		// unloadTypeAssets(AssetsType.SPINE_ATLAS);
		// unloadTypeAssets(AssetsType.XML);
		unloadTypeAssets(AssetsType.UI);
		unloadTypeAssets(AssetsType.BYTES);
	}

	/**
	 * 卸载对应类型的资源
	 * @param type 
	 */
	public function unloadTypeAssets(type:AssetsType):Void {
		if (_loadedData.exists(type)) {
			var m = _loadedData.get(type);
			for (key => value in m) {
				if (value is Tile) {
					cast(value, Tile).dispose();
				}
			}
			_loadedData.remove(type);
		}
	}
}