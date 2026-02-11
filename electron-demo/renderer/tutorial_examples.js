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
  }
];
