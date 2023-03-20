import hxPEngine.utils.Assets;
import ui.control.*;
import h2d.Text;

class Main extends hxd.App {
    private var m_mainPanel:MainPanel;

    override function update(dt : Float) {
        #if hl
        hxPEngine.utils.hl.Thread.loop( );
        #end
     }

    override function init() {
        super.init();

        var assets = new Assets(); 
        assets.loadFile("res/ui/View.pui");
        assets.start(onAssetsLoaded);
        //m_mainPanel = new MainPanel(s2d);
        //s2d.addChild(m_mainPanel);
    }

    function onAssetsLoaded(f:Float) {
        if (f == 1) {
            trace("assets loaded");
            ui.view.ViewBinder.bindAll();
            m_mainPanel = new MainPanel(s2d);
        }
    }

    static function main() {
        new Main();
    }
}