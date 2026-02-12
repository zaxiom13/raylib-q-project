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
origEmitLine:.raylib.transport._emitLine;
origNativeLoadFn:.raylib.native._load;

/ open/close should be boolean + idempotent close path
openCalls:0i;
closeCalls:0i;
stopCalls:0i;
.raylib.transport.open:{openCalls+:1i; :1b};
.raylib.transport.close:{closeCalls+:1i; :1b};
.raylib.interactive._stop:{stopCalls+:1i; .raylib.interactive.active:0b; :0b};
.raylib._runtimeOpen:0b;
.raylib.autoPump.enabled:1b;
.raylib.autoPump.suspend:0b;
.raylib.autoPump.active:0b;
.raylib.autoPump._timerOwned:0b;
.raylib.scene._rows:([] id:enlist `tmp; kind:enlist `circle; src:enlist ([] x:enlist 1f; y:enlist 2f; r:enlist 3f); bindings:enlist ()!(); layer:enlist 0i; visible:enlist 1b; ord:enlist 7i);
.raylib.scene._nextOrd:8i;
assertEq["open bool";.raylib.open[];1b];
assertEq["open transport call count";openCalls;1i];
assertEq["open enables auto pump";.raylib.autoPump.active;1b];
assertEq["open implicit scene reset rows";count .raylib.scene._rows;0];
assertEq["open implicit scene reset ord";.raylib.scene._nextOrd;0i];
.raylib.scene._rows:([] id:enlist `keep; kind:enlist `circle; src:enlist ([] x:enlist 4f; y:enlist 5f; r:enlist 6f); bindings:enlist ()!(); layer:enlist 0i; visible:enlist 1b; ord:enlist 0i);
assertEq["open second bool";.raylib.open[];1b];
assertEq["open second does not reset rows";count .raylib.scene._rows;1];
assertEq["close bool";.raylib.close[];1b];
assertEq["close transport call count";closeCalls;1i];
assertEq["close disables auto pump";.raylib.autoPump.active;0b];
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

/ draw target namespace defaults and validation
assertEq["draw target default";.draw.target.get[];`raylib];
assertEq["draw target set canvas";.draw.target.set `canvas;`canvas];
assertEq["draw target read canvas";.draw.target.get[];`canvas];
errDrawTargetType:.[.draw.target.set;enlist "canvas";{x}];
assertEq["draw target type usage";errDrawTargetType;"usage: .draw.target.set[`raylib|`canvas]"];
errDrawTargetValue:.[.draw.target.set;enlist `svg;{x}];
assertEq["draw target value usage";errDrawTargetValue;"usage: .draw.target.set[`raylib|`canvas]"];
assertEq["draw target reset raylib";.draw.target.set `raylib;`raylib];

/ canvas target should emit command lines instead of touching native runtime
emitted:();
nativeLoadCalls:0i;
.raylib.transport._emitLine:{[line] emitted,:enlist line; :1b};
.raylib.native._load:{nativeLoadCalls+:1i; :1b};
sendMsgStub:.raylib._sendMsg;
.raylib._sendMsg:origSendMsg;
.draw.target.set `canvas;
.raylib.circle ([] x:enlist 9f; y:enlist 8f; r:enlist 7f);
assertEq["draw target canvas native load skipped";nativeLoadCalls;0i];
assertEq["draw target canvas emit count";count emitted;1];
assertEq["draw target canvas emit line";first emitted;"RAYLIB_Q_CMD ADD_CIRCLE 9 8 7 0 121 241 255"];
.draw.target.set `raylib;
.raylib._sendMsg:sendMsgStub;
.raylib.transport._emitLine:origEmitLine;
.raylib.native._load:origNativeLoadFn;

/ canvas frame callbacks should arm interactive ticking automatically
.raylib.frame.clear[];
.raylib.interactive.active:0b;
.draw.target.set `canvas;
cbCanvasFrame:.draw.frame.on {[state] :state`frame};
assertEq["draw frame.on canvas active";.raylib.interactive.active;1b];
assertEq["draw frame.on canvas callback count";count .raylib.frame._callbacks;1];
assertEq["draw frame.on canvas off";.raylib.frame.off cbCanvasFrame;1];
assertEq["draw frame.on canvas reset target";.draw.target.set `raylib;`raylib];

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

/ symbol refs are rejected in draw columns
msgs:();
mx:111f;
my:222f;
tCircleFollow:([] x:enlist `mx; y:enlist `my; r:enlist 10f);
errCircleFollow:.[.raylib.circle;enlist tCircleFollow;{x}];
assertEq["circle symbol refs type";errCircleFollow;"type"];

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

/ text callable payload (regression: callable string return should be accepted)
msgs:();
tTextFn:([] x:enlist 1f; y:enlist 2f; text:enlist {"dynamic"}; size:enlist 12i);
.raylib.text tTextFn;
assertEq["text callable msg";first msgs;"ADD_TEXT 1 2 12 0 0 0 255 dynamic"];

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

/ pixels large static payload switches to texture blit command
msgs:();
oldPixBlitThreshold:.raylib._pixelBlitThreshold;
.raylib._pixelBlitThreshold:1i;
tPixBlit:([] pixels:enlist 10 20i; x:enlist 1f; y:enlist 2f; scale:enlist 3f);
nPixBlit:.raylib.pixels tPixBlit;
assertEq["pixels blit count";nPixBlit;1];
assertEq["pixels blit msg count";count msgs;1];
assertEq["pixels blit msg";first msgs;"ADD_PIXELS_BLIT 1 2 6 3 255 2 1 1"];
.raylib._pixelBlitThreshold:oldPixBlitThreshold;

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
docShapeShow:.raylib.help `shape.show;
assertEq["help shape show exact";docShapeShow;"Print a Uiua-style pretty view of an array and return ::.\nusage: .raylib.shape.show x"];
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
docSceneSquare:.raylib.help `scene.square;
assertEq["help scene square exact";docSceneSquare;"Upsert square scene source.\nusage: .raylib.scene.square[`id;table]"];
docEachFrame:.raylib.help `each.frame;
assertEq["help each frame exact";docEachFrame;"Register a no-arg callback to run each frame tick.\nusage: .raylib.each.frame[{...}]"];
docUnknown:.raylib.help `notAFunction;
assertEq["help unknown contains msg";0<count docUnknown ss "unknown function: notAFunction";1b];
assertEq["easings list";.raylib.easings[];`linear`inQuad`outQuad`inOutQuad];
  assertEq["colors count";count .raylib.colors[];23];
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
shapeShowRes:.raylib.shape.show 2 2#til 4;
assertEq["shape show returns null";shapeShowRes;::];

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
