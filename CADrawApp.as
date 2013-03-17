package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class CADrawApp extends Sprite
	{
		private var _CADrawer:CADraw;
		
		public function CADrawApp()
		{
			super();
					
			var fpsCounter:FPSCounter = new FPSCounter();			
			fpsCounter.x = 10;
			fpsCounter.y = stage.stageHeight - 20;
			addChild( fpsCounter );	
			
			respawnCA();
		}
		
		private const
			COOL_BASE_COLORS:Array =
				[
					[
						[0, 0, 0],
						[255, 255, 255]
					],
					[
						[ 180, 175, 145 ],
						[ 120, 119, 70 ],
						[ 64, 65, 30 ],
						[ 50, 51, 29 ],
						[ 192, 48, 0 ]
					],
					[
						[255,	0, 0],
						[255, 127, 0],
						[255, 255, 0],
						[0, 240, 0],
						[255, 0, 255],
						[0, 0, 255],
						[255, 0, 255]
					],
					[
						[28, 29, 33],
						[49, 53, 61],
						[68, 88, 120],
						[146, 205, 207],
						[238, 239, 247]
					],
					[
						[133, 219, 24],
						[205, 232, 85],
						[245, 246, 212],
						[167, 197, 32],
						[73, 63, 11]
					],
					[
						[46, 9, 39],
						[217, 0, 0],
						[255, 45, 0],
						[255, 140, 0],
						[4, 117, 111]
					],
					[
						[0, 0, 0],
						[10, 0, 0],
						[255, 0, 0],
						[0, 0, 0],
						[0, 10, 0],
						[0, 255, 0],
						[0, 0, 0],
						[0, 0, 10],
						[0, 0, 255]
					],
					[
						[245, 223, 229],
						[171, 154, 158],
						[135, 30, 49],
						[97, 14, 30],
						[66, 17, 27]
					],
					[
						[255, 255, 255],
						[78, 169, 160],
						[150, 149, 20],
						[254, 156, 3],
						[252, 222, 142]
					]
				],

			COOL_CONFIGS:Array =
				[
					[ CADraw.CA_NEUMANN, 4, 2 ],
					[ CADraw.CA_NEUMANN, 4, 1 ],
					[ CADraw.CA_NEUMANN, 3, 2 ],
					[ CADraw.CA_NEUMANN, 3, 1 ],
					[ CADraw.CA_NEUMANN, 2, 2 ],
				
					[ CADraw.CA_MOORE, 3, 1 ],
					[ CADraw.CA_MOORE, 3, 2 ],
					[ CADraw.CA_MOORE, 4, 1 ],
					[ CADraw.CA_MOORE, 4, 1 ],
					[ CADraw.CA_MOORE, 5, 1 ],
				
					[ CADraw.CA_DIAGONAL, 4, 3 ],
					[ CADraw.CA_DIAGONAL, 3, 2 ],
					[ CADraw.CA_DIAGONAL, 3, 1 ],
					[ CADraw.CA_DIAGONAL, 2, 2 ],
					
					[ CADraw.CA_DIAMOND, 4, 2 ],
					[ CADraw.CA_DIAMOND, 4, 3 ],
					[ CADraw.CA_DIAMOND, 5, 1 ],
					[ CADraw.CA_DIAMOND, 5, 2 ],

					[ CADraw.CA_SKEW, 3, 1 ],
					[ CADraw.CA_SKEW, 3, 2 ],
				];
				
		public function clickHandler( e:MouseEvent ):void
		{
			respawnCA();
		}
		
		private function respawnCA():void
		{
			if(_CADrawer)
			{
				_CADrawer.dispose();
				_CADrawer.removeEventListener( MouseEvent.CLICK, clickHandler );
				removeChild( _CADrawer );
			}
			
			var colors:Array = COOL_BASE_COLORS[ uint(Math.random()*COOL_BASE_COLORS.length) ];			
			var config:uint = uint( Math.random()*COOL_CONFIGS.length );
			
			_CADrawer = new CADraw( COOL_CONFIGS[config][0], 8, COOL_CONFIGS[config][1], COOL_CONFIGS[config][2], colors);
					
			_CADrawer.scaleX = stage.stageWidth / _CADrawer.width;
			_CADrawer.scaleY = stage.stageHeight / _CADrawer.height;
			
			_CADrawer.addEventListener( MouseEvent.CLICK, clickHandler );
			
			addChildAt(_CADrawer, 0);
		}

	}
}