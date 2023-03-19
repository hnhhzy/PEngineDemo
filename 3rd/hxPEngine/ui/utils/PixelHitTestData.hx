package hxPEngine.ui.utils;

import haxe.io.Bytes;

class PixelHitTestData {
    public var pixelWidth:Int;
    public var scale:Float;
    public var pixels:Array<Int>;

    public function new()
    {
    }

    public function load(ba:haxe.io.BytesInput):Void
    {
        var t = ba.readInt32();
        pixelWidth = ba.readInt32();
        scale = ba.readByte();
        var len:Int = ba.readInt32();
        pixels = new Array<Int>();
        for(i in 0...len)
        {
            var j:Int = ba.readByte();
            if(j<0)
                j+=256;

            pixels[i] = j;
        }
    }
}