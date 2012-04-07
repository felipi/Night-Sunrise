package System 
{
	import Data.Global;
	
	import fdd.queue.Queue;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;

	/**
	 * ...
	 * @author Felipi
	 */
	public class AssetManager
	{
		public static var CHARACTER : String = "Resources/Graphics/Characters/";
		public static var PICTURE : String = "Resources/Graphics/Pictures/";
		public static var MUSIC : String = "Resources/Sounds/Musics/";
		public static var EFFECT : String = "Resources/Sounds/Effects/";
		public static var LEVEL : String = "Resources/Levels/";
		public static var LEVELXML : String = "xml/levels/";
		public static var ASSETSXML : String = "xml/levels/assets/";
		
		public var queue : Queue;
		private var assets : Object = { };
		
		public function AssetManager() 
		{
			queue = new Queue(false);
		}
		
		public function RegisterAsset( name:String, type:String, url:String ) : void {
			if (type == MUSIC || type == EFFECT) {
				var sound : Sound = new Sound();
				
				assets[name] = { object : sound, type : Sound };
				queue.addItem(sound, [Event.COMPLETE], sound.load, [new URLRequest(Global.deployedURL + type + url)]);				
			} else if (type == LEVELXML) {
				var urlloader : URLLoader = new URLLoader();
				
				assets[name] = { object : urlloader, type : URLLoader };
				queue.addItem(urlloader, [Event.COMPLETE], urlloader.load, [new URLRequest(Global.deployedURL + type + url)]);
			}else {
				var loader : Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(ioe:IOErrorEvent):void { trace(ioe); } );
				assets[name] = { object : loader, type : Loader };
				queue.addItem(loader.contentLoaderInfo, [Event.COMPLETE], loader.load, [new URLRequest(Global.deployedURL + type + url)]);
			}
			
		}
		
		public function Load() : void {
			queue.start();
		}
		
		public function Asset(name:String): Object {
			if (assets[name] == null) {
				if (this != GameManager.assetManager) {
					return GameManager.assetManager.Asset(name);
				}else {
					return null;
				}
			}
			if (assets[name].type == Loader) {
				var bmd : BitmapData = new BitmapData(assets[name].object.width, assets[name].object.height, true, 0x000000);
				bmd.draw(assets[name].object);
				
				var bitmap : Bitmap = new Bitmap(bmd);
				return bitmap;
			}
			return assets[name].object;
		}
	}

}