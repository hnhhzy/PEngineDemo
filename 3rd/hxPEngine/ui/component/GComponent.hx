package hxPEngine.ui.component;

import hxPEngine.ui.utils.*;

class GComponent extends GObject {
    private var _children:Array<GObject>;
    public var opaque:Bool;
    private var _margin:Margin;    
    private var _buildingDisplayList:Bool = false;    
    public var mask:h2d.Object;

    public function new(?parent:h2d.Object) {
        super(parent);
        _children = new Array<GObject>();
        _margin = new Margin();
    }

    private function constructFromXML(xml:haxe.xml.Access):Void {

    }

    override public function constructFromResource():Void{
        constructFromResource2(null, 0);
    }

    public function getChildById(id:String):GObject {
        var cnt:Int = _children.length;
        for (i in 0...cnt)
        {
            if (_children[i].id == id)
                return _children[i];
        }

        return null;
    }

    private function constructFromResource2(objectPool:Array<GObject>, poolIndex:Int):Void {
        var xml:haxe.xml.Access = packageItem.owner.getComponentData(packageItem);
        var str:String;
        var arr:Array<Dynamic>;
        
        _underConstruct = true;

        str = xml.att.size;
        arr = str.split(",");
        sourceWidth = Std.parseInt(arr[0]);
        sourceHeight = Std.parseInt(arr[1]);
        initWidth = sourceWidth;
        initHeight = sourceHeight;

        setSize(sourceWidth, sourceHeight);

        //str = xml.att.pivot;
        var str = try xml.att.pivot catch (e:Dynamic) null;
        if (str != null) {
            arr = str.split(",");
            str = xml.att.anchor;
            internalSetPivot(Std.parseFloat(arr[0]), Std.parseFloat(arr[1]), str == "true");
        }

        //str = xml.att.restrictSize;
        str = try xml.att.restrictSize catch (e:Dynamic) null;
        if (str != null) {
            arr = str.split(",");
            minWidth = Std.parseInt(arr[0]);
            maxWidth = Std.parseInt(arr[1]);
            minHeight = Std.parseInt(arr[2]);
            maxHeight = Std.parseInt(arr[3]);
        }

        //str = xml.att.opaque;
        str = try xml.att.opaque catch (e:Dynamic) "false";
        if (str != "false") {
            this.opaque = true;
        }

        var overflow:Int;
        //str = xml.att.overflow;
        str = try xml.att.overflow catch (e:Dynamic) null;
        if (str != null) {
            overflow = OverflowType.parse(str);
        }
        else {
            overflow = OverflowType.Visible;
        }

        //str = xml.att.margin;
        str = try xml.att.margin catch (e:Dynamic) null;
        if (str != null) {
            if(str != "") {
                _margin.parse(str);
            }
        }

        if (overflow == OverflowType.Scroll) {
            var scroll:Int = ScrollType.Both;
            //str = xml.att.scroll;
            str = try xml.att.scroll catch (e:Dynamic) null;
            if (str != null) {
                scroll = ScrollType.parse(str);
            }
            else {
                scroll = ScrollType.Vertical;
            }

            var scrollBarDisplay:Int = ScrollBarDisplayType.Default;
            //str = xml.att.scrollBar;
            str = try xml.att.scrollBar catch (e:Dynamic) null;
            if (str != null) {
                scrollBarDisplay = ScrollBarDisplayType.parse(str);
            }
            else {
                scrollBarDisplay = ScrollBarDisplayType.Default;
            }
            //var scrollBarFlags:Int = Std.parseInt(xml.att.scrollBarFlags);
            var scrollBarFlags:Int = try Std.parseInt(xml.att.scrollBarFlags) catch (e:Dynamic) 0;
            var scrollBarMargin:Margin = new Margin();
            //str = xml.att.scrollBarMargin;
            str = try xml.att.scrollBarMargin catch (e:Dynamic) null;
            if (str != null) {
                scrollBarMargin.parse(str);
            }
            var vtScrollBarRes:String = null;
            var hzScrollBarRes:String = null;
            //str = xml.att.scrollBarRes;
            str = try xml.att.scrollBarRes catch (e:Dynamic) null;
            if (str != null)
            {
                arr = str.split(",");
                vtScrollBarRes = arr[0];
                hzScrollBarRes = arr[1];
            }

            setupScroll(scrollBarMargin, scroll, scrollBarDisplay, scrollBarFlags,
            vtScrollBarRes, hzScrollBarRes);

        }else {
            setupOverflow(overflow);
        }

        _buildingDisplayList = true;
        var col;
        // 注释待补
        // var col = xml.nodes.controller;
        // var controller:Controller;
        // for (cxml in col.iterator()) {
        //     controller = new Controller();
        //     _controllers.push(controller);
        //     controller._parent = this;
        //     controller.setup(cxml);
        // }

        var child:GObject;
        var displayList:Array<DisplayListItem> = packageItem.displayList;
        var childCount:Int = displayList.length;
        var i:Int;
        for (i in 0...childCount) {
            var di:DisplayListItem = displayList[i];
            if (objectPool != null) {
                child = objectPool[poolIndex + i];
            } else if (di.packageItem != null) {
                child = UIObjectFactory.newObject(di.packageItem);
                child.packageItem = di.packageItem;
                child.constructFromResource();
            } else {
                child = UIObjectFactory.newObject2(di.type);
            }

            child._underConstruct = true;
            child.setup_beforeAdd(di.desc);
            child.parent = this;
            _children.push(child);
        }

        this.relations.setup(xml);

        for (i in 0...childCount) {
            _children[i].relations.setup(displayList[i].desc);
        }

        for (i in 0...childCount) {
            child = _children[i];
            child.setup_afterAdd(displayList[i].desc);
            child._underConstruct = false;
        }

        //str = xml.att.mask;
        str = try xml.att.mask catch (e:Dynamic) null;
        if (str != null) {
            this.mask = getChildById(str).displayObject;
        }
        col = xml.nodes.transition;
        // 待补 基类不一致
        // var trans:Transition;
        // for (cxml in col.iterator()) {
        //     trans = new Transition(this);
        //     _transitions.push(trans);
        //     trans.setup(cxml);
        // }
    
        // if (_transitions.length > 0)
        // {
        //     this.addEventListener(Event.ADDED_TO_STAGE, p__addedToStage);
        //     this.addEventListener(Event.REMOVED_FROM_STAGE, __removedFromStage);
        // }

        //applyAllControllers();

        _buildingDisplayList = false;
        _underConstruct = false;

        //buildNativeDisplayList();
        //setBoundsChangedFlag();

        constructFromXML(xml);


    }

