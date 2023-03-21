package hxPEngine.ui.component;
import hxPEngine.ui.utils.*;

class GObject extends h2d.Object {
    public var id:String;
    public var packageItem:PackageItem;
    private var _underConstruct:Bool = false;
    private static var _gInstanceCounter:Int = 0;

    public var sourceWidth:Float;
    public var sourceHeight:Float;
    public var initWidth:Float;
    public var initHeight:Float;

    private var _rawWidth:Float;
    private var _rawHeight:Float;
    public var minWidth:Float;
    public var minHeight:Float;
    public var maxWidth:Float;
    public var maxHeight:Float;
    private var _width:Float;
    private var _height:Float;

    private var _pivotOffsetX:Float;
    private var _pivotOffsetY:Float;
    private var _pivotX:Float;
    private var _pivotY:Float;
    private var _pivotAsAnchor:Bool = false;
    private var _x:Float;
    private var _y:Float;
    private var _yOffset:Int = 0;
    //Size的实现方式，有两种，0-GObject的w/h等于DisplayObject的w/h。1-GObject的sourceWidth/sourceHeight等于DisplayObject的w/h，剩余部分由scale实现
    private var _sizeImplType:Int = 0;
    public var pixelSnapping:Bool = false;

    private var displayObject:h2d.Object;
    public var touchable:Bool;    
    private var grayed:Bool = false;
    public var tooltips:String;
    public var _blendMode:String;   // 待补，这里父类不一致
    private var data:Dynamic;    
    private var relations:Relations;


    public function new(?parent:h2d.Object) {
        super(parent);

        _x = 0;
        _y = 0;
        _width = 0;
        _height = 0;
        _rawWidth = 0;
        _rawHeight = 0;
        sourceWidth = 0;
        sourceHeight = 0;
        initWidth = 0;
        initHeight = 0;
        minWidth = 0;
        minHeight = 0;
        maxWidth = 0;
        maxHeight = 0;
        id = "_n" + _gInstanceCounter++;
        name = "";        
        touchable = true;
        _pivotX = 0;
        _pivotY = 0;
        _pivotOffsetX = 0;
        _pivotOffsetY = 0;

        // 待补，这里父类不一致
        //createDisplayObject();
        relations = new Relations(this);

        this.onInit();
    }

    public function onInit():Void {}

    public function constructFromResource():Void{}

    public function ensureSizeCorrect():Void{}

    @:final public function setXY(xv:Float, yv:Float):Void {
        //待补
        // if (_x != xv || _y != yv)
        // {
        //     var dx:Float = xv - _x;
        //     var dy:Float = yv - _y;
        //     _x = xv;
        //     _y = yv;

        //     handlePositionChanged();
        //     if (Std.isOfType(this, GGroup))
        //         cast(this, GGroup).moveChildren(dx, dy);

        //     updateGear(1);

        //     if (parent != null && !Std.is(parent, GList))
        //     {
        //         _parent.setBoundsChangedFlag();
        //         if (_group != null)
        //             _group.setBoundsChangedFlag();
        //         _dispatcher.dispatch(this, XY_CHANGED);
        //     }

        //     if (draggingObject == this && !sUpdateInDragging)
        //         this.localToGlobalRect(0, 0, this.width, this.height, sGlobalRect);
        // }
    }


    public function setup_afterAdd(xml:haxe.xml.Access):Void {
        //var s:String = xml.att.group;
        var s:String = try xml.att.group catch (e:Dynamic) null;
        // 待补
        // if (s != null)
        //     _group = try cast(_parent.getChildById(s), GGroup)
        //     catch (e:Dynamic) null;

        // var col = xml.descendants();
        // for (cxml in col.iterator())
        // {
        //     var index:Null<Int> = Reflect.field(GearXMLKeys, cxml.x.nodeName);
        //     if (index != null)
        //         getGear(index).setup(cxml);
        // }
    }

