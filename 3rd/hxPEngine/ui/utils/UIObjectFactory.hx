package hxPEngine.ui.utils;

import hxPEngine.ui.component.*;

class UIObjectFactory {
    private static var packageItemExtensions : Map<String, Class<Dynamic>> = new Map<String, Class<Dynamic>>();
    
    public static function newObject(pi : PackageItem) : GObject {
        switch (pi.type)
        {

        }
        return null;
    }

    public static function setPackageItemExtension(url : String, type : Class<Dynamic>) : Void {
        if (url == null) {            
            // throw new Error("Invaild url: " + url);
            return;
        }

        var pi:PackageItem = UIPackage.getItemByURL(url);
        if (pi != null)
            pi.extensionType = type;

        packageItemExtensions[url] = type;
    }


}