package Graphics.FX
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	public class MotionBlur
	{
		[Embed(source="/../Resources/Filters/MotionBlur.pbj", mimeType="application/octet-stream")]
		private var pbMotionBlur : Class;
		
		private var objects : Array = [];
		
		public function MotionBlur() 
		{
			
		}
		
		public function get objectArray():Array { return objects;  };
		
		public function AddObject(object : DisplayObject) : void{
			var mbObject : Object = {};
			mbObject.lastX = object.x;
			mbObject.lastY = object.y;
			mbObject.object = object;
			mbObject.amount = 0;
			mbObject.angle = 0;
			
			var filter : FilterCollection = new FilterCollection();
			filter.ApplyFilters(mbObject.object);
			
			var fMotionBlur : String = filter.AddFilter(pbMotionBlur);
			filter.AddParameter(fMotionBlur, "amount", 0);
			filter.AddParameter(fMotionBlur, "angle", 0);
			
			mbObject.filter = filter;
			
			objects.push(mbObject);
		}
		
		public function Update() : void{
			for each (var obj : Object in objects){
				CalcMotion(obj);
			}			
		}
		
		private function CalcMotion(object : Object) : void{
			var deltaX:Number = object.object.x - object.lastX;
			var deltaY:Number = object.object.y - object.lastY;
			
			object.amount = Math.sqrt(deltaX * deltaX + deltaY * deltaY)/50;
			object.angle = Math.atan2(deltaY, deltaX);
			
			var data : Object = object.filter.GetData(object.filter.filterArray[0].shader.data.name);
			data.amount = object.amount;
			data.angle = object.angle;
			
			object.lastX = object.object.x;
			object.lastY = object.object.y;
		}

	}
}