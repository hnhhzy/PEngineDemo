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

    private static var _stringsSource : Map<String, Dynamic>;

    public function new() {
        _items = new Array<PackageItem>();
        _hitTestDatas = new Map<String, PixelHitTestData>();
    }

    public static function getById(id : String) : UIPackage {
        return _packageInstById[id];
    }

    public function getItemById(itemId : String) : PackageItem {
        return _itemsById[itemId];
    }
    
    public function getItemByName(resName : String) : PackageItem {
        return _itemsByName[resName];
    }

    private function getXMLDesc(file : String) : haxe.xml.Access{

        var _entry = ZipUtils.readDescFile(_entries, file);
        if(_entry == null) {
            trace(file + " not found");
            return null;
        }

        var str = _entry.data.toString();        
        var sxml:Xml = Xml.parse(str);
        var xml = new haxe.xml.Access(sxml.firstChild());
        return xml;
    }

    public function getComponentData(item : PackageItem) : haxe.xml.Access {
        if (item.componentData == null)
        {
            var xml : haxe.xml.Access = getXMLDesc(item.id + ".xml");
            
            item.componentData = xml;
            
            loadComponentChildren(item);
            translateComponent(item);
        }
        
        return item.componentData;
    }

    private function loadComponentChildren(item : PackageItem) : Void {
        //var listNode = item.componentData.node.displayList;
        var listNode = try item.componentData.node.displayList catch (e:Dynamic) null;
        //trace(listNode);
        if (listNode != null) {
            var col : Iterator<haxe.xml.Access> = listNode.elements;
            item.displayList = new Array<DisplayListItem>();
            var di : DisplayListItem;
            for (cxml in col) {
                var tagName : String = cxml.name;
                //var src : String = cxml.att.src;
                var src = try cxml.att.src catch (e:Dynamic) null;
                if (src != null) {
                    //trace(cxml);
                    //var pkgId : String = cxml.att.pkg;
                    var pkgId = try cxml.att.pkg catch (e:Dynamic) null;
                    var pkg : UIPackage;
                    if (pkgId != null && pkgId != item.owner.id)  {
                        pkg = UIPackage.getById(pkgId);
                    } else {
                        pkg = item.owner;
                    }

                    var pi : PackageItem = (pkg != null) ? pkg.getItemById(src) : null;
                    if (pi != null) {
                        di = new DisplayListItem(pi, null);
                    } else {
                        di = new DisplayListItem(null, tagName);
                    }
                } else {
                    var input = try cxml.att.input catch (e:Dynamic) "false";
                    if (tagName == "text" && input == "true") {
                        di = new DisplayListItem(null, "inputtext");
                    } else {
                        di = new DisplayListItem(null, tagName);
                    }
                }

                di.desc = cxml;
                item.displayList.push(di);

            }
        } else {
            item.displayList = new Array<DisplayListItem>();
        }
    }

    private function translateComponent(item:PackageItem) : Void {
        if(_stringsSource==null) {
            return;
        }

        var strings:Map<String, Dynamic> = _stringsSource[this.id + item.id];
        if(strings==null) {
            return;
        }
        var cnt:Int = item.displayList.length;
        var value:Dynamic;
        var cxml:haxe.xml.Access;
        var dxml:haxe.xml.Access;
        for(i in 0...cnt) {
            cxml = item.displayList[i].desc;
            var ename : String = cxml.name;
            var elementId : String = cxml.att.id;

            if (cxml.att.resolve("tooltips").length > 0) {
                value = strings[elementId + "-tips"];
                if (value != null) {
                    // cxml.setAttribute("tooltips", value);
                    // 检查结果
                    cxml.setProperty("tooltips", value);
                }
            }
            dxml = cxml.node.gearText;
            if (dxml != null) {
                value = strings[elementId+"-texts"];
                if(value!=null) {
                    //dxml.setAttribute("values", value);
                    dxml.setProperty("values", value);
                }

                value = strings[elementId+"-texts_def"];
                if(value!=null) {
                    //dxml.setAttribute("default", value);
                    dxml.setProperty("default", value);
                }
            }

            var items : Array<haxe.xml.Access>;
            var j : Int;
            if (ename == "text" || ename == "richtext") {
                value = strings[elementId];
                if (value != null) {
                    //cxml.setAttribute("text", value);
                    cxml.setProperty("text", value);
                }
                value = strings[elementId + "-prompt"];
                if (value != null) {
                    //cxml.setAttribute("prompt", value);
                    cxml.setProperty("prompt", value);
                }
            } else if (ename == "list") {
                items = cxml.nodes.item;
                j = 0;
                for (exml in items.iterator()) {
                    value = strings[elementId + "-" + j];
                    if (value != null) {
                        //exml.setAttribute("title", value);
                        exml.setProperty("title", value);
                    }
                    j++;
                }
            } else if (ename == "component") {
                dxml = cxml.node.Button;
                if (dxml != null) {
                    value = strings[elementId];
                    if (value != null) {
                        //dxml.setAttribute("title", value);
                        dxml.setProperty("title", value);
                    }
                    value = strings[elementId + "-0"];
                    if (value != null) {
                        //dxml.setAttribute("selectedTitle", value);
                        dxml.setProperty("selectedTitle", value);
                    }
                    continue;
                }

                dxml = cxml.node.Label;
                if (dxml != null) {
                    value = strings[elementId];
                    if (value != null) {
                        //dxml.setAttribute("title", value);
                        dxml.setProperty("title", value);
                    }
                    value = strings[elementId+"-prompt"];
                    if(value!=null) {
                        //dxml.setAttribute("prompt", value);
                        dxml.setProperty("prompt", value);
                    }
                    continue;
                }

                dxml = cxml.node.ComboBox;
                if (dxml != null) {
                    value = strings[elementId];
                    if (value != null) {
                        //dxml.setAttribute("title", value);
                        dxml.setProperty("title", value);
                    }

                    items = dxml.nodes.item;
                    j = 0;
                    for (exml in items.iterator()) {
                        value = strings[elementId + "-" + j];
                        if (value != null) {
                            //exml.setAttribute("title", value);
                            exml.setProperty("title", value);
                        }
                        j++;
                    }
                    continue;
                }
            }
        }

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

        var ret = xml.node.resolve("resources");
        var resources:Iterator<haxe.xml.Access>  = null;
        if(ret != null) {
            resources = ret.elements;
        }

        _itemsById = new Map<String, PackageItem>();
        _itemsByName = new Map<String, PackageItem>();

        var pi : PackageItem;
        var cxml : haxe.xml.Access;
        var arr : Array<String>;

        // https://github.com/rakuten/FairyGUI-haxe/blob/master/src/fairygui/UIPackage.hx
        if(resources != null) {
            for (cxml in resources) {
                pi = new PackageItem();
                pi.owner = this;
                pi.type = PackageItemType.parseType(cxml.name);
                pi.id = cxml.att.id;
                pi.name = cxml.att.name;
                // 待补，新编辑器是.src不是file
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

        _constructing++;
        g.packageItem = item;
        g.constructFromResource();
        _constructing--;
        return g;
    }


    public static function getItemByURL(url : String) : PackageItem {
        if (url == null)
            return null;

        var pos1:Int = url.indexOf("//");
        if (pos1 == -1)
            return null;
        var pkg:UIPackage;
        var pos2:Int = url.indexOf("/", pos1 + 2);
        if (pos2 == -1)
        {
            if (url.length > 13)
            {
                var pkgId:String = url.substr(5, 8);
                pkg = getById(pkgId);
                if (pkg != null)
                {
                    var srcId:String = url.substr(13);
                    return pkg.getItemById(srcId);
                }
            }
        }
        else
        {
            var pkgName:String = url.substr(pos1 + 2, pos2 - pos1 - 2);
            pkg = getByName(pkgName);
            if (pkg != null)
            {
                var srcName:String = url.substr(pos2 + 1);
                return pkg.getItemByName(srcName);
            }
        }

        return null;
    }
    
}