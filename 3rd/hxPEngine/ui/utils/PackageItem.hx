package hxPEngine.ui.utils;

class PackageItem {
    public var owner : UIPackage;
    
    public var type : Int = 0;
    public var id : String;
    public var name : String;
    public var width : Int = 0;
    public var height : Int = 0;
    public var file : String;

    //image
    public var scale9Grid : hxd.clipper.Rect;
    public var scaleByTile : Bool = false;
    public var smoothing : Bool = false;
    public var tileGridIndice : Int = 0;

    //componenet
    public var extensionType:Class<Dynamic>;


    public function new() {

    }
}