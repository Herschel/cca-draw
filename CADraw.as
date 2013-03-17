package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;

	public class CADraw extends Sprite
	{
		private var
			_worldPrev:Array,
			_world:Array,
			
			_threshold:uint,
			
			_tickFunc:Function,
			
			_bitmap:Bitmap,
			_frameBuffer:BitmapData,
			
			_baseColors:Array,
			_colors:Array,
			
			_worldSize:uint,
			_worldWidth:uint,
			_worldHeight:uint,
			_worldMask:uint,
			
			_stateSize:uint,
			_numStates:uint,
			_stateMask:uint,
			
			_doesDrawSpectrum:Boolean=true;
			
			
		public static const
			
			CA_NEUMANN:uint = 0,
			CA_MOORE:uint = 1,
			CA_DIAGONAL:uint = 2,
			CA_DIAMOND:uint = 3,
			CA_SKEW:uint = 4;
			
		public function CADraw(tickFunc:uint, worldSize:uint, stateSize:uint, threshold:uint, colors:Array):void
		{
			_worldSize = worldSize;
			_worldWidth = _worldHeight = 1<<worldSize;
			_worldMask = _worldWidth-1;

			initWorld();
			initDisplay();

			_baseColors = colors;
			_stateSize = stateSize;
			_numStates = 1<<stateSize;
			_stateMask = _numStates-1;
			_threshold = threshold;
			this.tickFunc = tickFunc;
			
			initColors();
			 
			reset();
				
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
			
			_threshold = 1;
		}
		
		private function initWorld():void
		{
			_worldPrev = new Array(_worldWidth);
			_world = new Array(_worldWidth);
			
			for(var i:uint=0; i<_worldWidth; i++)
			{
				_worldPrev[i] = new Array(_worldHeight);
				_world[i] = new Array(_worldHeight);
			}	
		}
		
		
		private function initDisplay():void
		{
			_frameBuffer = new BitmapData( _worldWidth, _worldHeight, false, 0xff000000);
			 
			_bitmap = new Bitmap(_frameBuffer);
			
			addChild( _bitmap );
			
		}
		
		private function initColors():void
		{
			_colors = new Array(_numStates);
			
			var
				color0:Array, color1:Array, finalColor:Array,
				colorIndex:Number, t:Number;
			
			finalColor = new Array(3);
			for(var i:uint=0; i<_numStates; i++)
			{
				colorIndex = (_baseColors.length-1) * i/(_numStates-1);
				
				color0 = _baseColors[ uint(colorIndex) ];
				if( colorIndex<_baseColors.length-1 )
					color1 = _baseColors[ uint(colorIndex)+1 ];
				else 
					color1 = color0;
					
				t = colorIndex - uint(colorIndex);
				finalColor[0] = uint( .5 + (color0[0] + (color1[0]-color0[0])*t) );
				finalColor[1] = uint( .5 + (color0[1] + (color1[1]-color0[1])*t) );
				finalColor[2] = uint( .5 + (color0[2] + (color1[2]-color0[2])*t) );
				
				_colors[i] = finalColor[0]<<16 | finalColor[1]<<8 | finalColor[2];
			}
		}
		
		public function reset():void
		{
			
			for(var i:uint=0; i<_worldWidth; i++)
				for(var j:uint=0; j<_worldHeight; j++)
					_world[i][j] = uint(Math.random()*_numStates);
		}
		
		public function set tickFunc(n:uint):void
		{
			switch(n)
			{
				default:
				case CA_NEUMANN:	_tickFunc = tickVonNeumann;	break;
				case CA_MOORE:		_tickFunc = tickMoore;		break;
				case CA_DIAGONAL:	_tickFunc = tickDiagonal;	break;
				case CA_DIAMOND:	_tickFunc = tickDiamond;	break;
				case CA_SKEW:		_tickFunc = tickSkew;		break;
			}
		}
		
		private function enterFrameHandler(e:Event):void
		{
			_tickFunc();
			render();
		}
		
		private function tickVonNeumann():void
		{
			var temp:Array = _worldPrev;
			_worldPrev = _world;
			_world = temp;
			
			var i:uint, j:uint,  next:uint, count:uint;
			for(i=0; i<_worldWidth; i++)
				for(j=0; j<_worldHeight; j++)
				{
					next = (_worldPrev[i][j]+1)&_stateMask;
					
					count = 
						uint(_worldPrev[i][(j-1)&_worldMask] == next) +
						uint(_worldPrev[i][(j+1)&_worldMask] == next) +
						uint(_worldPrev[(i-1)&_worldMask][j] == next) +
						uint(_worldPrev[(i+1)&_worldMask][j] == next);
					
					if(count >= _threshold)
						_world[i][j] = next;					
					else
						_world[i][j] = _worldPrev[i][j];
				}
				
		}
		
		private function tickDiagonal():void
		{
			var temp:Array = _worldPrev;
			_worldPrev = _world;
			_world = temp;
			
			var i:uint, j:uint,  next:uint, count:uint;
			for(i=0; i<_worldWidth; i++)
				for(j=0; j<_worldHeight; j++)
				{
					next = (_worldPrev[i][j]+1)&_stateMask;

					count = 
						uint(_worldPrev[(i-1)&_worldMask][(j-1)&_worldMask] == next) +
						uint(_worldPrev[(i-1)&_worldMask][(j+1)&_worldMask] == next) +
						uint(_worldPrev[(i+1)&_worldMask][(j-1)&_worldMask] == next) +
						uint(_worldPrev[(i+1)&_worldMask][(j+1)&_worldMask] == next);
					
					if(count >= _threshold)
						_world[i][j] = next;					
					else
						_world[i][j] = _worldPrev[i][j];
				}
				
		}
		
		private function tickMoore():void
		{
			var temp:Array = _worldPrev;
			_worldPrev = _world;
			_world = temp;
			
			var i:uint, j:uint,  next:uint, count:uint;
			for(i=0; i<_worldWidth; i++)
				for(j=0; j<_worldHeight; j++)
				{
					next = (_worldPrev[i][j]+1)&_stateMask;
					
					count = 
						uint(_worldPrev[i][(j-1)&_worldMask] == next) +
						uint(_worldPrev[i][(j+1)&_worldMask] == next) +
						uint(_worldPrev[(i-1)&_worldMask][j] == next) +
						uint(_worldPrev[(i+1)&_worldMask][j] == next) +
						uint(_worldPrev[(i-1)&_worldMask][(j-1)&_worldMask] == next) +
						uint(_worldPrev[(i-1)&_worldMask][(j+1)&_worldMask] == next) +
						uint(_worldPrev[(i+1)&_worldMask][(j-1)&_worldMask] == next) +
						uint(_worldPrev[(i+1)&_worldMask][(j+1)&_worldMask] == next);
					
					if(count >= _threshold)
						_world[i][j] = next;					
					else
						_world[i][j] = _worldPrev[i][j];
				}
				
		}
		
		private function tickDiamond():void
		{
			var temp:Array = _worldPrev;
			_worldPrev = _world;
			_world = temp;
			
			var i:uint, j:uint,  next:uint, count:uint;
			for(i=0; i<_worldWidth; i++)
				for(j=0; j<_worldHeight; j++)
				{
					next = (_worldPrev[i][j]+1)&_stateMask;

					count = 
						uint(_worldPrev[i][(j-1)&_worldMask] == next) +
						uint(_worldPrev[i][(j+1)&_worldMask] == next) +
						uint(_worldPrev[(i-1)&_worldMask][j] == next) +
						uint(_worldPrev[(i+1)&_worldMask][j] == next) +
						uint(_worldPrev[(i-1)&_worldMask][(j-1)&_worldMask] == next) +
						uint(_worldPrev[(i-1)&_worldMask][(j+1)&_worldMask] == next) +
						uint(_worldPrev[(i+1)&_worldMask][(j-1)&_worldMask] == next) +
						uint(_worldPrev[(i+1)&_worldMask][(j+1)&_worldMask] == next) +
						uint(_worldPrev[i][(j-2)&_worldMask] == next) +
						uint(_worldPrev[i][(j+2)&_worldMask] == next) +
						uint(_worldPrev[(i-2)&_worldMask][j] == next) +
						uint(_worldPrev[(i+2)&_worldMask][j] == next);
					
					if(count >= _threshold)
						_world[i][j] = next;					
					else
						_world[i][j] = _worldPrev[i][j];
				}
				
		}
		
		private function tickSkew():void
		{
			var temp:Array = _worldPrev;
			_worldPrev = _world;
			_world = temp;
			
			var i:uint, j:uint,  next:uint, count:uint;
			for(i=0; i<_worldWidth; i++)
				for(j=0; j<_worldHeight; j++)
				{
					next = (_worldPrev[i][j]+1)&_stateMask;
					
					count = 
						uint(_worldPrev[(i-1)&_worldMask][(j-1)&_worldMask] == next) +
						uint(_worldPrev[i][(j-1)&_worldMask] == next) +
						uint(_worldPrev[(i+1)&_worldMask][(j+1)&_worldMask] == next);
					
					if(count >= _threshold)
						_world[i][j] = next;					
					else
						_world[i][j] = _worldPrev[i][j];
				}
				
		}
		
		private function render():void
		{
			var i:uint, j:uint;
			
			_frameBuffer.lock();
			
			for(i=0; i<_worldWidth; i++)
				for(j=0; j<_worldHeight; j++)
					_frameBuffer.setPixel(i, j, _colors[_world[i][j]] );
				
			_frameBuffer.unlock();		
		}
		
		public function dispose():void
		{
			_bitmap.bitmapData = null;
			_bitmap = null;
			_frameBuffer = null;
			
			removeEventListener( Event.ENTER_FRAME, enterFrameHandler );
			
			_world = null;
			_worldPrev = null;
			_colors = null;
			_baseColors = null;
		}
		
	}
}
