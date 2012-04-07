package Graphics.FX
{
	import System.GameManager;
	
	import caurina.transitions.Equations;
	import caurina.transitions.Tweener;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	
	public class ShatterBitmap extends Sprite
	{
		private var bitmapData:BitmapData// With this we import the image from the library as BitmapData
		public var totalX:Number; // the number of pieces on rows
		public var totalY:Number; // the number of pieces on columns 
		public var pieceW:Number;  // calculating the width of each piece according to the total pieces
		public var pieceH:Number; // calculating the height of each piece according to the total pieces
		private var pieces:Array = new Array(); // Will hold all pieces of image as data
		private var container:Sprite = new Sprite(); // Container for the image
		public var broken:Boolean = false; // Boolean to check if the image is shattered
		public var numVertices:Number;
		
		public const gravity : Number = 2;
		
		public function get piecesArray() : Array{
			return pieces;
		}
		
		private function ShatterImage():void
		{
			//scaleX = scaleY = 1;
			pieceW = (bitmapData.width*this.parent.scaleX) / totalX;
			pieceH = (bitmapData.height*this.parent.scaleY) / totalY;
			
			for (var j:int = 0; j<totalX; j++)
			{
				for (var i:int = 0; i<totalY; i++)
				{
					var piece:MovieClip = new MovieClip(); // This will hold one piece of photo
					
					var vertices : Array = [];
					
					if(j==0  || i==0)
						vertices.push(new Point(i * pieceW, j * pieceH));
					else
						vertices.push(pieces[j * totalY + i - totalX - 1].vertices[3]);
					
					if(j==0)
						vertices.push(new Point(i * pieceW + pieceW, j * pieceH));
					else
						vertices.push(pieces[j * totalY + i - totalX].vertices[4]);
					
					var rx:Number = i==totalX-1 ? 0 : 1;
					var ry:Number = j==totalY-1 ? 0 : 1;
					
					//if(i==totalX-1||j==totalY-1)
					//	vertices.push(new Point(i * pieceW + pieceW + rx*(Math.random() * pieceW / 2 ), j * pieceH + ry*(Math.random() * pieceH / 2)));
					if(j==0)
						vertices.push(new Point(i * pieceW + pieceW + rx*(Math.random() * pieceW / 2 ), j * pieceH + ry*(Math.random() * pieceH / 2)));
					else
						vertices.push(pieces[j * totalY + i - totalX].vertices[3]);
						
					//if(i==totalX-1||j==totalY-1)
					//	vertices.push(new Point(i * pieceW + pieceW + rx*(Math.random() * pieceW/4 ), j * pieceH + pieceH + ry*(Math.random() * pieceH/4)));
					//else
						vertices.push(new Point(i * pieceW + pieceW + rx*(Math.random() * pieceW/4 ), j * pieceH + pieceH + ry*(Math.random() * pieceH/4)));
						
					vertices.push(new Point(i * pieceW + rx*(Math.random() * pieceW / 2 ), j * pieceH + pieceH + ry*(Math.random() * pieceH / 2)));	
					
					if(i == 0)
						vertices.push(new Point(i * pieceW, j * pieceH + pieceH));
					else
						vertices.push(pieces[j * totalY + i - 1].vertices[3]);
					
					if (i == 0) {
						vertices.push(new Point(i * pieceW, j * pieceH/2));
					} else {
						vertices.push(pieces[j * totalY + i - 1].vertices[2]);
					}
					
					/*for each(var v : Point in vertices){
						v.x += pieceW * (this.parent.scaleX-1);
						v.y += pieceH * (this.parent.scaleY-1);
					}*/

					piece.vertices = vertices;
					piece.matrixi = i;
					piece.matrixj = j;
					piece.piecew = pieceW;
					piece.pieceh = pieceH;
					
					var dmatrix : Matrix = new Matrix();
					dmatrix.scale(parent.scaleX, parent.scaleY);
					//parent.scaleX = parent.scaleY = 1;
					with(piece.graphics){
						beginBitmapFill(bitmapData, dmatrix, false, true);
						//beginFill(0xff00aa * Math.random(), 0.5);
						moveTo(vertices[0].x, vertices[0].y);
						
						lineTo(vertices[1].x, vertices[1].y);
						lineTo(vertices[2].x, vertices[2].y);
						lineTo(vertices[3].x, vertices[3].y);
						lineTo(vertices[4].x, vertices[4].y);
						lineTo(vertices[5].x, vertices[5].y);
						lineTo(vertices[6].x, vertices[6].y);
						lineTo(vertices[0].x, vertices[0].y);
						
						endFill();
					}
					//piece.addChild(bm);
					//container.addChild(piece);
					GameManager.level.middleLayer.addChild(piece);
					//trace(container.localToGlobal(new Point() ), container.x, container.y);
					piece.x += container.localToGlobal(new Point() ).x - GameManager.level.cameraOffsetX;
					piece.y += container.localToGlobal(new Point() ).y - GameManager.level.cameraOffsetY;
					//piece.x -= pieceW/2;
					//piece.y -= pieceH/2
					//piece.oX = piece.x = i * (pieceW + bm.width / 2);// * pieceW; // Setting the original X and Y of the image;
					//piece.oY = piece.y = j * (pieceH + bm.height / 2);// * pieceH;
					piece.x += i * pieceW;
					piece.y += j * pieceH;
					
					trace(piece.scaleX);
					
					var matrix:Matrix = new Matrix();
					matrix.translate( -(i*pieceW), -(j*pieceH));
					var s:Number = parent.scaleX;
					var ds:Number = 1-s;
					var nscale:Number = 0;//1+( (s*s)+(ds*ds) * (ds) ); 
					//matrix.scale(s, s);
					
					var bmd : BitmapData = new BitmapData(pieceW*1.5 + pieceW*nscale, pieceH*1.5 + pieceH*nscale, true, 0xFFFFFF);
					bmd.draw(piece, matrix);
					//var bm : Bitmap = new Bitmap(bmd, "always", false);
					//bm.x -= bm.width/2;
					//bm.y -= bm.height / 2;
					var nonClearRect:Rectangle = bmd.getColorBoundsRect(0xFF000000, 0x00000000, false);
					var area:int = nonClearRect.width*nonClearRect.height;
					trace(nonClearRect);
					if(area<=0)
						piece.empty = true;
					else
						piece.empty = false;
					
					pieces.push(piece); // Adding each piece to the array
					
					piece.graphics.clear();
					
					piece.graphics.beginBitmapFill(bmd,null, false);
					piece.graphics.drawRect(0,0,bmd.width,bmd.height);
					piece.graphics.endFill();		
					
					piece.broken = false;
					
				}
			}				
			
		}
		
		public function Update() : void {
		if (broken) {
				trace("Update");
				for each(var piece : MovieClip in piecesArray) {
					if (piece.alpha < 0 && piece.visible) {
						piece.visible = false;
					}
					if (!piece.broken || !piece.visible) continue;
					if (!piece.fallen) {
						piece.speedy = 1 * Math.random();
						piece.speedx = 10 * (Math.random() - 0.5);
						piece.jump = 10 + Math.random();
					}
					
					var randomx : Number = (Math.random() - 0.5) * 200 + 50;
					var finaly : Number =  height;
					var randr : Number =  Math.random() * 90;
					var randx : Number = Math.random() * 180;
					var randy : Number = Math.random() * 180;
					var tim : Number = Math.random() * 1;
					
					piece.fallen = true;
					piece.y += piece.speedy - piece.jump;
					piece.x += piece.speedx;
					piece.jump *= 0.7;
					piece.speedy *= gravity; 

					piece.rotationZ += Math.random()+(piece.speeedy+piece.speedx)*4;
					piece.rotationX += Math.random()+piece.speedx*4;
					piece.rotationY += Math.random()+piece.speedy*4;
					piece.alpha -= 0.05;
				}
			}	
		}
		
		public function Break() : void {
		if(!broken){	
			broken = true;
			ShatterImage();
			removeChildAt(0);
		}
		}
		
		public function ShatterBitmap(source:BitmapData, sizex:Number = 3)
		{
			var b : Bitmap = new Bitmap(source);
			addChild(b);
			if (sizex < 2 ) sizex = 2;
			
			addChild(container);
			
			container.cacheAsBitmap = true;
			bitmapData = source;
			totalX = sizex;
			totalY = sizex;
			
			pieceW = bitmapData.width / totalX;
			pieceH = bitmapData.height / totalY;
			//ShatterImage();
		}

	}
	
}