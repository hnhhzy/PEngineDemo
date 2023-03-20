package hxPEngine.ui.utils;

class DisplayListItem
{
    public var packageItem : PackageItem;
    public var type : String;
    public var desc : haxe.xml.Access;
    public var listItemCount : Int = 0;
    
    public function new(packageItem : PackageItem, type : String)
    {
        this.packageItem = packageItem;
        this.type = type;
    }
}