    // 待补
    private function setupScroll(scrollBarMargin:Margin, scroll:Int, scrollBarDisplay:Int, flags:Int, vtScrollBarRes:String, hzScrollBarRes:String):Void {
        // if (_rootContainer == _container)
        // {
        // _container = new Sprite();
        // _rootContainer.addChild(_container);
        // }
        // _scrollPane = new ScrollPane(this, scroll, scrollBarMargin, scrollBarDisplay, flags,
        // vtScrollBarRes, hzScrollBarRes);
    }

    private function setupOverflow(overflow:Int):Void {
        // if (overflow == OverflowType.Hidden)
        // {
        //     if (_rootContainer == _container)
        //     {
        //         _container = new Sprite();
        //         _rootContainer.addChild(_container);
        //     }

        //     _container.scrollRect = new Rectangle();
        //     updateClipRect();

        //     _container.x = _margin.left;
        //     _container.y = _margin.top;
        // }
        // else if (_margin.left != 0 || _margin.top != 0)
        // {
        //     if (_rootContainer == _container)
        //     {
        //         _container = new Sprite();
        //         _rootContainer.addChild(_container);
        //     }

        //     _container.x = _margin.left;
        //     _container.y = _margin.top;
        // }
    }


    public function getChild(name:String):GObject {
        var cnt:Int = _children.length;
        for (i in 0...cnt)
        {
            if (_children[i].name == name)
                return _children[i];
        }

        return null;
    }
}