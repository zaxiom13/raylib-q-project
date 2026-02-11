/ --- Test Group 10: Scene bindings & computed columns ---
.raylib.scene.reset[];
.raylib.scene.autoRefresh:0b;
msgs:();
playerX:100f; playerY:200f;
.raylib.scene.circle[`player;([] x:enlist {playerX}; y:enlist {playerY}; r:enlist 25f)];
.raylib.refresh[];
assertEq["binding resolves callable";0<count msgs[1] ss "100 200 25";1b];
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
/ scene id should track same-named table var updates without explicit .raylib.bind
orbits:([] x:100 140 180f; y:90 130 170f; r:12 8 8f);
.raylib.scene.circle[`orbits;orbits];
msgs:();
.raylib.refresh[];
assertEq["scene id tracks table initial";any {0<count x ss "ADD_CIRCLE 100 90 12"} each msgs;1b];
orbits[`x]:400 430 460f;
orbits[`y]:220 250 280f;
msgs:();
.raylib.refresh[];
assertEq["scene id tracks table latest";any {0<count x ss "ADD_CIRCLE 400 220 12"} each msgs;1b];
/ scene id can differ from mutable table name when src is passed as symbol
planetSrc:([] x:90 120 150f; y:70 80 90f; r:10 6 6f);
.raylib.scene.circle[`planets;`planetSrc];
msgs:();
.raylib.refresh[];
assertEq["scene symbol source initial";any {0<count x ss "ADD_CIRCLE 90 70 10"} each msgs;1b];
planetSrc[`x]:510 545 580f;
planetSrc[`y]:240 260 280f;
msgs:();
.raylib.refresh[];
assertEq["scene symbol source latest";any {0<count x ss "ADD_CIRCLE 510 240 10"} each msgs;1b];
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

/ --- Test Group 12: Complex numbers ---
assertCx:{[name;z;re;im]
  c:.cx.from z;
  assertEq[name,",re";c`re;re];
  assertEq[name,",im";c`im;im];
  :1b
 };
assertNear:{[name;actual;expected;eps]
  d:abs actual-expected;
  if[d>eps;
    failures,:enlist (name,": expected~",string expected," actual=",string actual)];
  :1b
 };
assertCxNear:{[name;z;re;im;eps]
  c:.cx.from z;
  assertNear[name,",re";c`re;re;eps];
  assertNear[name,",im";c`im;im;eps];
  :1b
 };
z:.cx.new[3;4];
assertCx["cx constructor";z;3f;4f];
assertCx["cx scalar coercion";.cx.from 5;5f;0f];
assertCx["cx pair coercion";.cx.from 5 6;5f;6f];
assertCx["cx dict coercion";.cx.from `re`im!(7;8);7f;8f];
assertCx["cx add";.cx.add[3 4;1 -2];4f;2f];
assertCx["cx sub";.cx.sub[3 4;1 -2];2f;6f];
assertCx["cx mul";.cx.mul[3 4;1 -2];11f;-2f];
assertCx["cx div";.cx.div[3 4;1 -2];-1f;2f];
assertCx["cx conj";.cx.conj 3 4;3f;-4f];
assertEq["cx abs";.cx.abs 3 4;5f];
assertEq["cx str";.cx.str 3 -4;"3 - 4i"];
assertCx["cx constants i";.cx.i;0f;1f];
assertEq["cx modulus alias";.cx.modulus 3 4;5f];
assertCx["cx floor";.cx.floor 3.9 -4.1;3f;-5f];
assertCx["cx ceil";.cx.ceil 3.1 -4.9;4f;-4f];
assertCx["cx round";.cx.round 3.6 -4.6;4f;-5f];
assertCx["cx frac";.cx.frac 3.75 -4.25;0.75f;0.75f];
assertCx["cx mod scalar";.cx.mod[5.5 -7.2;2f];1.5f;0.8f];
assertCx["cx mod component";.cx.mod[11 14;5 6];1f;2f];
assertNear["cx arg q1";.cx.arg 1 1;(acos -1f)%4f;0.00001f];
assertNear["cx arg q2";.cx.arg -1 1;3f*(acos -1f)%4f;0.00001f];
assertNear["cx arg down";.cx.arg 0 -1;(-1f)*(acos -1f)%2f;0.00001f];
assertCxNear["cx recip";.cx.recip 1 1;0.5f;-0.5f;0.00001f];
assertCxNear["cx normalize";.cx.normalize 3 4;0.6f;0.8f;0.00001f];
assertCxNear["cx fromPolar";.cx.fromPolar[2f;(acos -1f)%2f];0f;2f;0.0001f];
pz:.cx.polar 3 4;
assertNear["cx polar r";pz`r;5f;0.00001f];
assertNear["cx polar theta";pz`theta;atan 4f%3f;0.00001f];
assertCxNear["cx exp zero";.cx.exp 0 0;1f;0f;0.00001f];
assertCxNear["cx log one";.cx.log 1 0;0f;0f;0.00001f];
assertCxNear["cx pow i2";.cx.pow[0 1;2];-1f;0f;0.0002f];
assertCx["cx powEach scalar";.cx.powEach[3 4;2];9f;16f];
assertCx["cx powEach pair";.cx.powEach[2 3;3 2];8f;9f];
assertCxNear["cx sqrt -1";.cx.sqrt -1 0;0f;1f;0.0002f];
assertCxNear["cx sin zero";.cx.sin 0 0;0f;0f;0.00001f];
assertCxNear["cx cos zero";.cx.cos 0 0;1f;0f;0.00001f];
assertCxNear["cx tan zero";.cx.tan 0 0;0f;0f;0.00001f];
fnCxAdd:.[value;enlist `.cx.add;{`missing}];
assertEq["cx add callable";.raylib._isCallable fnCxAdd;1b];
errCxType:.[.cx.from;enlist "oops";{x}];
assertEq["cx invalid input error";10h=type errCxType;1b];
errCxDiv0:.[.cx.div;(1 2;0 0);{x}];
assertEq["cx div by zero error";errCxDiv0;"domain"];
errCxMod0:.[.cx.mod;(1 2;0f);{x}];
assertEq["cx mod by zero error";errCxMod0;"domain"];
errCxLog0:.[.cx.log;enlist 0 0;{x}];
assertEq["cx log zero error";errCxLog0;"domain"];

