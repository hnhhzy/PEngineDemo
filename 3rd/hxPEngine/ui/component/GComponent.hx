package hxPEngine.ui.component;

import hxPEngine.ui.utils.*;

class GComponent extends GObject {
    private var _children:Array<GObject>;

    public function new(?parent:h2d.Object) {
        super(parent);
    }

    private function constructFromXML(xml:FastXML):Void {

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