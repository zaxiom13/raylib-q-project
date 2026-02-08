system "t 0";
.z.ts:{[x]::};
\l raylib_q_init.q

failures:();

assertEq:{[name;actual;expected]
  if[not actual~expected;
    failures,:enlist (name,": expected=",string expected," actual=",string actual)];
  :1b
 };

origOpen:.raylib.open;
origTransportOpen:.raylib.transport.open;
origTransportClose:.raylib.transport.close;
origTransportSubmit:.raylib.transport.submit;
origTransportEventsPoll:.raylib.transport.events.poll;
origEnsureReady:.raylib._ensureReady;
origInteractiveStop:.raylib.interactive._stop;
origRunCmd:.raylib._runCmd;
origSendMsg:.raylib._sendMsg;
origEventsPath:.raylib.events.path;

/ open/close should be boolean + idempotent close path
openCalls:0i;
closeCalls:0i;
stopCalls:0i;
.raylib.transport.open:{openCalls+:1i; :1b};
.raylib.transport.close:{closeCalls+:1i; :1b};
.raylib.interactive._stop:{stopCalls+:1i; .raylib.interactive.active:0b; :0b};
.raylib._runtimeOpen:0b;
.raylib.scene._rows:([] id:enlist `tmp; kind:enlist `circle; src:enlist ([] x:enlist 1f; y:enlist 2f; r:enlist 3f); bindings:enlist ()!(); layer:enlist 0i; visible:enlist 1b; ord:enlist 7i);
.raylib.scene._nextOrd:8i;
assertEq["open bool";.raylib.open[];1b];
assertEq["open transport call count";openCalls;1i];
assertEq["open implicit scene reset rows";count .raylib.scene._rows;0];
assertEq["open implicit scene reset ord";.raylib.scene._nextOrd;0i];
.raylib.scene._rows:([] id:enlist `keep; kind:enlist `circle; src:enlist ([] x:enlist 4f; y:enlist 5f; r:enlist 6f); bindings:enlist ()!(); layer:enlist 0i; visible:enlist 1b; ord:enlist 0i);
assertEq["open second bool";.raylib.open[];1b];
assertEq["open second does not reset rows";count .raylib.scene._rows;1];
assertEq["close bool";.raylib.close[];1b];
assertEq["close transport call count";closeCalls;1i];
assertEq["close does not reopen";openCalls;1i];
assertEq["close marks runtime closed";.raylib._runtimeOpen;0b];
.raylib.interactive.active:1b;
assertEq["close active bool";.raylib.close[];1b];
assertEq["close active stop call count";stopCalls;1i];
assertEq["close active sets inactive";.raylib.interactive.active;0b];
assertEq["close active transport call count";closeCalls;2i];
assertEq["close inactive no extra stop";.raylib.close[];1b];
assertEq["close inactive stop unchanged";stopCalls;1i];

msgs:();
cmds:();
.raylib.open:{:0};
.raylib._runCmd:{[cmd] cmds,:enlist cmd; :0};
.raylib._sendMsg:{[msg] msgs,:enlist .raylib._cmdToText msg; :0};

/ start should open renderer
cmds:();
.raylib.start[];
assertEq["start run count";count cmds;0];

/ triangle default color + row count
msgs:();
tTri:([] x:enlist 10f; y:enlist 20f; r:enlist 30f);
nTri:.raylib.triangle tTri;
assertEq["triangle count";nTri;1];
assertEq["triangle msg";first msgs;"ADD_TRIANGLE 10 20 30 190 33 55 255"];

/ circle explicit color
msgs:();
tCircle:([] x:enlist 1f; y:enlist 2f; r:enlist 3f; color:enlist 1 2 3 4i);
nCircle:.raylib.circle tCircle;
assertEq["circle count";nCircle;1];
assertEq["circle msg";first msgs;"ADD_CIRCLE 1 2 3 1 2 3 4"];