/ --- Test Group 13: Rayua crosswalk reference coverage ---
refLines:read0 `:docs/RAYUA_BINDINGS_REFERENCE.md;
beginHits:where refLines like "<!-- BEGIN_RAYUA_CROSSWALK -->";
endHits:where refLines like "<!-- END_RAYUA_CROSSWALK -->";
assertEq["ref begin marker exists";0<count beginHits;1b];
assertEq["ref end marker exists";0<count endHits;1b];
beginIdx:$[count beginHits;first beginHits;0Ni];
endIdx:$[count endHits;first endHits;0Ni];
body:$[(0=count beginHits)|(0=count endHits);();(1+beginIdx)_endIdx#refLines];
isBindingRow:{[ln]
  if[2>count ln; :0b];
  if[not "| "~2#ln; :0b];
  :0<count ln ss " | `"
 };
bindingRows:body where isBindingRow each body;
assertEq["ref binding row count";count bindingRows;159];
assertEq["ref first row is 1";first bindingRows like "| 1 |*";1b];
assertEq["ref last row is 159";last bindingRows like "| 159 |*";1b];
hasValidStatus:{[ln]
  :(ln like "*| Implemented |*") | (ln like "*| Partial |*") | (ln like "*| Missing |*") | (ln like "*| Implemented (native/emulated) |*") | (ln like "*| Implemented (stub/no-op) |*")
 };
assertEq["ref statuses valid";all hasValidStatus each bindingRows;1b];
assertEq["ref has at least one stub status";any bindingRows like "*| Implemented (stub/no-op) |*";1b];

/ --- Test Group 14: Compatibility surface ---
compatFns:.raylib.compat._bindings;
assertEq["compat binding count";count compatFns;159];
assertEq["compat usage count";count key .raylib.compat._usage;159];
docInitCompat:.raylib.help[`InitWindow];
assertEq["compat help has usage";docInitCompat like "*usage: .raylib.InitWindow*";1b];
errCompatArgs:.raylib.compat.call[`InitWindow;()];
assertEq["compat wrong argc uses usage";errCompatArgs;.raylib.compat._usage`InitWindow];
origEscKey:.raylib.interactive._escKey;
.raylib.HideCursor[];
assertEq["compat hide cursor updates state";.raylib.IsCursorHidden[];1b];
.raylib.ShowCursor[];
assertEq["compat show cursor updates state";.raylib.IsCursorHidden[];0b];
.raylib.SetTraceLogLevel 5;
assertEq["compat trace log state set";.raylib.compat._state`traceLog;5i];
.raylib.SetExitKey 123;
assertEq["compat exit key state set";.raylib.compat._state`exitKey;123i];
assertEq["compat exit key interactive esc set";.raylib.interactive._escKey;123i];
.raylib.interactive._escKey:origEscKey;
i:0;
while[i<count compatFns;
  nm:compatFns i;
  sym:`$".raylib.",string nm;
  fn:.[value;enlist sym;{`missing}];
  if[`missing~fn;
    failures,:enlist raze ("compat missing fn ";string nm);
   ;
    if[not .raylib._isCallable fn;
      failures,:enlist raze ("compat not callable ";string nm);
     ;
      argc:.raylib.compat._argCount nm;
      args:$[argc=0;();argc#enlist 0];
      r:.[fn;args;{`invokeError}];
      if[`invokeError~r;
        failures,:enlist raze ("compat invoke error ";string nm)]]];
  i+:1];

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
