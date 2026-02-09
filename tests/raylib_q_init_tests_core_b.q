errType:.[.raylib.circle;enlist 42;{x}];
assertEq["type error";errType;"usage: .raylib.circle[t] where t is a table with x y r (optional color,alpha,layer,rotation,stroke,fill)"];
msgs:();
nCircleExtra:.raylib.circle ([] x:enlist 11f; y:enlist 12f; r:enlist 3f; rate:enlist 0.5f);
assertEq["circle extra cols allowed count";nCircleExtra;1];
assertEq["circle extra cols allowed draw";msgs 0;"ADD_CIRCLE 11 12 3 0 121 241 255"];

/ scene upsert + refresh from table source
.raylib.scene.reset[];
boundSpec:.raylib.bind[`sceneCircle;`x`y!({mx+1f};{my+2f})];
assertEq["bind tag";boundSpec 0;`raylib_bound];
assertEq["bind src";boundSpec 1;`sceneCircle];
assertEq["isBound true";.raylib._isBound boundSpec;1b];
assertEq["isBound false";.raylib._isBound `sceneCircle;0b];
sceneCircle:([] x:10 30f; y:20 40f; r:5 7f);
.raylib.scene.circle[`sceneCircleId;sceneCircle];
msgs:();
nScene1:.raylib.refresh[];
assertEq["scene refresh count1";nScene1;2];
assertEq["scene refresh msg count1";count msgs;3];
assertEq["scene refresh msg clear1";msgs 0;"CLEAR"];
assertEq["scene refresh msg first";msgs 1;"ADD_CIRCLE 10 20 5 0 121 241 255"];
sceneCircle:1_ sceneCircle;
msgs:();
nScene2:.raylib.refresh[];
assertEq["scene refresh count2";nScene2;2];
assertEq["scene refresh msg count2";count msgs;3];
assertEq["scene refresh msg clear2";msgs 0;"CLEAR"];
assertEq["scene refresh msg unchanged";msgs 1;"ADD_CIRCLE 10 20 5 0 121 241 255"];
resolvedNoBindings:.raylib.scene._resolveWithBindings[sceneCircle;()!()];
assertEq["scene resolve empty bindings unchanged";resolvedNoBindings;sceneCircle];

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
.raylib.scene.circle[`setSym;sceneSet];
.raylib.scene.set[`setSym;`x;200 300f];
msgs:();
.raylib.refresh[];
assertEq["scene set table refresh first";msgs 1;"ADD_CIRCLE 200 30 5 0 121 241 255"];
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
errBadSrc:.[.raylib.scene.circle;(`badSrc;`missingSceneSymbol);{x}];
assertEq["scene bad source upsert usage";errBadSrc;"usage: .raylib.scene.upsertEx[`id;`kind;table;bindingsDict;layerInt;visibleBool]"];
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

/ interactive live binding from callable refs
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
liveCircle:([] x:enlist {mx}; y:enlist {my}; r:enlist 10f);
.raylib.circle liveCircle;
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
liveDedupe:([] x:enlist {mx}; y:enlist {my}; r:enlist 8f);
.raylib.circle liveDedupe;
.raylib.circle liveDedupe;
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

