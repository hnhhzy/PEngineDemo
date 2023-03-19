package hxPEngine.ui.utils;
import hxPEngine.utils.BytesUtil;
import hxPEngine.utils.ZipUtils;
import deflatex.*;
import haxe.io.Bytes;
import hxPEngine.ui.component.*;
import haxe.zip.*;
using Reflect;

class UIPackage {
    public var id:String;
    public var name:String;
    private static var _constructing : Int = 0;
    private static var _packageInstById : Map<String, UIPackage> = new Map<String, UIPackage>();
    private static var _packageInstByName : Map<String, UIPackage> = new Map<String, UIPackage>();
    private var _itemsById : Map<String, PackageItem>;
    private var _itemsByName : Map<String, PackageItem>;
    private var _items : Array<PackageItem>;
    private var _hitTestDatas:Map<String, PixelHitTestData>;

    private var _entries:List<haxe.zip.Entry>;

    public function new() {
        _items = new Array<PackageItem>();
        _hitTestDatas = new Map<String, PixelHitTestData>();
    }

    public static function addPackage(data : Bytes) : UIPackage {
            var pkg : UIPackage = new UIPackage();
            //var reader : ZipUIPackageReader = new ZipUIPackageReader(desc, res);
            //var inflater:Inflater = new Inflater();
            //var decompressed:Bytes = inflater.decompress(data);
            var bytesInput = new haxe.io.BytesInput(data);
            var reader = new  Reader(bytesInput);


            pkg.create(reader);
            _packageInstById[pkg.id] = pkg;
            _packageInstByName[pkg.name] = pkg;
            return pkg;
    }

    function create(reader:Reader) {
        _entries = reader.read(); 
        
        var _entry = ZipUtils.readDescFile(_entries, "package.xml");
        if(_entry == null) {
            trace("package.xml not found");
            return;
        }

        var str = _entry.data.toString();        
        var sxml:Xml = Xml.parse(str);
        var xml = new haxe.xml.Access(sxml.firstChild());

        id = xml.att.id;
        name = xml.att.name;

        var resources:Iterator<haxe.xml.Access> = xml.node.resolve("resources").elements;

        _itemsById = new Map<String, PackageItem>();
        _itemsByName = new Map<String, PackageItem>();

        var pi : PackageItem;
        var cxml : haxe.xml.Access;
        var arr : Array<String>;

        // https://github.com/rakuten/FairyGUI-haxe/blob/master/src/fairygui/UIPackage.hx
        for (cxml in resources) {
            pi = new PackageItem();
            pi.owner = this;
            pi.type = PackageItemType.parseType(cxml.name);
            pi.id = cxml.att.id;
            pi.name = cxml.att.name;
            pi.file = try cxml.att.file catch (e:Dynamic) null;
            var sizeStr = try cxml.att.size catch (e:Dynamic) null;
            if (sizeStr != null) {
                arr = sizeStr.split(",");
                pi.width = Std.parseInt(arr[0]);
                pi.height = Std.parseInt(arr[1]);
            }

            switch (pi.type) {
                case PackageItemType.Image: {
                    str = try cxml.att.scale catch(e:Dynamic) null;
                    if (str == "9grid") {
                        pi.scale9Grid = new hxd.clipper.Rect();
                        str = cxml.att.scale9grid;
                        arr = str.split(",");
                        pi.scale9Grid.left = Std.parseInt(arr[0]);
                        pi.scale9Grid.top = Std.parseInt(arr[1]);
                        pi.scale9Grid.right = Std.parseInt(arr[2]);
                        pi.scale9Grid.bottom = Std.parseInt(arr[3]);
                        
                        str = try cxml.att.gridTile catch(e:Dynamic) null;
                        if (str != null) {
                            pi.tileGridIndice = Std.parseInt(str);
                        }
                    } else if (str == "tile") {
                        pi.scaleByTile = true;
                    }
                    str = try cxml.att.smoothing catch(e:Dynamic) null;
                    pi.smoothing = str != "false";
                }
                case PackageItemType.MovieClip: {
                    str = try cxml.att.smoothing catch(e:Dynamic) null;
                    pi.smoothing = str != "false";
                }
                case PackageItemType.Component: {
                    //UIObjectFactory.resolvePackageItemExtension(pi);
                }
            }
            _items.push(pi);
            _itemsById[pi.id] = pi;
            if (pi.name != null) {
                _itemsByName[pi.name] = pi;
            }            
        }

        var ba:Bytes = ZipUtils.readResFile(_entries, "hittest.bytes");
        if(ba!=null) {            
            var bas = new haxe.io.BytesInput(ba);
            // 需要设置编码为 BIG_ENDIAN 我也不知道为什么
            bas.bigEndian = true;
            if(bas != null) {
                var hitTestData:PixelHitTestData = new PixelHitTestData();
                _hitTestDatas[BytesUtil.readUTF(bas)] = hitTestData;
                hitTestData.load(bas);
            }
        }

        var cnt : Int = _items.length;
        for (i in 0...cnt) {
            pi = _items[i];
            if (pi.type == PackageItemType.Font) {
                //loadFont(pi);
                //_bitmapFonts[pi.bitmapFont.id] = pi.bitmapFont;
            }
        }

    }

    public static function getByName(name : String) : UIPackage {
            return _packageInstByName[name];
    }

    public static function createObject(pkgName : String, resName : String, userClass : Dynamic = null) : GObject {
        var pkg : UIPackage = getByName(pkgName);
        if (pkg != null) 
            return pkg.createObject2(resName, userClass);

        return null;
    }

    public function createObject2(resName : String, userClass : Dynamic = null) : GObject {
        var pi : PackageItem = _itemsByName[resName];
        if (pi != null) 
            return internalCreateObject(pi, userClass);
        else 
        return null;
    }

    private function internalCreateObject(item : PackageItem, userClass : Dynamic) : GObject {
        var g : GObject = null;
        if (item.type == PackageItemType.Component) 
        {
            if (userClass != null) 
            {
                if (Std.isOfType(userClass, Class)) 
                    g = cast(Type.createInstance(userClass, []), GObject);
                else 
                    g = cast(userClass, GObject);
            }
            else 
                g = UIObjectFactory.newObject(item);
        }
        else 
            g = UIObjectFactory.newObject(item);
        
        if (g == null) 
            return null;
        
        g.packageItem = item;
        return g;
    }
}