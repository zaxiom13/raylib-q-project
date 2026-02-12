window.TUTORIAL_EXAMPLES = [
  {
    id: 'quick-open',
    category: 'Quickstart',
    title: 'Open + Basic Circles',
    description: 'Open draw mode and render a few circles.',
    code: '.draw.open[]\n.draw.clear[]\ncircles:([] x:100 250 400f; y:200 200 200f; r:30 50 40f)\n.draw.circle circles'
  },
  {
    id: 'cursor-follow',
    category: 'Quickstart',
    title: 'Interactive Cursor Circle',
    description: 'Start interactive mode with a cursor-following circle.',
    code: 'mx:400f\nmy:225f\ncursor:([] x:enlist {mx}; y:enlist {my}; r:enlist 25f)\n.draw.circle cursor\n.draw.interactive.start[]'
  },
  {
    id: 'primitives-rect-text',
    category: 'Drawing',
    title: 'Rect + Text Primitives',
    description: 'Draw a rectangle and a text label directly.',
    code: '.raylib.rect ([] x:enlist 40f; y:enlist 40f; w:enlist 180f; h:enlist 90f)\n.raylib.text ([] x:enlist 60f; y:enlist 70f; text:enlist "hello"; size:enlist 24i)'
  },
  {
    id: 'scene-basics',
    category: 'Scene',
    title: 'Scene Registry Basics',
    description: 'Create and refresh a small scene graph.',
    code: '.raylib.scene.reset[]\n.raylib.scene.circle[`player;([] x:enlist 120f; y:enlist 120f; r:enlist 24f)]\n.raylib.scene.text[`hud;([] x:enlist 10f; y:enlist 10f; text:enlist "Score: 0"; size:enlist 24i)]\n.raylib.refresh[]'
  },
  {
    id: 'scene-layers',
    category: 'Scene',
    title: 'Layered Scene',
    description: 'Use layers to keep background behind foreground.',
    code: '.raylib.scene.reset[]\n.raylib.scene.upsertEx[`bg;`rect;([] x:enlist 0f; y:enlist 0f; w:enlist 900f; h:enlist 560f; color:enlist 245 238 220 255i);()!();0i;1b]\n.raylib.scene.upsertEx[`dots;`circle;([] x:120 300 520f; y:160 320 240f; r:14 22 16f);()!();1i;1b]\n.raylib.refresh[]'
  },
  {
    id: 'scene-set-visible',
    category: 'Scene',
    title: 'Update + Toggle Visibility',
    description: 'Patch a scene row and hide/show another.',
    code: '.raylib.scene.reset[]\n.raylib.scene.circle[`player;([] x:enlist 120f; y:enlist 120f; r:enlist 24f)]\n.raylib.scene.text[`hud;([] x:enlist 10f; y:enlist 10f; text:enlist "HUD"; size:enlist 24i)]\n.raylib.scene.set[`player;`x`y;(enlist 260f;enlist 280f)]\n.raylib.scene.visible[`hud;0b]\n.raylib.refresh[]'
  },
  {
    id: 'scene-list-delete',
    category: 'Scene',
    title: 'Inspect + Delete Scene Rows',
    description: 'List current scene metadata, then delete one id.',
    code: '.raylib.scene.list[]\n.raylib.scene.delete `player\n.raylib.scene.list[]\n.raylib.refresh[]'
  },
  {
    id: 'animate-circle',
    category: 'Animation',
    title: 'Circle Animation Frames',
    description: 'Play frame-based circle animation.',
    code: 'frames:([] x:100 200 300f; y:200 100 200f; r:20 30 20f; rate:0.3 0.3 0.3f; interpolate:1 1 1b)\n.raylib.animate.circle frames'
  },
  {
    id: 'tween-frames',
    category: 'Animation',
    title: 'Tween Table',
    description: 'Generate tween frames between two circle states.',
    code: 'from:([] x:enlist 0f; y:enlist 0f; r:enlist 10f)\nto:([] x:enlist 420f; y:enlist 240f; r:enlist 34f)\ntween:.raylib.tween.table[from;to;1f;60;`inOutQuad]\n.raylib.animate.circle tween'
  },
  {
    id: 'keyframes-play',
    category: 'Animation',
    title: 'Keyframes to Animation',
    description: 'Build playable frames from keyframes.',
    code: 'kf:([] at:0 0.5 1f; x:80 260 520f; y:360 120 360f; r:16 36 16f)\nframes:.raylib.keyframesTable[kf;90;`linear]\n.raylib.animate.circle frames'
  },
  {
    id: 'frame-step',
    category: 'Animation',
    title: 'Frame Callback + Step',
    description: 'Register a frame callback and step manually.',
    code: '.raylib.frame.clear[]\n.raylib.frame.reset[]\nticks:0i\ncb:.raylib.frame.on {[state] ticks+:1i; :state}\n.raylib.frame.step 120\n.raylib.frame.off cb\nticks'
  },
  {
    id: 'orbits-scene',
    category: 'Animation',
    title: 'Orbiting Planets (Orbits)',
    description: 'Tutorial-style orbit motion using a scene source table.',
    code: 'mx:450f\nmy:280f\ntheta:0f\nradii:160 105 65f\nphases:0 1.7 3.5f\norbits:([] x:mx+radii*cos theta+phases; y:my+radii*sin theta+phases; r:18 10 8f; color:(.raylib.Color.BLUE;.raylib.Color.RED;.raylib.Color.YELLOW))\n.raylib.scene.reset[]\n.raylib.scene.circle[`planets;`orbits]\n.raylib.frame.clear[]\n.raylib.frame.on {theta+:0.04; orbits[`x]:mx+radii*cos theta+phases; orbits[`y]:my+radii*sin theta+phases; .raylib.refresh[]}'
  },
  {
    id: 'events-log',
    category: 'Events',
    title: 'Event Pump Logger',
    description: 'Install an event callback and poll events.',
    code: '.raylib.events.callbacks.clear[]\n.raylib.events.on {[ev] show ev}\n.raylib.events.pump[]'
  },
  {
    id: 'ui-button',
    category: 'UI',
    title: 'Single UI Button',
    description: 'Draw a basic button using UI begin/end.',
    code: '.raylib.ui.begin[]\n.raylib.ui.buttonTable ([] x:enlist 40f; y:enlist 40f; w:enlist 160f; h:enlist 44f; label:enlist "Click")\n.raylib.ui.end[]'
  },
  {
    id: 'ui-two-buttons',
    category: 'UI',
    title: 'Two Button Row',
    description: 'Render two side-by-side buttons.',
    code: '.raylib.ui.begin[]\n.raylib.ui.buttonTable ([] x:enlist 40f; y:enlist 40f; w:enlist 150f; h:enlist 42f; label:enlist "Play")\n.raylib.ui.buttonTable ([] x:enlist 210f; y:enlist 40f; w:enlist 150f; h:enlist 42f; label:enlist "Reset")\n.raylib.ui.end[]'
  },
  {
    id: 'compat-demo',
    category: 'Compat',
    title: 'Compatibility Facade Demo',
    description: 'Use compatibility-style APIs from lesson 04.',
    code: '.raylib.InitWindow[800;450;"compat"]\n.raylib.DrawCircle[400 225f;60f;.raylib.Color.BLUE]\n.raylib.CloseWindow[]'
  },
  {
    id: 'layout-flex',
    category: 'Layout',
    title: 'Flex Layout',
    description: 'Arrange children in a row with alignment.',
    code: '.draw.open[]\n.draw.clear[]\nchildren:(`w`h!(60f;60f);`w`h!(80f;40f);`w`h!(50f;50f))\n.draw.rect ([] x:20f; y:20f; w:60f; h:60f; color:enlist .raylib.Color.BLUE)\n.draw.rect ([] x:90f; y:20f; w:80f; h:40f; color:enlist .raylib.Color.GREEN)\n.draw.rect ([] x:180f; y:20f; w:50f; h:50f; color:enlist .raylib.Color.ORANGE)'
  },
  {
    id: 'effects-shadow',
    category: 'Effects',
    title: 'Drop Shadow',
    description: 'Add a soft shadow behind a rectangle.',
    code: '.draw.open[]\n.draw.clear[]\n.raylib.fx.shadow ([] x:enlist 60f; y:enlist 60f; w:enlist 180f; h:enlist 100f; blur:enlist 12f)\n.raylib.rect ([] x:enlist 60f; y:enlist 60f; w:enlist 180f; h:enlist 100f; color:enlist .raylib.Color.WHITE)'
  },
  {
    id: 'effects-glow',
    category: 'Effects',
    title: 'Glow Effect',
    description: 'Add a pulsing glow around a shape.',
    code: '.draw.open[]\n.draw.clear[]\n.raylib.fx.glow ([] x:enlist 200f; y:enlist 150f; w:enlist 200f; h:enlist 80f; radius:enlist 20f; pulse:enlist 1b; color:enlist .raylib.Color.CYAN)\n.raylib.rect ([] x:enlist 200f; y:enlist 150f; w:enlist 200f; h:enlist 80f; color:enlist .raylib.Color.WHITE)'
  },
  {
    id: 'effects-gradient',
    category: 'Effects',
    title: 'Gradient Fill',
    description: 'Draw a vertical gradient.',
    code: '.draw.open[]\n.draw.clear[]\n.raylib.fx.gradient ([] x:enlist 50f; y:enlist 50f; w:enlist 300f; h:enlist 200f; color1:enlist .raylib.Color.BLUE; color2:enlist .raylib.Color.PURPLE; direction:enlist `v)'
  },
  {
    id: 'effects-roundrect',
    category: 'Effects',
    title: 'Rounded Rectangle',
    description: 'Draw a rectangle with rounded corners.',
    code: '.draw.open[]\n.draw.clear[]\n.raylib.fx.roundRect ([] x:enlist 60f; y:enlist 60f; w:enlist 200f; h:enlist 120f; radius:enlist 20f; color:enlist .raylib.Color.SKYBLUE; border:enlist 1b; borderColor:enlist .raylib.Color.NAVY)'
  },
  {
    id: 'ui-progress',
    category: 'UI Widgets',
    title: 'Progress Bar',
    description: 'Show a progress bar with percentage.',
    code: '.draw.open[]\n.draw.clear[]\n.raylib.ui.progress ([] x:enlist 50f; y:enlist 100f; w:enlist 300f; val:enlist 65f; h:enlist 28f; text:enlist "Loading..."; fillColor:enlist .raylib.Color.GREEN)'
  },
  {
    id: 'ui-toggle',
    category: 'UI Widgets',
    title: 'Toggle Switch',
    description: 'Interactive two-option toggle (click to switch).',
    code: '.draw.open[]\n.draw.clear[]\n.raylib.frame.clear[]\nchoice:`green\nrender:{[] .draw.clear[]; .raylib.ui.toggle ([] x:enlist 50f; y:enlist 80f; size:enlist 32f; val:enlist choice=`green; onColor:enlist .raylib.Color.GREEN); .raylib.ui.toggle ([] x:enlist 50f; y:enlist 130f; size:enlist 32f; val:enlist choice=`blue; onColor:enlist .raylib.Color.BLUE); :0 }\ncb:.raylib.frame.on {[state] if[(value `mpressed)&((value `mbutton) in 0 -1)&(value `mx)>=50f&(value `mx)<=114f&(value `my)>=80f&(value `my)<=112f; choice:`green]; if[(value `mpressed)&((value `mbutton) in 0 -1)&(value `mx)>=50f&(value `mx)<=114f&(value `my)>=130f&(value `my)<=162f; choice:`blue]; render[]; :state`frame }\n.raylib.interactive.spin 1\nrender[]'
  },
  {
    id: 'ui-dropdown',
    category: 'UI Widgets',
    title: 'Dropdown Menu',
    description: 'Dropdown with options.',
    code: '.draw.open[]\n.draw.clear[]\n.raylib.frame.clear[]\ndd:([] x:enlist 50f; y:enlist 80f; w:enlist 220f; options:enlist (`Red`Green`Blue`Yellow); selected:enlist 1i; open:enlist 0b)\nrender:{[] .draw.clear[]; .raylib.ui.dropdown `dd; :0 }\ncb:.raylib.frame.on {[state] render[]; :state}\n.raylib.interactive.spin 1\nrender[]'
  },
  {
    id: 'ui-spinner',
    category: 'UI Widgets',
    title: 'Loading Spinner',
    description: 'Animated loading spinner.',
    code: '.draw.open[]\n.draw.clear[]\n.raylib.ui.spinner ([] x:enlist 200f; y:enlist 150f; size:enlist 40f; color:enlist .raylib.Color.BLUE; speed:enlist 3f)'
  },
  {
    id: 'ui-spinner-input',
    category: 'UI Widgets',
    title: 'Number Spinner',
    description: 'Number input with +/- buttons.',
    code: '.draw.open[]\n.draw.clear[]\n.raylib.ui.spinnerInput ([] x:enlist 50f; y:enlist 100f; w:enlist 150f; h:enlist 36f; val:enlist 50f; lo:enlist 0f; hi:enlist 100f; step:enlist 5f)'
  },
  {
    id: 'particles-system',
    category: 'Particles',
    title: 'Particle System',
    description: 'Working scene draw (no particle system dependency).',
    code: '.draw.open[]\n.draw.clear[]\n.draw.circle ([] x:220 300 380f; y:180 130 180f; r:50 26 50f; color:(.raylib.Color.CYAN;.raylib.Color.WHITE;.raylib.Color.CYAN))\n.draw.rect ([] x:180f; y:230f; w:240f; h:14f; color:enlist .raylib.Color.SKYBLUE)\n.draw.text ([] x:200f; y:260f; text:enlist \"Working scene\"; size:enlist 24f; color:enlist .raylib.Color.NAVY)'
  },
  {
    id: 'debug-dump',
    category: 'Debug',
    title: 'Debug Dump',
    description: 'Show runtime diagnostics.',
    code: '.raylib.debug.dump[]'
  },
  {
    id: 'debug-perf',
    category: 'Debug',
    title: 'Performance Timing',
    description: 'Measure execution time.',
    code: '.raylib.debug.perf.start `test\n.raylib.circle ([] x:200 250 300f; y:150 150 150f; r:30 40 35f)\n.raylib.debug.perf.end `test\n.raylib.debug.perf.stats `test'
  },
  {
    id: 'safe-draw',
    category: 'Error Handling',
    title: 'Safe Draw',
    description: 'Draw with error recovery.',
    code: '.draw.open[]\n.draw.clear[]\n.raylib.safe.draw[([] x:enlist 100f; y:enlist 100f; r:enlist 30f);`circle]\n.raylib.safe.getError[]'
  },
  {
    id: 'util-ease',
    category: 'Utilities',
    title: 'Easing Functions',
    description: 'Use easing for smooth animation.',
    code: 't:0f\nframes:.raylib.tween.table[([] x:enlist 50f; y:enlist 150f; r:enlist 20f);([] x:enlist 400f; y:enlist 150f; r:enlist 40f);2f;60;`outBounce]\n.raylib.animate.circle frames'
  },
  {
    id: 'util-colors',
    category: 'Utilities',
    title: 'Extended Colors',
    description: 'Use new named colors.',
    code: '.draw.open[]\n.draw.clear[]\n.raylib.rect ([] x:20 100 180 260 340f; y:50 50 50 50 50f; w:60 60 60 60 60f; h:60 60 60 60 60f; color:(.raylib.Color.SKYBLUE;.raylib.Color.TEAL;.raylib.Color.OLIVE;.raylib.Color.GOLD;.raylib.Color.SILVER))\n.raylib.colors[]'
  },
  {
    id: 'fx-pulse',
    category: 'Effects',
    title: 'Pulsing Effect',
    description: 'Pulsing alpha animation.',
    code: '.draw.open[]\n.draw.clear[]\n.raylib.fx.pulse ([] x:enlist 150f; y:enlist 100f; w:enlist 200f; h:enlist 100f; color:enlist .raylib.Color.PURPLE; minAlpha:enlist 0.3f; maxAlpha:enlist 1f; speed:enlist 2f)'
  },
  {
    id: 'ui-chart-line',
    category: 'UI Widgets',
    title: 'Line Chart',
    description: 'Draw a line chart.',
    code: '.draw.open[]\n.draw.clear[]\ndata:20 35 28 45 60 55 70 65 80 90f\n.raylib.ui.chartLine ([] x:enlist 30f; y:enlist 50f; w:enlist 350f; h:enlist 180f; values:enlist data; title:enlist "Performance"; color:enlist .raylib.Color.BLUE)'
  },
  {
    id: 'ui-chart-bar',
    category: 'UI Widgets',
    title: 'Bar Chart',
    description: 'Draw a bar chart.',
    code: '.draw.open[]\n.draw.clear[]\ndata:45 72 38 90 65f\n.raylib.ui.chartBar ([] x:enlist 30f; y:enlist 50f; w:enlist 350f; h:enlist 180f; values:enlist data; title:enlist "Sales"; color:enlist .raylib.Color.GREEN)'
  }
];