/ generic draw dispatcher
msgs:();
nDrawGeneric:.raylib.draw[`circle;([] x:enlist 9f; y:enlist 8f; r:enlist 7f)];
assertEq["draw generic count";nDrawGeneric;1];
assertEq["draw generic msg";first msgs;"ADD_CIRCLE 9 8 7 0 121 241 255"];

/ circle alpha override
msgs:();
tCircleAlpha:([] x:enlist 1f; y:enlist 2f; r:enlist 3f; color:enlist 1 2 3 4i; alpha:enlist 200i);
.raylib.circle tCircleAlpha;
assertEq["circle alpha override";first msgs;"ADD_CIRCLE 1 2 3 1 2 3 200"];

/ square default color + schema
msgs:();
tSquare:([] x:enlist 10f; y:enlist 20f; r:enlist 5f);
nSquare:.raylib.square tSquare;
assertEq["square count";nSquare;1];
assertEq["square msg";first msgs;"ADD_SQUARE 10 20 5 255 161 0 255"];
msgs:();
nSquareExtra:.raylib.square ([] x:enlist 1f; y:enlist 2f; r:enlist 3f; foo:enlist 99i);
assertEq["square extra col ignored count";nSquareExtra;1];
assertEq["square extra col ignored draw";first msgs;"ADD_SQUARE 1 2 3 255 161 0 255"];

/ circle symbol refs resolve live globals
msgs:();
mx:111f;
my:222f;
tCircleFollow:([] x:enlist `mx; y:enlist `my; r:enlist 10f);
nCircleFollow:.raylib.circle tCircleFollow;
assertEq["circle symbol refs count";nCircleFollow;1];
assertEq["circle symbol refs msg";first msgs;"ADD_CIRCLE 111 222 10 0 121 241 255"];

/ rectangle missing required column
errRect:.[.raylib.rect;enlist ([] x:enlist 1f; y:enlist 2f; w:enlist 3f);{x}];
assertEq["rect cols error";errRect;"usage: .raylib.rect[t] where t is a table with x y w h (optional color,alpha,layer,rotation,stroke,fill)"];

/ extra metadata columns are ignored for draw primitives
msgs:();
nCircleExtraLoose:.raylib.circle ([] x:enlist 1f; y:enlist 2f; r:enlist 3f; foo:enlist 99i);
assertEq["circle extra col ignored count";nCircleExtraLoose;1];
assertEq["circle extra col ignored draw";first msgs;"ADD_CIRCLE 1 2 3 0 121 241 255"];

/ line thickness default
msgs:();
tLine:([] x1:enlist 0f; y1:enlist 0f; x2:enlist 5f; y2:enlist 8f);
.raylib.line tLine;
assertEq["line default thickness msg";first msgs;"ADD_LINE 0 0 5 8 1 0 0 0 255"];

/ point explicit color
msgs:();
tPoint:([] x:enlist 5f; y:enlist 6f; color:enlist 7 8 9 10i);
.raylib.point tPoint;
assertEq["point msg";first msgs;"ADD_PIXEL 5 6 7 8 9 10"];

/ text payload
msgs:();
tText:([] x:enlist 12f; y:enlist 15f; text:enlist "hello"; size:enlist 24i);
.raylib.text tText;
assertEq["text msg";first msgs;"ADD_TEXT 12 15 24 0 0 0 255 hello"];

/ pixels grayscale payload + scaling
msgs:();
tPixGray:([] pixels:enlist 10 20i; x:enlist 10f; y:enlist 20f; scale:enlist 2f);
nPixGray:.raylib.pixels tPixGray;
assertEq["pixels gray count";nPixGray;1];
assertEq["pixels gray msg count";count msgs;2];
assertEq["pixels gray msg1";msgs 0;"ADD_RECT 10 20 2 2 10 10 10 255"];
assertEq["pixels gray msg2";msgs 1;"ADD_RECT 12 20 2 2 20 20 20 255"];

/ pixels rgb payload + alpha modulation
msgs:();
tPixRgb:([] pixels:enlist 1 2 3i; x:enlist 0f; y:enlist 0f; alpha:enlist 128i);
nPixRgb:.raylib.pixels tPixRgb;
assertEq["pixels rgb count";nPixRgb;1];
assertEq["pixels rgb msg";first msgs;"ADD_RECT 0 0 1 1 1 2 3 128"];

/ pixels rgb inferred from length=6 (w=2,h=1)
msgs:();
tPixRgb6:([] pixels:enlist 10 60 180 255 60 30i; x:enlist 7f; y:enlist 9f);
nPixRgb6:.raylib.pixels tPixRgb6;
assertEq["pixels rgb6 count";nPixRgb6;1];
assertEq["pixels rgb6 msg count";count msgs;2];
assertEq["pixels rgb6 msg1";msgs 0;"ADD_RECT 7 9 1 1 10 60 180 255"];
assertEq["pixels rgb6 msg2";msgs 1;"ADD_RECT 8 9 1 1 255 60 30 255"];

/ pixels animated frames inferred from nested shape (2x2x2) with rate
msgs:();
tPixAnim:([] pixels:enlist ((1 2i;3 4i);(5 6i;7 8i)); x:enlist 0f; y:enlist 0f; rate:enlist 0.2f);
nPixAnim:.raylib.pixels tPixAnim;
assertEq["pixels anim count";nPixAnim;1];
assertEq["pixels anim msg count";count msgs;11];
assertEq["pixels anim clear";msgs 0;"ANIM_PIXELS_CLEAR"];
assertEq["pixels anim add first";msgs 1;"ANIM_PIXELS_ADD 0 0 0 1 1 1 1 1 255"];
assertEq["pixels anim add frame1 first";msgs 5;"ANIM_PIXELS_ADD 1 0 0 1 1 5 5 5 255"];
assertEq["pixels anim rate";msgs 9;"ANIM_PIXELS_RATE 200"];
assertEq["pixels anim play";msgs 10;"ANIM_PIXELS_PLAY"];

/ pixels animated RGB frames from list-of-vectors with rate
msgs:();
tPixAnimRgb:([] pixels:enlist (10 60 180 255 60 30i;255 0 0 0 255 0i); x:enlist 10f; y:enlist 20f; rate:enlist 0.1f);
nPixAnimRgb:.raylib.pixels tPixAnimRgb;
assertEq["pixels anim rgb count";nPixAnimRgb;1];
assertEq["pixels anim rgb clear";msgs 0;"ANIM_PIXELS_CLEAR"];
assertEq["pixels anim rgb add1";msgs 1;"ANIM_PIXELS_ADD 0 10 20 1 1 10 60 180 255"];
assertEq["pixels anim rgb add2";msgs 2;"ANIM_PIXELS_ADD 0 11 20 1 1 255 60 30 255"];
assertEq["pixels anim rgb add3";msgs 3;"ANIM_PIXELS_ADD 1 10 20 1 1 255 0 0 255"];
assertEq["pixels anim rgb add4";msgs 4;"ANIM_PIXELS_ADD 1 11 20 1 1 0 255 0 255"];
assertEq["pixels anim rgb rate";msgs 5;"ANIM_PIXELS_RATE 100"];
assertEq["pixels anim rgb play";msgs 6;"ANIM_PIXELS_PLAY"];

/ pixels grayscale matrix payload + destination size override
msgs:();
tPixMat:([] pixels:enlist (1 2i;3 4i); x:enlist 2f; y:enlist 4f; dw:enlist 4f; dh:enlist 2f);
nPixMat:.raylib.pixels tPixMat;
assertEq["pixels matrix count";nPixMat;1];
assertEq["pixels matrix msg count";count msgs;4];
assertEq["pixels matrix first";msgs 0;"ADD_RECT 2 4 2 1 1 1 1 255"];
assertEq["pixels matrix last";msgs 3;"ADD_RECT 4 5 2 1 4 4 4 255"];

/ pixels explicit w/h mismatch with inferred shape
errPixDims:.[.raylib.pixels;enlist ([] pixels:enlist 1 2 3i; x:enlist 0f; y:enlist 0f; w:enlist 2i; h:enlist 2i);{x}];
assertEq["pixels dims mismatch error";errPixDims;.raylib._pixelUsage];

/ fillColor helper
tBase:([] x:1 2 3f; y:4 5 6f; r:7 8 9f);
tRed:.raylib.fillColor[tBase;.raylib.Color.RED];
assertEq["fillColor rowcount";count tRed;count tBase];
assertEq["fillColor first";tRed[`color] 0;.raylib.Color.RED];
assertEq["fillColor last";tRed[`color] 2;.raylib.Color.RED];
assertEq["fillColor input unchanged";`color in cols tBase;0b];

/ fillColor mutate by symbol
tBlue:([] x:10 20f; y:30 40f; r:5 6f);
.raylib.fillColor[`tBlue;.raylib.Color.BLUE];
assertEq["fillColor mutate has color";`color in cols tBlue;1b];
assertEq["fillColor mutate first";tBlue[`color] 0;.raylib.Color.BLUE];

/ fillColor cycles multiple colors with take
tCycle:.raylib.fillColor[tBase;(.raylib.Color.RED;.raylib.Color.BLUE)];
assertEq["fillColor cycle row0";tCycle[`color] 0;.raylib.Color.RED];
assertEq["fillColor cycle row1";tCycle[`color] 1;.raylib.Color.BLUE];
assertEq["fillColor cycle row2";tCycle[`color] 2;.raylib.Color.RED];

/ help docs
docTri:.raylib.help `triangle;
assertEq["help triangle exact";docTri;"Draw triangles from table rows.\nusage: .raylib.triangle[t] where t has x y r (optional color,alpha,layer,rotation,stroke,fill)"];
docSquare:.raylib.help `square;
assertEq["help square exact";docSquare;"Draw squares from table rows (center/radius semantics).\nusage: .raylib.square[t] where t has x y r (optional color,alpha,layer,rotation,stroke,fill)"];
docShape:.raylib.help `shape.info;
assertEq["help shape exact";docShape;"Return the shape of a nested array.\nusage: .raylib.shape.info x"];
docShapePretty:.raylib.help `shape.pretty;
assertEq["help shape pretty exact";docShapePretty;"Return a Uiua-style pretty string with shape and boxed slices.\nusage: .raylib.shape.pretty x"];
docColors:.raylib.help `colors;
assertEq["help colors exact";docColors;"List named color constants with RGBA vectors.\nusage: .raylib.colors[]"];
docEasings:.raylib.help `easings;
assertEq["help easings exact";docEasings;"List available easing names accepted by tween/keyframes APIs.\nusage: .raylib.easings[]"];
docInteractiveStart:.raylib.help `interactive.start;
assertEq["help interactive start exact";docInteractiveStart;"Start safe timer-driven interactive loop (Esc stops).\nusage: .raylib.interactive.start[]"];
docSpin:.raylib.help `interactive.spin;
assertEq["help interactive spin exact";docSpin;"Alias of timer-driven interactive mode toggle.\nusage: .raylib.interactive.spin[0|1]"];
docSceneSet:.raylib.help `scene.set;
assertEq["help scene set exact";docSceneSet;"Patch one scene source table by id (partial column updates); auto-refreshes by default.\nusage: .raylib.scene.set[`id;`col or `col1`col2;value or (value1;value2)]"];
docSceneRefCircle:.raylib.help `scene.ref.circle;
assertEq["help scene ref circle exact";docSceneRefCircle;"Upsert circle scene source by symbol reference (id=src).\nusage: .raylib.scene.ref.circle[`srcSymbol]"];
docSceneSquare:.raylib.help `scene.square;
assertEq["help scene square exact";docSceneSquare;"Upsert square scene source.\nusage: .raylib.scene.square[`id;tableOrSymbol]"];
docEachFrame:.raylib.help `each.frame;
assertEq["help each frame exact";docEachFrame;"Register a no-arg callback to run each frame tick.\nusage: .raylib.each.frame[{...}]"];
docUnknown:.raylib.help `notAFunction;
assertEq["help unknown contains msg";0<count docUnknown ss "unknown function: notAFunction";1b];
assertEq["easings list";.raylib.easings[];`linear`inQuad`outQuad`inOutQuad];
assertEq["colors count";count .raylib.colors[];9];
assertEq["colors first name";(.raylib.colors[]`name) 0;`RED];
assertEq["colors first rgba";(.raylib.colors[]`rgba) 0;.raylib.Color.RED];
errColorVec:.[.raylib._rgba4;enlist 1 2i;{x}];
assertEq["rgba4 usage";errColorVec;.raylib._colorUsage];
assertEq["rgba4 named color";.raylib._rgba4 .raylib.Color.BLUE;.raylib.Color.BLUE];
assertEq["rgba4 clamp range";.raylib._rgba4 -10 20 300 999i;0 20 255 255i];

/ shape helper
shape3d:.raylib.shape.info 3 3 2#til 49;
assertEq["shape 3d";shape3d;3 3 2];
shapeVec:.raylib.shape.info til 5;
assertEq["shape vector";shapeVec;enlist 5];
shapeAtom:.raylib.shape.info 42;
assertEq["shape atom";shapeAtom;()];
shapePretty2d:.raylib.shape.pretty 2 3#til 6;
assertEq["shape pretty 2d has header";0<count shapePretty2d ss "shape 2 3";1b];
assertEq["shape pretty 2d has top border";0<count shapePretty2d ss "+";1b];
shapePretty4d:.raylib.shape.pretty 1 2 3 3#til 18;
assertEq["shape pretty 4d has slice tag";0<count shapePretty4d ss "slice";1b];
shapePretty5d:.raylib.shape.pretty 2 2 2 2 3#til 48;
assertEq["shape pretty 5d has layer";0<count shapePretty5d ss "layer";1b];
assertEq["shape pretty 5d has 3d slice idx";0<count shapePretty5d ss "slice";1b];

/ animate circle variable rate + interpolate
msgs:();
tAnimCircle:([] x:10 20f; y:30 40f; r:5 8f; rate:0.2 0.35f; interpolate:10b; color:(enlist 1 2 3 255i),enlist 5 6 7 255i);
nAnimCircle:.raylib.animate.circle tAnimCircle;
assertEq["animate circle count";nAnimCircle;2];
assertEq["animate circle msg count";count msgs;4];
assertEq["animate circle clear";msgs 0;"ANIM_CIRCLE_CLEAR"];
assertEq["animate circle add1";msgs 1;"ANIM_CIRCLE_ADD 10 30 5 1 2 3 255 200 1"];
assertEq["animate circle add2";msgs 2;"ANIM_CIRCLE_ADD 20 40 8 5 6 7 255 350 0"];
assertEq["animate circle play";msgs 3;"ANIM_CIRCLE_PLAY"];

/ animate alpha override
msgs:();
tAnimCircleAlpha:([] x:enlist 10f; y:enlist 30f; r:enlist 5f; rate:enlist 0.2f; color:enlist 1 2 3 255i; alpha:enlist 80i);
.raylib.animate.circle tAnimCircleAlpha;
assertEq["animate circle alpha";msgs 1;"ANIM_CIRCLE_ADD 10 30 5 1 2 3 80 200 0"];

/ animate triangle
msgs:();
tAnimTriangle:([] x:100 110f; y:120 130f; r:20 25f; rate:0.1 0.2f; interpolate:11b);
.raylib.animate.triangle tAnimTriangle;
assertEq["animate triangle clear";msgs 0;"ANIM_TRIANGLE_CLEAR"];
assertEq["animate triangle add1";msgs 1;"ANIM_TRIANGLE_ADD 100 120 20 190 33 55 255 100 1"];
assertEq["animate triangle play";msgs 3;"ANIM_TRIANGLE_PLAY"];

/ animate rect
msgs:();
tAnimRect:([] x:50 80f; y:60 70f; w:40 55f; h:30 45f; rate:0.15 0.25f; interpolate:01b; color:(enlist 9 8 7 255i),enlist 3 2 1 255i);
.raylib.animate.rect tAnimRect;
assertEq["animate rect add1";msgs 1;"ANIM_RECT_ADD 50 60 40 30 9 8 7 255 150 0"];
assertEq["animate rect add2";msgs 2;"ANIM_RECT_ADD 80 70 55 45 3 2 1 255 250 1"];
assertEq["animate rect play";msgs 3;"ANIM_RECT_PLAY"];

/ animate line (default thickness)
msgs:();
tAnimLine:([] x1:0 10f; y1:0 10f; x2:20 30f; y2:20 30f; rate:0.05 0.1f; interpolate:10b);
.raylib.animate.line tAnimLine;
assertEq["animate line add1";msgs 1;"ANIM_LINE_ADD 0 0 20 20 1 0 0 0 255 50 1"];
assertEq["animate line add2";msgs 2;"ANIM_LINE_ADD 10 10 30 30 1 0 0 0 255 100 0"];
assertEq["animate line play";msgs 3;"ANIM_LINE_PLAY"];

/ animate point
msgs:();
tAnimPoint:([] x:1 2f; y:3 4f; rate:0.12 0.34f; interpolate:10b; color:(enlist 11 12 13 255i),enlist 21 22 23 255i);
.raylib.animate.point tAnimPoint;
assertEq["animate point add1";msgs 1;"ANIM_POINT_ADD 1 3 11 12 13 255 120 1"];
assertEq["animate point add2";msgs 2;"ANIM_POINT_ADD 2 4 21 22 23 255 340 0"];
assertEq["animate point play";msgs 3;"ANIM_POINT_PLAY"];

/ animate text
msgs:();
tAnimText:([] x:200 250f; y:100 130f; text:("a";"b"); size:20 32i; rate:0.11 0.22f; interpolate:11b);
.raylib.animate.text tAnimText;
assertEq["animate text add1";msgs 1;"ANIM_TEXT_ADD 200 100 20 0 0 0 255 110 1 a"];
assertEq["animate text add2";msgs 2;"ANIM_TEXT_ADD 250 130 32 0 0 0 255 220 1 b"];
assertEq["animate text play";msgs 3;"ANIM_TEXT_PLAY"];

/ generic animate dispatcher + alias
msgs:();
nAnimGeneric:.raylib.anim[`point;([] x:1 2f; y:3 4f; rate:0.1 0.2f)];
assertEq["anim generic count";nAnimGeneric;2];
assertEq["anim generic clear";msgs 0;"ANIM_POINT_CLEAR"];
assertEq["anim generic play";msgs 3;"ANIM_POINT_PLAY"];
msgs:();
nAnimAlias:.raylib.animate.apply[`point;([] x:enlist 1f; y:enlist 2f; rate:enlist 0.1f)];
assertEq["anim alias count";nAnimAlias;1];
assertEq["anim alias clear";msgs 0;"ANIM_POINT_CLEAR"];

/ animate rate validation
errAnimRate:.[.raylib.animate.circle;enlist ([] x:enlist 1f; y:enlist 2f; r:enlist 3f; rate:enlist 0f);{x}];
assertEq["animate rate error";errAnimRate;"usage: .raylib.animate.circle[t] where t is a table with x y r rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), and each rate>0 (seconds)"];

/ animate stop (all tracks)
msgs:();
.raylib.animate.stop[];
assertEq["animate stop count";count msgs;7];
assertEq["animate stop circle";msgs 0;"ANIM_CIRCLE_STOP"];
assertEq["animate stop text";msgs 5;"ANIM_TEXT_STOP"];
assertEq["animate stop pixels";msgs 6;"ANIM_PIXELS_STOP"];

/ animate start (all tracks)
msgs:();
.raylib.animate.start[];
assertEq["animate start count";count msgs;7];
assertEq["animate start circle";msgs 0;"ANIM_CIRCLE_PLAY"];
assertEq["animate start text";msgs 5;"ANIM_TEXT_PLAY"];
assertEq["animate start pixels";msgs 6;"ANIM_PIXELS_PLAY"];

/ tween table
tweenFrom:([] x:enlist 0f; y:enlist 10i; label:enlist `a);
tweenTo:([] x:enlist 10f; y:enlist 20i; label:enlist `b);
tweenOut:.raylib.tween.table[tweenFrom;tweenTo;1f;4i;`linear];
assertEq["tween row count";count tweenOut;5];
assertEq["tween x mid";tweenOut[`x] 2;5f];
assertEq["tween y mid";tweenOut[`y] 2;15i];
assertEq["tween label first";tweenOut[`label] 0;`a];
assertEq["tween label last";tweenOut[`label] 4;`b];
assertEq["tween rate";tweenOut[`rate] 0;0.25f];
tweenColorFrom:([] x:enlist 100f; y:enlist 120f; r:enlist 12f; color:enlist 255 80 80 255i);
tweenColorTo:([] x:enlist 520f; y:enlist 320f; r:enlist 36f; color:enlist 80 180 255 255i);
tweenColorOut:.raylib.tween.table[tweenColorFrom;tweenColorTo;2f;4i;`linear];
assertEq["tween color row count";count tweenColorOut;5];
assertEq["tween color first";tweenColorOut[`color] 0;255 80 80 255i];
assertEq["tween color mid";tweenColorOut[`color] 2;167 130 167 255i];
assertEq["tween color last";tweenColorOut[`color] 4;80 180 255 255i];
errTweenEase:.[.raylib.tween.table;(tweenFrom;tweenTo;1f;4i;`quadratic);{x}];
assertEq["tween easing usage";errTweenEase;.raylib._easeUsage];

/ keyframes table
kf:([] at:0 1f; x:0 10f; y:10 20f);
kfOut:.raylib.keyframesTable[kf;4f;`linear];
assertEq["keyframes row count";count kfOut;5];
assertEq["keyframes first x";kfOut[`x] 0;0f];
assertEq["keyframes last x";kfOut[`x] 4;10f];
assertEq["keyframes first rate";kfOut[`rate] 0;0.25f];
kfLong:([] at:0 0.7 1.4 2.2f; x:80 220 450 600f; y:100 280 120 260f; r:10 22 16 30f);
kfLongOut:.raylib.keyframesTable[kfLong;60f;`linear];
assertEq["keyframes long row count threshold";(count kfLongOut)>120;1b];
assertEq["keyframes long first x";kfLongOut[`x] 0;80f];
assertEq["keyframes long last x";last kfLongOut[`x];600f];
assertEq["keyframes long first rate";kfLongOut[`rate] 0;1f%60f];
msgs:();
nKfAnim:.raylib.animate.circle kfLongOut;
assertEq["keyframes animate circle count";nKfAnim;count kfLongOut];
assertEq["keyframes animate circle clear";msgs 0;"ANIM_CIRCLE_CLEAR"];
assertEq["keyframes animate circle play";last msgs;"ANIM_CIRCLE_PLAY"];

/ fixed-step frame callbacks
.raylib.frame.clear[];
.raylib.frame.reset[];
.raylib.frame.setDt 0.1f;
tickFrames:();
cbId:.raylib.frame.on {[state] tickFrames,:enlist state`frame; :state`frame};
stStep:.raylib.frame.step 3;
assertEq["frame step frame";stStep`frame;3i];
assertEq["frame step time";stStep`time;0.3f];
assertEq["frame callback count";count tickFrames;3];
assertEq["frame callback last";last tickFrames;3i];
eachFrames:0i;
eachId:.raylib.each.frame {eachFrames+:1i};
.raylib.frame.step 2;
assertEq["each.frame callback count";eachFrames;2i];
assertEq["each.frame off removed";.raylib.frame.off eachId;1];
removedCb:.raylib.frame.off cbId;
assertEq["frame off removed";removedCb;1];
errFrameOff:.[.raylib.frame.off;enlist `bad;{x}];
assertEq["frame off usage";errFrameOff;"usage: .raylib.frame.off[id] or .raylib.frame.off[idList]"];
assertEq["frame clear resets";.raylib.frame.clear[];0];
assertEq["frame clear table rows";count .raylib.frame._callbacks;0];

/ run-mode emits sleep commands
cmds:();
.raylib.frame.run 2;
assertEq["frame run sleep count";count cmds;2];
assertEq["frame run sleep first";cmds 0;"sleep 0.1"];

/ frame dt validation
errFrameDt:.[.raylib.frame.setDt;enlist 0f;{x}];
assertEq["frame dt usage";errFrameDt;"usage: .raylib.frame.setDt[seconds] where seconds>0"];

/ type error shared across primitives
errType:.[.raylib.circle;enlist 42;{x}];
assertEq["type error";errType;"usage: .raylib.circle[t] where t is a table with x y r (optional color,alpha,layer,rotation,stroke,fill)"];
msgs:();
nCircleExtra:.raylib.circle ([] x:enlist 11f; y:enlist 12f; r:enlist 3f; rate:enlist 0.5f);
assertEq["circle extra cols allowed count";nCircleExtra;1];
assertEq["circle extra cols allowed draw";msgs 0;"ADD_CIRCLE 11 12 3 0 121 241 255"];

/ scene upsert + refresh from symbol source
.raylib.scene.reset[];
boundSpec:.raylib.bind[`sceneCircle;`x`y!({mx+1f};{my+2f})];
assertEq["bind tag";boundSpec 0;`raylib_bound];
assertEq["bind src";boundSpec 1;`sceneCircle];
assertEq["isBound true";.raylib._isBound boundSpec;1b];
assertEq["isBound false";.raylib._isBound `sceneCircle;0b];
sceneCircle:([] x:10 30f; y:20 40f; r:5 7f);
.raylib.scene.circle[`sceneCircleId;`sceneCircle];
msgs:();
nScene1:.raylib.refresh[];
assertEq["scene refresh count1";nScene1;2];
assertEq["scene refresh msg count1";count msgs;3];
assertEq["scene refresh msg clear1";msgs 0;"CLEAR"];
assertEq["scene refresh msg first";msgs 1;"ADD_CIRCLE 10 20 5 0 121 241 255"];
sceneCircle:1_ sceneCircle;
msgs:();
nScene2:.raylib.refresh[];
assertEq["scene refresh count2";nScene2;1];
assertEq["scene refresh msg count2";count msgs;2];
assertEq["scene refresh msg clear2";msgs 0;"CLEAR"];
assertEq["scene refresh msg updated";msgs 1;"ADD_CIRCLE 30 40 7 0 121 241 255"];
resolvedNoBindings:.raylib.scene._resolveWithBindings[sceneCircle;()!()];
assertEq["scene resolve empty bindings unchanged";resolvedNoBindings;sceneCircle];
sceneRefCircle:([] x:7 9f; y:8 10f; r:2 4f);
.raylib.scene.ref.circle[`sceneRefCircle];
sceneRefMeta:.raylib.scene.list[];
assertEq["scene ref id inferred";sceneRefMeta[`id] 1;`sceneRefCircle];
sceneRefCircle:1_ sceneRefCircle;
msgs:();
nSceneRef:.raylib.refresh[];
assertEq["scene ref refresh count";nSceneRef;2];
assertEq["scene ref updated draw";0<count (raze msgs) ss "ADD_CIRCLE 9 10 4";1b];
sceneRefWithRate:([] x:enlist 6f; y:enlist 7f; r:enlist 8f; rate:enlist 0.1f);
.raylib.scene.ref.circle[`sceneRefWithRate];
msgs:();
nSceneRefExtra:.raylib.refresh[];
assertEq["scene ref extra cols count positive";0<nSceneRefExtra;1b];
assertEq["scene ref extra cols draw";0<count (raze msgs) ss "ADD_CIRCLE 6 7 8";1b];
errSceneRefUsage:.[.raylib.scene.ref.circle;enlist ([] x:enlist 1f);{x}];
assertEq["scene ref usage";errSceneRefUsage;"usage: .raylib.scene.ref.<kind>[`srcSymbol]"];

/ scene layer ordering + visibility + delete
.raylib.scene.reset[];
sRect:([] x:enlist 1f; y:enlist 2f; w:enlist 3f; h:enlist 4f);
sPoint:([] x:enlist 8f; y:enlist 9f);
.raylib.scene.upsertEx[`rectA;`rect;sRect;()!();1i;1b];
.raylib.scene.upsertEx[`pointA;`point;sPoint;()!();0i;1b];
msgs:();
nLayer:.raylib.refresh[];
assertEq["scene layer count";nLayer;2];
assertEq["scene layer first";msgs 1;"ADD_PIXEL 8 9 0 0 0 255"];
assertEq["scene layer second";msgs 2;"ADD_RECT 1 2 3 4 255 161 0 255"];
.raylib.scene.visible[`pointA;0];
msgs:();
nVisible:.raylib.refresh[];
assertEq["scene visible count";nVisible;1];
assertEq["scene visible msg";msgs 1;"ADD_RECT 1 2 3 4 255 161 0 255"];
nDelete:.raylib.scene.delete `rectA;
assertEq["scene delete removed";nDelete;1];
msgs:();
nEmpty:.raylib.refresh[];
assertEq["scene empty count";nEmpty;0];
assertEq["scene empty msg count";count msgs;1];
assertEq["scene empty msg clear";msgs 0;"CLEAR"];

/ scene square center/r semantics
.raylib.scene.reset[];
sSquare:([] x:enlist 30f; y:enlist 40f; r:enlist 6f);
.raylib.scene.square[`sqA;sSquare];
msgs:();
nSquareScene:.raylib.refresh[];
assertEq["scene square count";nSquareScene;1];
assertEq["scene square msg";msgs 1;"ADD_SQUARE 30 40 6 255 161 0 255"];

/ scene clear layer
.raylib.scene.reset[];
.raylib.scene.circle[`c0;([] x:enlist 1f; y:enlist 1f; r:enlist 1f)];
.raylib.scene.upsertEx[`c2;`circle;([] x:enlist 2f; y:enlist 2f; r:enlist 2f);()!();2i;1b];
nClearLayer:.raylib.scene.clearLayer 0i;
assertEq["scene clearLayer removed";nClearLayer;1];
msgs:();
nAfterLayerClear:.raylib.refresh[];
assertEq["scene clearLayer count";nAfterLayerClear;1];
assertEq["scene clearLayer msg";msgs 1;"ADD_CIRCLE 2 2 2 0 121 241 255"];

/ scene set shorthand partial updates
.raylib.scene.reset[];
sceneSet:([] x:10 20f; y:30 40f; r:5 6f);
.raylib.scene.circle[`setSym;`sceneSet];
.raylib.scene.set[`setSym;`x;200 300f];
assertEq["scene set symbol src updated";sceneSet[`x];200 300f];
msgs:();
.raylib.refresh[];
assertEq["scene set symbol refresh first";msgs 1;"ADD_CIRCLE 200 30 5 0 121 241 255"];
.raylib.scene.reset[];
.raylib.scene.circle[`setInline;([] x:enlist 1f; y:enlist 2f; r:enlist 3f)];
.raylib.scene.set[`setInline;`x`y;(enlist 9f;enlist 8f)];
msgs:();
.raylib.refresh[];
assertEq["scene set inline refresh";0<count (raze msgs) ss "ADD_CIRCLE 9 8 3";1b];
assertEq["scene set missing id";.raylib.scene.set[`missing;`x;1f];0];
errSceneSet:.[.raylib.scene.set;(`setInline;`x`y;1f);{x}];
assertEq["scene set usage";errSceneSet;"usage: .raylib.scene.set[`id;`col or `col1`col2;value or (value1;value2)]"];

/ scene computed bindings + list metadata
.raylib.scene.reset[];
theta:0f;
radii:0 45 75f;
phases:0 0 0.5*acos -1f;
mx:100f;
my:200f;
orbits:([] r:14 8 8f; color:(.raylib.Color.BLUE;.raylib.Color.RED;.raylib.Color.YELLOW));
bnd:`x`y!({mx+radii*cos theta+phases};{my+radii*sin theta+phases});
.raylib.scene.circle[`orbits;.raylib.bind[orbits;bnd]];
sceneMeta:.raylib.scene.list[];
assertEq["scene list has bound col";`bound in cols sceneMeta;1b];
assertEq["scene list bound true";sceneMeta[`bound] 0;1b];
resolvedOrbit:.raylib.scene._resolveWithBindings[orbits;bnd];
assertEq["scene bindings x first";"i"$resolvedOrbit[`x] 0;100i];
assertEq["scene bindings y first";"i"$resolvedOrbit[`y] 0;200i];
msgs:();
nBound:.raylib.refresh[];
assertEq["scene bindings draw count";nBound;3];
assertEq["scene bindings first draw";msgs 1;"ADD_CIRCLE 100 200 14 0 121 241 255"];
theta:0.08f;
msgs:();
.raylib.refresh[];
assertEq["scene bindings updates on refresh";0<count (msgs 2) ss "ADD_CIRCLE 144.";1b];
badLenErr:.[{.raylib.scene._resolveWithBindings[orbits;`x!enlist {1 2f}]};();{x}];
assertEq["scene bindings wrong length errors";0<count string badLenErr;1b];

/ refresh should recover cleanly after bad scene source errors
.raylib.scene.reset[];
.raylib.scene.autoRefresh:0b;
.raylib.scene.circle[`badSrc;`missingSceneSymbol];
errRefreshBad:.[.raylib.refresh;();{x}];
assertEq["scene refresh bad source errors";0<count string errRefreshBad;1b];
assertEq["scene refresh bad source batch inactive";.raylib._batch.active;0b];
assertEq["scene refresh bad source batch cleared";count .raylib._batch.msgs;0];
.raylib.scene.reset[];
goodScene:([] x:enlist 11f; y:enlist 22f; r:enlist 33f);
.raylib.scene.circle[`goodSrc;goodScene];
msgs:();
nRecover:.raylib.refresh[];
.raylib.scene.autoRefresh:1b;
assertEq["scene refresh recovery count";nRecover;1];
assertEq["scene refresh recovery clear";msgs 0;"CLEAR"];
assertEq["scene refresh recovery draw";msgs 1;"ADD_CIRCLE 11 22 33 0 121 241 255"];

/ scene computed columns inline (no .raylib.bind)
.raylib.scene.reset[];
theta:0f;
radii:0 45 75f;
phases:0 0 0.5*acos -1f;
mx:100f;
my:200f;
orbitIdx:til count radii;
orbitXFns:{value raze ("{(mx+radii*cos theta+phases) ";string x;"}")} each orbitIdx;
orbitYFns:{value raze ("{(my+radii*sin theta+phases) ";string x;"}")} each orbitIdx;
orbitsInline:([] x:orbitXFns; y:orbitYFns; r:14 8 8f; color:(.raylib.Color.BLUE;.raylib.Color.RED;.raylib.Color.YELLOW));
.raylib.scene.circle[`orbitsInline;orbitsInline];
sceneMetaInline:.raylib.scene.list[];
assertEq["scene inline bound false";sceneMetaInline[`bound] 0;0b];
msgs:();
nInline:.raylib.refresh[];
assertEq["scene inline draw count";nInline;3];
assertEq["scene inline first draw";msgs 1;"ADD_CIRCLE 100 200 14 0 121 241 255"];
theta:0.08f;
msgs:();
.raylib.refresh[];
assertEq["scene inline updates on refresh";0<count (msgs 2) ss "ADD_CIRCLE 144.";1b];

/ Step 6 events + interactive mode
testEventBlob:"";
.raylib.transport.events.poll:{:testEventBlob};
testEventBlob:"1|1000|mouse_move|12|34|1|2\n2|1001|window_focus|1|0|0|0\n";
msgs:();
evPoll:.raylib.events.poll[];
assertEq["events poll sends no cmd";count msgs;0];
assertEq["events poll count";count evPoll;2];
assertEq["events poll first type";evPoll[`type] 0;`mouse_move];
assertEq["events poll second a";evPoll[`a] 1;1i];

/ native transport events come back as one newline-delimited string
testEventBlob:"10|1005|mouse_state|77|88|0|0\n11|1006|window_focus|1|0|0|0\n";
evPollNative:.raylib.events.poll[];
assertEq["events poll native blob count";count evPollNative;2];
assertEq["events poll native blob first type";evPollNative[`type] 0;`mouse_state];
assertEq["events poll native blob second seq";evPollNative[`seq] 1;11j];

eventRows:0i;
.raylib.events.callbacks.clear[];
cbEv:.raylib.events.on {[ev] eventRows+:count ev; :eventRows};
testEventBlob:"3|1002|key_down|65|0|0|0\n";
msgs:();
evPump:.raylib.events.pump[];
assertEq["events pump row count";count evPump;1];
assertEq["events pump callback rows";"i"$eventRows;1i];
assertEq["events off removed";.raylib.events.off cbEv;1];
assertEq["events callbacks clear";.raylib.events.callbacks.clear[];0];
errEventsOff:.[.raylib.events.off;enlist `bad;{x}];
assertEq["events off usage";errEventsOff;"usage: .raylib.events.off[id] or .raylib.events.off[idList]"];
assertEq["events clear table rows";count .raylib.events._callbacks;0];

/ interactive live binding from symbol refs
.raylib.interactive.live.clear[];
assertEq["interactive spin stop while inactive";.raylib.interactive.spin 0;0b];
assertEq["interactive stop before start";.raylib.interactive.stop[];0b];
preStartCb:.raylib.frame.on {[state] :state`frame};
assertEq["interactive pre-start callback count";count .raylib.frame._callbacks;1];
assertEq["interactive start first";.raylib.interactive.start[];1b];
assertEq["interactive start clears callbacks";count .raylib.frame._callbacks;0];
assertEq["interactive start second";.raylib.interactive.start[];1b];
assertEq["interactive stop after double start";.raylib.interactive.stop[];0b];
assertEq["interactive stop after double start inactive";.raylib.interactive.active;0b];
mx:10f;
my:20f;
msgs:();
.raylib.circle ([] x:enlist `mx; y:enlist `my; r:enlist 10f);
assertEq["interactive live count";count .raylib.interactive.live.list[];1];
mx:300f;
my:320f;
testEventBlob:"4|1003|mouse_move|300|320|0|0\n";
iv:.raylib.interactive.setInterval 0.5f;
assertEq["interactive interval fractional";iv;0.5f];
assertEq["interactive interval timer floor";.raylib.interactive._timerMs;1i];
assertEq["interactive interval loops";.raylib.interactive._ticksPerBeat;2i];
.raylib.interactive.setInterval 1000000;
on1:.raylib.interactive.mode 1;
assertEq["interactive mode on";on1;1b];
msgs:();
cmds:();
submitBodies:();
.raylib._sendMsg:origSendMsg;
.raylib.transport.submit:{[body] submitBodies,:enlist .raylib._batchToText body; :1b};
evTick:.raylib.interactive.tick[];
.raylib._sendMsg:{[msg] msgs,:enlist .raylib._cmdToText msg; :0};
assertEq["interactive tick event count";count evTick;1];
assertEq["interactive tick mx";mx;300f];
assertEq["interactive tick my";my;320f];
assertEq["interactive tick batched submit count";count submitBodies;1];
cmd0:$[count submitBodies;first submitBodies;""];
assertEq["interactive tick batched has clear";0<count cmd0 ss "CLEAR";1b];
assertEq["interactive tick batched has circle";0<count cmd0 ss "ADD_CIRCLE 300 320 10 0 121 241 255";1b];
tickFrames2:0i;
.raylib.frame.clear[];
cbTick2:.raylib.frame.on {[state] tickFrames2+:1i; :state`frame};
.raylib.interactive.active:1b;
testEventBlob:"";
.raylib.interactive.tick[];
assertEq["interactive tick runs frame callbacks";tickFrames2;1i];
assertEq["interactive tick advanced frame";0<"i"$.raylib.frame._state`frame;1b];
assertEq["interactive tick frame off";.raylib.frame.off cbTick2;1];

.raylib.frame.clear[];
cbTickErr:.raylib.frame.on {[state] '`boom};
.raylib.interactive.active:1b;
.raylib.interactive.lastError:`;
testEventBlob:"";
.raylib.interactive.tick[];
assertEq["interactive tick frame error stops";.raylib.interactive.active;0b];
assertEq["interactive tick frame error stored";10h=type .raylib.interactive.lastError;1b];
assertEq["interactive tick frame error off";.raylib.frame.off cbTickErr;1];

/ redraw failures should stop interactive mode and clear batch state
.raylib.interactive._live:([] id:enlist 42i; kind:enlist `circle; src:enlist `missingLiveSymbol);
.raylib.interactive.active:1b;
.raylib.interactive.lastError:`;
testEventBlob:"";
.raylib.interactive.tick[];
assertEq["interactive redraw error stops";.raylib.interactive.active;0b];
assertEq["interactive redraw error stored";10h=type .raylib.interactive.lastError;1b];
assertEq["interactive redraw error batch inactive";.raylib._batch.active;0b];
assertEq["interactive redraw error batch cleared";count .raylib._batch.msgs;0];

off0:.raylib.interactive.mode 0;
assertEq["interactive mode off";off0;0b];
assertEq["interactive active false";.raylib.interactive.active;0b];
assertEq["interactive live clear";.raylib.interactive.live.clear[];0];

/ interactive esc stop + live dedupe
.raylib.interactive.active:1b;
.raylib.interactive.spinActive:1b;
.raylib.interactive._applyEvents flip `seq`time`type`a`b`c`d!(enlist 1j;enlist 1j;enlist `key_down;enlist 256i;enlist 0i;enlist 0i;enlist 0i);
assertEq["interactive esc stops active";.raylib.interactive.active;0b];
assertEq["interactive esc stops spin";.raylib.interactive.spinActive;0b];
.raylib.interactive.live.clear[];
mx:50f; my:60f;
.raylib.circle ([] x:enlist `mx; y:enlist `my; r:enlist 8f);
.raylib.circle ([] x:enlist `mx; y:enlist `my; r:enlist 8f);
assertEq["interactive live dedupe";count .raylib.interactive.live.list[];1];

/ Step 7 UI toolkit: panel/button/slider/chart/inspector + helpers
msgs:();
nUiPanel:.raylib.ui.panel ([] x:enlist 10f; y:enlist 20f; w:enlist 120f; h:enlist 80f; title:enlist "Stats");
assertEq["ui panel count";nUiPanel;1];
assertEq["ui panel msg count";count msgs;6];
assertEq["ui panel rect";msgs 0;"ADD_RECT 10 20 120 80 245 245 245 255"];
assertEq["ui panel title";msgs 5;"ADD_TEXT 18 28 18 20 20 20 255 Stats"];

mx:50f; my:50f; mpressed:1b; mbutton:0i;
btnState:.raylib.ui.buttonState ([] x:enlist 20f; y:enlist 30f; w:enlist 90f; h:enlist 30f; label:enlist "Go");
assertEq["ui button state hot";btnState[`hot] 0;1b];
assertEq["ui button state active";btnState[`active] 0;1b];
assertEq["ui button state clicked";btnState[`clicked] 0;1b];
msgs:();
nUiButton:.raylib.ui.button ([] x:enlist 20f; y:enlist 30f; w:enlist 90f; h:enlist 30f; label:enlist "Go");
assertEq["ui button count";nUiButton;1];
assertEq["ui button msg count";count msgs;6];
assertEq["ui button bg active";msgs 0;"ADD_RECT 20 30 90 30 170 200 235 255"];

/ regression: frame callback can mutate button label and redraw without interactive crash
.raylib.frame.clear[];
.raylib.interactive.active:1b;
.raylib.interactive.lastError:`;
testEventBlob:"";
ctrUi:0i;
btnUi:([] x:enlist 40f; y:enlist 40f; w:enlist 180f; h:enlist 56f; label:enlist "total: 0");
hudUi:([] x:enlist 40f; y:enlist 120f; text:enlist "click button"; size:enlist 24i);
drawUi:{[]
  .raylib.clear[];
  .raylib.ui.button btnUi;
  .raylib.text hudUi;
  :0
 };
cbUi:.raylib.frame.on {[state]
  s:.raylib.ui.buttonState btnUi;
  if[s[`clicked] 0; ctrUi+:1i];
  if[s[`clicked] 0; btnUi[`label]:enlist raze ("total: ";string ctrUi)];
  drawUi[];
  :0
 };
mx:0f; my:0f; mpressed:0b; mbutton:-1i;
.raylib.interactive.tick[];
assertEq["ui callback idle counter";ctrUi;0i];
assertEq["ui callback idle label";btnUi[`label] 0;"total: 0"];
assertEq["ui callback idle no error";.raylib.interactive.lastError;`];
mx:60f; my:60f; mpressed:1b; mbutton:0i;
.raylib.interactive.tick[];
assertEq["ui callback click counter";ctrUi;1i];
assertEq["ui callback click label";btnUi[`label] 0;"total: 1"];
assertEq["ui callback click no error";.raylib.interactive.lastError;`];
assertEq["ui callback interactive still active";.raylib.interactive.active;1b];
assertEq["ui callback off";.raylib.frame.off cbUi;1];
.raylib.interactive._stop[];

mx:60f; my:100f; mpressed:1b; mbutton:0i;
sliderInput:([] x:enlist 20f; y:enlist 90f; w:enlist 100f; lo:enlist 0f; hi:enlist 10f; val:enlist 2f; label:enlist "Speed");
sliderState:.raylib.ui.sliderValue sliderInput;
assertEq["ui slider value drag";"f"$sliderState[`val] 0;4f];
msgs:();
nUiSlider:.raylib.ui.slider sliderState;
assertEq["ui slider count";nUiSlider;1];
assertEq["ui slider msg count";count msgs;5];
assertEq["ui slider track";msgs 0;"ADD_RECT 20 98 100 4 190 190 190 255"];

msgs:();
nUiChartLine:.raylib.ui.chartLine ([] x:enlist 10f; y:enlist 120f; w:enlist 120f; h:enlist 60f; values:enlist 1 3 2f; title:enlist "Trend");
assertEq["ui chart line count";nUiChartLine;1];
assertEq["ui chart line msg count";count msgs;9];
assertEq["ui chart line bg";msgs 0;"ADD_RECT 10 120 120 60 248 248 248 255"];
assertEq["ui chart line title";msgs 3;"ADD_TEXT 10 108 16 20 20 20 255 Trend"];

msgs:();
nUiChartBar:.raylib.ui.chart[`bar;([] x:enlist 150f; y:enlist 120f; w:enlist 120f; h:enlist 60f; values:enlist 2 4 1f; title:enlist "Bars")];
assertEq["ui chart bar count";nUiChartBar;1];
assertEq["ui chart bar msg count";count msgs;7];
assertEq["ui chart bar bg";msgs 0;"ADD_RECT 150 120 120 60 248 248 248 255"];

msgs:();
nUiInspector:.raylib.ui.inspector ([] x:enlist 10f; y:enlist 200f; field:enlist "fps"; val:enlist 240i);
assertEq["ui inspector count";nUiInspector;1];
assertEq["ui inspector msg count";count msgs;7];
assertEq["ui inspector key";msgs 5;"ADD_TEXT 18 208 16 20 20 20 255 fps"];
assertEq["ui inspector val";msgs 6;"ADD_TEXT 138 208 16 0 121 241 255 240"];

mx:25f; my:35f; mpressed:0b; mbutton:-1i;
hit:.raylib.ui.hit.rect ([] x:20 200f; y:30 20f; w:20 30f; h:20 20f);
assertEq["ui hit rect first";hit 0;1b];
assertEq["ui hit rect second";hit 1;0b];

docUiPanel:.raylib.help `ui.panel;
assertEq["help ui panel exact";docUiPanel;"Draw panel widgets from table rows.\nusage: .raylib.ui.panel[t] where t has x y w h"];
docUiChart:.raylib.help `ui.chart;
assertEq["help ui chart exact";docUiChart;"Generic chart dispatcher.\nusage: .raylib.ui.chart[`kind;t] where kind is line|bar"];
docUiInspector:.raylib.help `ui.inspector;
assertEq["help ui inspector exact";docUiInspector;"Draw inspector rows (`field` + `val`) with optional boxed panel styling.\nusage: .raylib.ui.inspector[t] where t has x y field val"];
docUiButtonClick:.raylib.help `ui.buttonClick;
assertEq["help ui button click exact";docUiButtonClick;"High-level clickable button with per-id edge state.\nusage: .raylib.ui.buttonClick[`id;rect4;label;onClickFn;`press|`release]"];

/ Step 7 high-level frame/button APIs: batch flush + edge semantics
.raylib._sendMsg:origSendMsg;
origSubmitUi:.raylib.transport.submit;
submitBodiesUi:();
.raylib.transport.submit:{[body] submitBodiesUi,:enlist .raylib._batchToText body; :1b};

mx:60f; my:60f; mpressed:1b; mbutton:0i;
pressCtr:0i;
.raylib.ui.state.reset[];
.raylib.ui.frame {[]
  .raylib.ui.buttonClick[`pressBtn;40 40 180 56f;"press";{[] pressCtr+:1i};`press];
  .raylib.ui.text[40f;120f;"txt";24i] };
assertEq["ui frame press first";pressCtr;1i];
assertEq["ui frame submit count";count submitBodiesUi;1];
uiCmd:first submitBodiesUi;
assertEq["ui frame submit nonempty";0<count raze string uiCmd;1b];

submitBodiesUi:();
.raylib.ui.frame {[] .raylib.ui.buttonClick[`pressBtn;40 40 180 56f;"press";{[] pressCtr+:1i};`press] };
.raylib.ui.frame {[] .raylib.ui.buttonClick[`pressBtn;40 40 180 56f;"press";{[] pressCtr+:1i};`press] };
assertEq["ui press hold does not repeat";pressCtr;1i];

releaseCtr:0i;
.raylib.ui.state.reset[];
mx:60f; my:60f; mbutton:0i; mpressed:1b;
.raylib.ui.frame {[] .raylib.ui.buttonClick[`relBtn;40 40 180 56f;"release";{[] releaseCtr+:1i};`release] };
assertEq["ui release while down";releaseCtr;0i];
mpressed:0b;
.raylib.ui.frame {[] .raylib.ui.buttonClick[`relBtn;40 40 180 56f;"release";{[] releaseCtr+:1i};`release] };
assertEq["ui release on up inside";releaseCtr;1i];

wrapCtr:0i;
.raylib.ui.state.reset[];
mx:60f; my:60f; mpressed:1b; mbutton:0i;
.raylib.ui.frame {[] .raylib.ui.buttonPress[`wrapBtn;40 40 180 56f;"wrap";{[] wrapCtr+:1i}] };
assertEq["ui buttonPress wrapper";wrapCtr;1i];

.raylib.transport.submit:origSubmitUi;

/ ============================================================
/ NEW TEST GROUPS: comprehensive coverage
/ ============================================================

/ run these groups through real send path and capture submitted command text
origSubmitPhase4:.raylib.transport.submit;
.raylib._sendMsg:origSendMsg;
msgs:();
submitBodiesPhase4:();
.raylib.transport.submit:{[body]
  txt:.raylib._batchToText body;
  submitBodiesPhase4,:enlist txt;
  if[count txt; msgs,:("\n" vs txt) where 0<count each "\n" vs txt];
  :1b
 };

/ --- Test Group 1: Callback registry direct tests ---
cbReg:.raylib._callbacks.empty[];
assertEq["cb make empty count";count cbReg`id;0];
cbNext:0i;
cbVals:();
idCb1:.raylib._callbacks.on[`cbReg;`cbNext;{[x] cbVals,:x; :0}];
assertEq["cb on returns id type";type idCb1;-6h];
assertEq["cb on count1";count cbReg`id;1];
idCb2:.raylib._callbacks.on[`cbReg;`cbNext;{[x] cbVals,:x+10; :0}];
assertEq["cb on count2";count cbReg`id;2];
cbReg2:cbReg;
cbVals:();
cbReg2:update enabled:1 0b from cbReg2;
.raylib._callbacks.dispatch[cbReg2;42];
assertEq["cb dispatch enabled only";cbVals;42 52];
removedCb1:.raylib._callbacks.off[`cbReg;idCb1;"cb usage"];
assertEq["cb off removes one";removedCb1;1];
assertEq["cb off count";count cbReg`id;1];
removedMissing:.raylib._callbacks.off[`cbReg;999i;"cb usage"];
assertEq["cb off missing safe";removedMissing;0];
assertEq["cb off missing count";count cbReg`id;1];
assertEq["cb clear returns 0";.raylib._callbacks.clear[`cbReg];0];
assertEq["cb clear empty";count cbReg`id;0];
assertEq["cb dispatch empty safe";.raylib._callbacks.dispatch[cbReg;99];99];

/ --- Test Group 2: Batch operations ---
msgs:();
.raylib._batch.abort[];
.raylib._batch.begin[];
assertEq["batch active after begin";.raylib._batch.active;1b];
.raylib.circle ([] x:enlist 1f; y:enlist 2f; r:enlist 3f);
assertEq["batch holds msgs";count msgs;0];
assertEq["batch queued one";count .raylib._batch.msgs;1];
.raylib._batch.flush[];
assertEq["batch flush inactive";.raylib._batch.active;0b];
assertEq["batch flush sent one";count msgs;1];
.raylib._batch.begin[];
.raylib.circle ([] x:enlist 1f; y:enlist 2f; r:enlist 3f);
.raylib._batch.begin[];
assertEq["batch double begin resets";count .raylib._batch.msgs;0];
.raylib._batch.abort[];
msgsBeforeAbort:count msgs;
.raylib._batch.begin[];
.raylib.circle ([] x:enlist 1f; y:enlist 2f; r:enlist 3f);
.raylib._batch.abort[];
assertEq["batch abort discards";count msgs;msgsBeforeAbort];

/ --- Test Group 3: Complex multi-layer scene rendering ---
.raylib.scene.reset[];
.raylib.scene.autoRefresh:0b;
.raylib.scene.upsertEx[`bg;`rect;([] x:enlist 0f; y:enlist 0f; w:enlist 800f; h:enlist 600f);()!();0i;1b];
.raylib.scene.upsertEx[`ui;`text;([] x:enlist 10f; y:enlist 10f; text:enlist "HUD"; size:enlist 20i);()!();2i;1b];
.raylib.scene.upsertEx[`mid;`circle;([] x:enlist 100f; y:enlist 100f; r:enlist 50f);()!();1i;1b];
msgs:();
.raylib.refresh[];
assertEq["scene layer order count";count msgs;4];
assertEq["scene clear first";msgs 0;"CLEAR"];
assertEq["scene layer 0 first";0<count msgs[1] ss "ADD_RECT";1b];
assertEq["scene layer 1 second";0<count msgs[2] ss "ADD_CIRCLE";1b];
assertEq["scene layer 2 third";0<count msgs[3] ss "ADD_TEXT";1b];
.raylib.scene.visible[`mid;0b];
msgs:();
.raylib.refresh[];
assertEq["scene hidden skip count";count msgs;3];
assertEq["scene hidden no circle";any {0<count x ss "ADD_CIRCLE"} each msgs;0b];
.raylib.scene.clearLayer 2i;
assertEq["scene clearLayer removes";count select from .raylib.scene._rows where layer=2i;0];
.raylib.scene.reset[];
.raylib.scene.autoRefresh:0b;
.raylib.scene.circle[`c1;([] x:enlist 10f; y:enlist 10f; r:enlist 5f)];
.raylib.scene.circle[`c2;([] x:enlist 20f; y:enlist 20f; r:enlist 5f)];
.raylib.scene.circle[`c3;([] x:enlist 30f; y:enlist 30f; r:enlist 5f)];
rowsScene:.raylib.scene.list[];
assertEq["scene insert order";rowsScene`id;`c1`c2`c3];
assertEq["scene insert ord monotonic";asc rowsScene`ord;rowsScene`ord];
.raylib.scene.autoRefresh:1b;

/ --- Test Group 4: Tween & keyframe edge cases ---
from1:([] x:enlist 0f; y:enlist 0f);
to1:([] x:enlist 100f; y:enlist 100f);
tw1:.raylib.tween.table[from1;to1;1f;1;`linear];
assertEq["tween 1 step count";count tw1;2];
assertEq["tween 1 step x0";tw1[`x] 0;0f];
assertEq["tween 1 step x1";tw1[`x] 1;100f];
tw60:.raylib.tween.table[from1;to1;1f;60;`linear];
assertEq["tween 60 start x";tw60[`x] 0;0f];
assertEq["tween 60 end x";tw60[`x] 60;100f];
twQ:.raylib.tween.table[from1;to1;1f;10;`inQuad];
assertEq["tween inQuad slow start";(twQ[`x] 1)<12f;1b];
assertEq["tween inQuad fast end";(twQ[`x] 9)>80f;1b];
kf3:([] at:0 0.5 1f; x:0 100 0f; y:0 50 0f);
frames3:.raylib.keyframesTable[kf3;20;`linear];
assertEq["kf 3pt count";count frames3;21];
assertEq["kf mid near peak";(frames3[`x] 9)>80f;1b];
fromC:([] x:enlist 0f; y:enlist 0f; r:enlist 10f; color:enlist 255 0 0 255i);
toC:([] x:enlist 0f; y:enlist 0f; r:enlist 10f; color:enlist 0 255 0 255i);
twC:.raylib.tween.table[fromC;toC;1f;10;`linear];
assertEq["tween color count";count twC;11];
assertEq["tween color mid green rising";((twC[`color] 5) 1)>100i;1b];

/ --- Test Group 5: Frame loop & callback ordering ---
.raylib.frame.clear[];
.raylib.frame.reset[];
.raylib.frame.setDt 0.1f;
orderFrame:();
idF1:.raylib.frame.on {[s] orderFrame,:1i; :0};
idF2:.raylib.frame.on {[s] orderFrame,:2i; :0};
idF3:.raylib.frame.on {[s] orderFrame,:3i; :0};
.raylib.frame.step 1;
assertEq["frame cb order";orderFrame;1 2 3i];
.raylib.frame.off idF2;
orderFrame:();
.raylib.frame.step 1;
assertEq["frame cb after off";orderFrame;1 3i];
.raylib.frame.reset[];
.raylib.frame.clear[];
.raylib.frame.step 10;
assertEq["frame step counter";.raylib.frame._state`frame;10i];
assertEq["frame step time";.raylib.frame._state`time;1f];
cmds:();
.raylib.frame.run 5;
assertEq["frame run sleep count";count cmds;5];
assertEq["frame run time advance";.raylib.frame._state`time;1.5f];
.raylib.frame.clear[];
eachCalls:0i;
eid:.raylib.each.frame {[] eachCalls+:1i; :0};
.raylib.frame.step 3;
assertEq["each.frame calls";eachCalls;3i];
.raylib.frame.off eid;

/ --- Test Group 6: Error handling & edge cases ---
errEmptyCircle:.raylib.circle ([] x:`float$(); y:`float$(); r:`float$());
assertEq["circle empty table";errEmptyCircle;0];
errTypeCircle:.[.raylib.circle;enlist ([] x:enlist "bad"; y:enlist 2f; r:enlist 3f);{x}];
assertEq["circle bad type is error";10h=type errTypeCircle;1b];
errRate0:.[.raylib.animate.circle;enlist ([] x:enlist 1f; y:enlist 2f; r:enlist 3f; rate:enlist 0f);{x}];
assertEq["anim rate 0 error";10h=type errRate0;1b];
errKind:.[.raylib.scene.upsert;(`test;`badkind;([] x:enlist 1f));{x}];
assertEq["scene bad kind error";10h=type errKind;1b];
setMissing:.raylib.scene.set[`nonexistent;`x;100f];
assertEq["scene set missing id no-op";setMissing;0];
errHelp:.[.raylib.help;enlist "notSymbol";{x}];
assertEq["help non-symbol error";10h=type errHelp;1b];
errTween:.[.raylib.tween.table;(([] x:enlist 0f);([] y:enlist 0f);1f;10;`linear);{x}];
assertEq["tween mismatched schema";10h=type errTween;1b];
errFill:.[.raylib.fillColor;(([] x:enlist 1f; y:enlist 2f; r:enlist 3f);"bad");{x}];
assertEq["fillColor bad color";10h=type errFill;1b];
errNegRate:.[.raylib.animate.circle;enlist ([] x:enlist 1f; y:enlist 2f; r:enlist 3f; rate:enlist -1f);{x}];
assertEq["anim negative rate error";10h=type errNegRate;1b];

/ --- Test Group 7: UI advanced scenarios ---
msgs:();
mx:0f; my:0f; mpressed:0b; mbutton:-1i;
bState:.raylib.ui.buttonState ([] x:enlist 100f; y:enlist 100f; w:enlist 80f; h:enlist 30f; label:enlist "btn");
assertEq["button cold";bState[`hot] 0;0b];
mx:120f; my:110f;
bState2:.raylib.ui.buttonState ([] x:enlist 100f; y:enlist 100f; w:enlist 80f; h:enlist 30f; label:enlist "btn");
assertEq["button hot";bState2[`hot] 0;1b];
mx:50f; my:55f; mpressed:1b; mbutton:0i;
sl:([] x:enlist 50f; y:enlist 50f; w:enlist 200f; lo:enlist 0f; hi:enlist 100f; val:enlist 50f);
slMin:.raylib.ui.sliderValue sl;
assertEq["slider at min";slMin[`val] 0;0f];
mx:250f;
slMax:.raylib.ui.sliderValue sl;
assertEq["slider at max";slMax[`val] 0;100f];
mx:100f; my:100f;
hitRect:([] x:enlist 100f; y:enlist 100f; w:enlist 50f; h:enlist 50f);
assertEq["hit rect corner";.raylib.ui.hit.rect[hitRect][0];1b];
mx:149f; my:149f;
assertEq["hit rect inside edge";.raylib.ui.hit.rect[hitRect][0];1b];
mx:150f; my:150f;
assertEq["hit rect outside edge";.raylib.ui.hit.rect[hitRect][0];1b];
msgs:();
.raylib.ui.frame {[] .raylib.ui.panel ([] x:10 10f; y:10 100f; w:200 200f; h:80 80f) };
assertEq["panel multi row";(count msgs)>2;1b];
msgs:();
errChartSingle:.[{[]
    .raylib.ui.frame {[] .raylib.ui.chartLine ([] x:enlist 10f; y:enlist 10f; w:enlist 200f; h:enlist 100f; values:enlist enlist 42f) }};
  enlist 0;{x}];
assertEq["chart single value error";10h=type errChartSingle;1b];
msgs:();
.raylib.ui.frame {[] .raylib.ui.chartLine ([] x:enlist 10f; y:enlist 10f; w:enlist 200f; h:enlist 100f; values:enlist 42 50f) };
assertEq["chart two values renders";(count msgs)>=1;1b];
msgs:();
.raylib.ui.frame {[] .raylib.ui.inspector ([] x:10 10f; y:10 40f; field:("key1";"key2"); val:("val1";"val2")) };
assertEq["inspector multi row";(count msgs)>2;1b];

/ --- Test Group 8: Pixel edge cases ---
msgs:();
.raylib.pixels ([] pixels:enlist enlist 128i; x:enlist 0f; y:enlist 0f);
assertEq["pixel 1x1 gray";count msgs;1];
msgs:();
grid10:10 10#til 100;
.raylib.pixels ([] pixels:enlist grid10; x:enlist 0f; y:enlist 0f);
assertEq["pixel 10x10";count msgs;100];
msgs:();
.raylib.pixels ([] pixels:enlist 2 2#0 255 128 64i; x:enlist 10f; y:enlist 10f; dw:enlist 100f; dh:enlist 100f);
assertEq["pixel dw dh scale";count msgs;4];
msgs:();
pixFrames3:(enlist 1 2 3i;enlist 4 5 6i;enlist 7 8 9i);
.raylib.pixels ([] pixels:enlist pixFrames3; x:enlist 0f; y:enlist 0f; rate:enlist 0.5f);
assertEq["anim pixel clear";any {0<count x ss "ANIM_PIXELS_CLEAR"} each msgs;1b];
assertEq["anim pixel play";any {0<count x ss "ANIM_PIXELS_PLAY"} each msgs;1b];
msgs:();
.raylib.pixels ([] pixels:enlist 1 1#255i; x:enlist 0f; y:enlist 0f; alpha:enlist 128i);
assertEq["pixel alpha modulation";any {0<count x ss " 128"} each msgs;1b];

/ --- Test Group 9: Interactive mode edge cases ---
origPollPhase4:.raylib.transport.events.poll;
.raylib.interactive.active:0b;
.raylib.interactive.start[];
assertEq["interactive active";.raylib.interactive.active;1b];
.raylib.interactive.stop[];
assertEq["interactive stopped";.raylib.interactive.active;0b];
.raylib.interactive.start[];
.raylib.interactive.stop[];
.raylib.interactive.start[];
.raylib.interactive.stop[];
assertEq["interactive rapid cycle";.raylib.interactive.active;0b];
mx:0f; my:0f;
.raylib.interactive.start[];
.raylib.transport.events.poll:{:enlist "1|0.01|mouse_move|150|200|0|0"};
.raylib.interactive.tick[];
assertEq["tick updates mx";mx;150f];
assertEq["tick updates my";my;200f];
.raylib.interactive.active:1b;
.raylib.interactive.spinActive:1b;
.raylib.transport.events.poll:{:enlist "2|0.02|key_down|256|0|0|0"};
.raylib.interactive.tick[];
assertEq["esc stops interactive";.raylib.interactive.active;0b];
.raylib.transport.events.poll:origPollPhase4;

/ --- Test Group 10: Scene bindings & computed columns ---
.raylib.scene.reset[];
.raylib.scene.autoRefresh:0b;
msgs:();
playerX:100f; playerY:200f;
.raylib.scene.circle[`player;([] x:enlist `playerX; y:enlist `playerY; r:enlist 25f)];
.raylib.refresh[];
assertEq["binding resolves symbol";0<count msgs[1] ss "100 200 25";1b];
playerX:300f;
msgs:();
.raylib.refresh[];
assertEq["binding tracks update";0<count msgs[1] ss "300 200 25";1b];
counter:0i;
.raylib.scene.circle[`computed;([] x:enlist {[] "f"$counter}; y:enlist 10f; r:enlist 6f)];
msgs:();
.raylib.refresh[];
assertEq["lambda binding";any {0<count x ss "ADD_CIRCLE 0 10 6"} each msgs;1b];
counter:42i;
msgs:();
.raylib.refresh[];
assertEq["lambda binding update";any {0<count x ss "ADD_CIRCLE 42 10 6"} each msgs;1b];
.raylib.scene.set[`player;`r;50f];
msgs:();
.raylib.refresh[];
assertEq["scene set partial";0<count msgs[1] ss "300 200 50";1b];
.raylib.scene.set[`player;`x;400f];
.raylib.scene.set[`player;`y;500f];
msgs:();
.raylib.refresh[];
assertEq["scene set multi col";0<count msgs[1] ss "400 500 50";1b];
.raylib.scene.autoRefresh:1b;
.raylib.scene.reset[];

/ --- Test Group 11: Shape introspection deep tests ---
assertEq["shape 1d";.raylib.shape.info 1 2 3;enlist 3];
assertEq["shape scalar";.raylib.shape.info 42;()];
arr3d:(1 2 3;4 5 6);
assertEq["shape 2x3";.raylib.shape.info arr3d;2 3];
arr4d:((1 2;3 4);(5 6;7 8));
assertEq["shape 2x2x2";.raylib.shape.info arr4d;2 2 2];
pretty:.raylib.shape.pretty 2 3#til 6;
assertEq["pretty has shape";pretty like "*2 3*";1b];
assertEq["shape empty";.raylib.shape.info ();enlist 0];

.raylib.transport.submit:origSubmitPhase4;

/ ============================================================
/ END NEW TEST GROUPS
/ ============================================================

.raylib.events.path:origEventsPath;

.raylib.open:origOpen;
.raylib.transport.open:origTransportOpen;
.raylib.transport.close:origTransportClose;
.raylib.transport.submit:origTransportSubmit;
.raylib.transport.events.poll:origTransportEventsPoll;
.raylib._ensureReady:origEnsureReady;
.raylib.interactive._stop:origInteractiveStop;
.raylib._runCmd:origRunCmd;
.raylib._sendMsg:origSendMsg;

if[count failures;
  show "raylib_q_init tests failed:";
  show failures;
  '"test_failed"];

show "raylib_q_init tests passed";
