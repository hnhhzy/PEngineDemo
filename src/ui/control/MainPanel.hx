package ui.control;

import ui.view.*;
import hxPEngine.ui.utils.*;
import hxPEngine.ui.component.*;

class MainPanel extends GObject {
    private var _view:GComponent;

    public function new(?parent:h2d.Object) {
        super(parent);

        _view = UI_Login.createInstance();
        //this.addChild(_view);

       // var tf = new h2d.Text(hxd.res.DefaultFont.get(), this);
        //tf.text = "Hello Hashlink !";

    }
}