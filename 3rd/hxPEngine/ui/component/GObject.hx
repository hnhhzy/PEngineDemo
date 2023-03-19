package hxPEngine.ui.component;
import hxPEngine.ui.utils.*;

class GObject extends h2d.Object {
    public var packageItem:PackageItem;

    public function new(?parent:h2d.Object) {
        super(parent);
        this.onInit();
    }

    public function onInit():Void {}
}