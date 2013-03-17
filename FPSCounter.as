package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	public class FPSCounter extends Sprite
	{
		private var
			_time:int,
			_frameTime:Number,
			_frames:uint,
			_fps:Number,
			
			_fpsText:TextField;
		
		private const
			NUM_FRAMES:uint = 16;
		
		public function get fps():Number
		{
			return _fps;
		}
		
		public function FPSCounter()
		{
			super();
			
			_time = getTimer();
			
			_fps = 0;
			
			_fpsText = new TextField();
			_fpsText.selectable = false;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = 0xffffff;
			textFormat.font = "FPS Font";
			textFormat.bold = true;

			_fpsText.defaultTextFormat = textFormat;
			_fpsText.filters = [new GlowFilter(0, 1, 4, 4, 100)];
			 
			addChild(_fpsText);
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		public function enterFrameHandler( e:Event ):void
		{
			var dt:uint = getTimer() - _time;
			_time += dt;
			
			_frameTime += dt/1000;
										
			if(++_frames == NUM_FRAMES)
			{
				_fps = _frames / _frameTime;
				_frameTime = 0;
				_frames = 0;
			}
			
			_fpsText.text = "FPS: " + uint(_fps*100)/100;			
		}
		
	}
}