    public function setup_beforeAdd(xml:haxe.xml.Access):Void {
        var str:String;
        var arr:Array<String>;

        id = xml.att.id;
        name = xml.att.name;

        str = xml.att.xy;
        arr = str.split(",");
        this.setXY(Std.parseInt(arr[0]), Std.parseInt(arr[1]));

        //str = xml.att.size;
        str = try xml.att.size catch (e:Dynamic) null;
        if (str != null)
        {
            arr = str.split(",");
            initWidth = Std.parseInt(arr[0]);
            initHeight = Std.parseInt(arr[1]);
            setSize(initWidth, initHeight, true);
        }

        //str = xml.att.restrictSize;
        str = try xml.att.restrictSize catch (e:Dynamic) null;
        if (str != null)
        {
            arr = str.split(",");
            minWidth = Std.parseInt(arr[0]);
            maxWidth = Std.parseInt(arr[1]);
            minHeight = Std.parseInt(arr[2]);
            maxHeight = Std.parseInt(arr[3]);
        }

        //str = xml.att.scale;
        str = try xml.att.scale catch (e:Dynamic) null;
        if (str != null)
        {
            arr = str.split(",");
            // 待补，父类方法不一样
            //setScale(Std.parseFloat(arr[0]), Std.parseFloat(arr[1]));
        }

        //str = xml.att.rotation;
        str = try xml.att.rotation catch (e:Dynamic) null;
        if (str != null)
            this.rotation = Std.parseInt(str);

        //str = xml.att.alpha;
        str = try xml.att.alpha catch (e:Dynamic) null;
        if (str != null)
            this.alpha = Std.parseFloat(str);

        //str = xml.att.pivot;
        str = try xml.att.pivot catch (e:Dynamic) null;
        if (str != null)
        {
            arr = str.split(",");
            //str = xml.att.anchor;
            str = try xml.att.anchor catch (e:Dynamic) "false";
            // 待补，父类方法不一样
            //this.setPivot(Std.parseFloat(arr[0]), Std.parseFloat(arr[1]), str == "true");
        }

        //if (xml.att.touchable == "false")
        if ((try xml.att.touchable catch (e:Dynamic) "true") == "false")
            this.touchable = false;
        //if (xml.att.visible == "false")
        if ((try xml.att.visible catch (e:Dynamic) "true") == "false")
            this.visible = false;
        //if (xml.att.grayed == "true")
        if ((try xml.att.grayed catch (e:Dynamic) "false") == "true")
            this.grayed = true;
        //this.tooltips = xml.att.tooltips;        
        this.tooltips = try xml.att.tooltips catch (e:Dynamic) "";

        //str = xml.att.blend;
        str = try xml.att.blend catch (e:Dynamic) null;
        if (str != null)
            this._blendMode = str;

        //str = xml.att.filter;
        str = try xml.att.filter catch (e:Dynamic) null;
        if (str != null)
        {
            switch (str)
            {
                case "color":
                    str = xml.att.filterData;
                    arr = str.split(",");
                    var cm:ColorMatrix = new ColorMatrix();
                    cm.adjustBrightness(Std.parseFloat(arr[0]));
                    cm.adjustContrast(Std.parseFloat(arr[1]));
                    cm.adjustSaturation(Std.parseFloat(arr[2]));
                    cm.adjustHue(Std.parseFloat(arr[3]));
                    // 待补，和父类不一致
                    //var cf:ColorMatrixFilter = new ColorMatrixFilter(cm);
                    //this.filters = [cf];
            }
        }

        //str = xml.att.customData;
        str = try xml.att.customData catch (e:Dynamic) null;
        if (str != null) {
            this.data = str;
        }
    }

    private function internalSetPivot(xv:Float, yv:Float, asAnchor:Bool):Void {
        _pivotX = xv;
        _pivotY = yv;
        _pivotAsAnchor = asAnchor;
        if (_pivotAsAnchor)
            handlePositionChanged();
    }

    private function handlePositionChanged():Void {
        if (displayObject != null)
        {
            var xv:Float = _x;
            var yv:Float = _y + _yOffset;
            if (_pivotAsAnchor)
            {
                xv -= _pivotX * _width;
                yv -= _pivotY * _height;
            }
            if (pixelSnapping)
            {
                xv = Math.round(xv);
                yv = Math.round(yv);
            }
            displayObject.x = xv + _pivotOffsetX;
            displayObject.y = yv + _pivotOffsetY;
        }
    }

    public function setSize(wv:Float, hv:Float, ignorePivot:Bool = false):Void {
        if (_rawWidth != wv || _rawHeight != hv)
        {
            _rawWidth = wv;
            _rawHeight = hv;
            if (wv < minWidth)
                wv = minWidth;
            if (hv < minHeight)
                hv = minHeight;
            if (maxWidth > 0 && wv > maxWidth)
                wv = maxWidth;
            if (maxHeight > 0 && hv > maxHeight)
                hv = maxHeight;
            var dWidth:Float = wv - _width;
            var dHeight:Float = hv - _height;

            _width = wv;
            _height = hv;

            // handleSizeChanged();
            // if (_pivotX != 0 || _pivotY != 0)
            // {
            //     if (!_pivotAsAnchor)
            //     {
            //         if (!ignorePivot)
            //             this.setXY(this.x - _pivotX * dWidth, this.y - _pivotY * dHeight);
            //         updatePivotOffset();
            //     }
            //     else
            //     {
            //         applyPivot();
            //     }
            // }

            // if (Std.is(this, GGroup))
            //     cast(this, GGroup).resizeChildren(dWidth, dHeight);

            // updateGear(2);

            // if (_parent != null)
            // {
            //     _parent.setBoundsChangedFlag();
            //     _relations.onOwnerSizeChanged(dWidth, dHeight);
            //     if (_group != null)
            //         _group.setBoundsChangedFlag(true);
            // }

            // _dispatcher.dispatch(this, SIZE_CHANGED);
        }
    }

}