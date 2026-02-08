system "t 0";
.z.ts:{[x]::};
\l raylib_q_init.q

/ ----------------------------------------------------------------------
/ Mock transport setup (headless: no window/GPU)
/ ----------------------------------------------------------------------
.raylib.transport.open:{:1b};
.raylib.transport.close:{:1b};
.raylib.open:{:0};
msgs:();
cmds:();
.raylib._runCmd:{[cmd] cmds,:enlist cmd; :0};
.raylib._sendMsg:{[msg] msgs,:enlist .raylib._cmdToText msg; :0};
eventBlob:"";
.raylib.transport.events.poll:{:eventBlob};

/ ----------------------------------------------------------------------
/ Test harness helpers
/ ----------------------------------------------------------------------
snNames:();
snOk:0#0b;
snDetail:();

record:{[name;ok;detail]
  snNames,:enlist name;
  snOk,:enlist ok;
  snDetail,:enlist detail;
  :ok
 };

fail:{[msg]
  'msg
 };

assertTrue:{[cond;msg]
  if[not cond; fail msg];
  :1b
 };

assertEq:{[actual;expected;msg]
  numAtom:{[x]
    t:type x;
    if[t>=0h; :0b];
    :any ("i"$abs t)=/:1 4 5 6 7 8 9
   };
  same:$[numAtom actual & numAtom expected; ("f"$actual)=("f"$expected); actual~expected];
  if[not same;
    fail msg];
  :1b
 };

assertErr:{[f;args;msg]
  err:.[f;args;{x}];
  if[10h<>type err; fail msg, " expected error"];
  :1b
 };

countPrefix:{[pref]
  :sum ({[p;x] p~(count p)#x}[pref]) each msgs
 };

containsAny:{[needle]
  :any {0<count x ss needle} each msgs
 };

runSnippet:{[name;fn]
  res:.[{(`ok;x[])};enlist fn;{(`err;x)}];
  if[`err~first res;
    :record[name;0b;res 1]];
  :record[name;1b;""]
 };

printLine:{[parts]
  if[10h=type parts;
    -1 parts;
    :0];
  -1 raze parts;
  :0
 };

/ ----------------------------------------------------------------------
/ Lesson 5: Drawing Primitives
/ ----------------------------------------------------------------------
runSnippet["L5.Snippet5 default circles";{
  `msgs set ();
  t:([] x:100 200 300f; y:150 150 150f; r:20 30 25f);
  n:.raylib.circle t;
  assertEq[n;3;"circle row count"];
  assertEq[countPrefix "ADD_CIRCLE";3;"circle command count"];
  assertEq[msgs 0;"ADD_CIRCLE 100 150 20 0 121 241 255";"circle row 1"];
  assertEq[msgs 1;"ADD_CIRCLE 200 150 30 0 121 241 255";"circle row 2"];
  assertEq[msgs 2;"ADD_CIRCLE 300 150 25 0 121 241 255";"circle row 3"];
 }];

runSnippet["L5.Snippet5b custom colors";{
  `msgs set ();
  t:([] x:100 200f; y:150 180f; r:20 30f; color:(.raylib.Color.RED;.raylib.Color.GREEN));
  n:.raylib.circle t;
  assertEq[n;2;"circle row count"];
  assertEq[msgs 0;"ADD_CIRCLE 100 150 20 255 0 0 255";"red row"];
  assertEq[msgs 1;"ADD_CIRCLE 200 180 30 0 180 0 255";"green row"];
 }];

runSnippet["L5.Snippet6 generic draw rect";{
  `msgs set ();
  n:.raylib.draw[`rect;([] x:50 150f; y:50 100f; w:80 120f; h:40 60f)];
  assertEq[n;2;"rect row count"];
  assertEq[countPrefix "ADD_RECT";2;"rect command count"];
 }];

/ ----------------------------------------------------------------------
/ Lesson 6: Schema Validation
/ ----------------------------------------------------------------------
runSnippet["L6.Snippet9a missing required col";{
  assertErr[.raylib.circle;enlist ([] x:enlist 10f; y:enlist 20f);"missing r should error"];
 }];

runSnippet["L6.Snippet9b extra cols tolerated";{
  `msgs set ();
  n:.raylib.circle ([] x:enlist 10f; y:enlist 20f; r:enlist 5f; velocity:enlist 3f);
  assertEq[n;1;"row count"];
  assertEq[msgs 0;"ADD_CIRCLE 10 20 5 0 121 241 255";"still draws"];
 }];

runSnippet["L6.Snippet9c bad color format";{
  assertErr[.raylib.circle;enlist ([] x:enlist 10f; y:enlist 20f; r:enlist 5f; color:enlist 255 0i);"bad color should error"];
 }];

/ ----------------------------------------------------------------------
/ Lesson 7: Scene Management
/ ----------------------------------------------------------------------
runSnippet["L7.Snippet10 scene lifecycle";{
  auto:.raylib.scene.autoRefresh;
  .raylib.scene.autoRefresh:0b;
  .raylib.scene.reset[];

  bg:([] x:enlist 0f; y:enlist 0f; w:enlist 800f; h:enlist 480f; color:enlist 230 230 230 255i);
  player:([] x:enlist 100f; y:enlist 200f; r:enlist 20f; color:enlist .raylib.Color.RED);
  hud:([] x:enlist 10f; y:enlist 10f; text:enlist "Score: 0"; size:enlist 24i);

  .raylib.scene.rect[`bg;bg];
  .raylib.scene.circle[`player;player];
  .raylib.scene.text[`hud;hud];
  assertEq[count .raylib.scene._rows;3;"added 3 scene rows"];

  player[`x]:enlist 200f;
  .raylib.scene.circle[`player;player];
  pidx:first where .raylib.scene._rows[`id]=`player;
  assertEq[((.raylib.scene._rows[`src] pidx)`x) 0;200f;"player updated"];

  .raylib.scene.visible[`hud;0b];
  hidx:first where .raylib.scene._rows[`id]=`hud;
  assertEq[.raylib.scene._rows[`visible] hidx;0b;"hud hidden"];

  .raylib.scene.delete `bg;
  assertEq[count .raylib.scene._rows;2;"bg deleted"];

  `msgs set ();
  n:.raylib.refresh[];
  assertTrue[n>0;"refresh should draw"];
  assertEq[countPrefix "ADD_CIRCLE";1;"player circle rendered"];

  .raylib.scene.autoRefresh:auto;
 }];

runSnippet["L7.Snippet12 symbol refs rejected";{
  `msgs set ();
  `mx set 111f;
  `my set 222f;
  cursor:([] x:enlist `mx; y:enlist `my; r:enlist 10f);
  assertErr[.raylib.circle;enlist cursor;"symbol refs should error"];
 }];

runSnippet["L7.Snippet12b lambda refs draw-time";{
  `msgs set ();
  `mx set 100f;
  `my set 200f;
  dynamic:([] x:enlist {mx+10f}; y:enlist {my-5f}; r:enlist 15f);
  .raylib.circle dynamic;
  assertEq[msgs 0;"ADD_CIRCLE 110 195 15 0 121 241 255";"lambda draw 1"];
  `msgs set ();
  `mx set 1f;
  `my set 2f;
  .raylib.circle dynamic;
  assertEq[msgs 0;"ADD_CIRCLE 11 -3 15 0 121 241 255";"lambda draw 2"];
 }];

/ ----------------------------------------------------------------------
/ Lesson 8: Animation & Tweening
/ ----------------------------------------------------------------------
runSnippet["L8.Snippet13 animate.circle frames";{
  `msgs set ();
  frames:([] x:100 200 300f; y:200 100 200f; r:20 30 20f; rate:0.3 0.3 0.3f; interpolate:1 1 1b);
  n:.raylib.animate.circle frames;
  assertEq[n;3;"animate row count"];
  assertEq[countPrefix "ANIM_CIRCLE_CLEAR";1;"clear cmd"];
  assertEq[countPrefix "ANIM_CIRCLE_ADD";3;"add cmd count"];
  assertEq[countPrefix "ANIM_CIRCLE_PLAY";1;"play cmd"];
 }];

runSnippet["L8.Snippet14a tween.table frame count";{
  from:([] x:enlist 0f; y:enlist 0f; r:enlist 10f);
  to:([] x:enlist 400f; y:enlist 200f; r:enlist 30f);
  tween:.raylib.tween.table[from;to;1f;60;`inOutQuad];
  assertEq[count tween;61;"tween frame count"];
 }];

runSnippet["L8.Snippet14b keyframesTable frame count";{
  kf:([] at:0 0.5 1f; x:0 200 400f; y:0 100 0f; r:10 20 10f);
  frames:.raylib.keyframesTable[kf;60;`linear];
  assertEq[count frames;61;"keyframes frame count"];
 }];

runSnippet["L8.Snippet16 frame callbacks with step";{
  .raylib.frame.clear[];
  .raylib.frame.reset[];
  `ticks set 0i;
  id:.raylib.frame.on {[state] `ticks set (value `ticks)+1i; :state};
  out:.raylib.frame.step 120;
  assertEq[value `ticks;120i;"callback count"];
  assertEq[out`frame;120i;"frame count"];
  .raylib.frame.off id;
 }];

/ ----------------------------------------------------------------------
/ Lesson 9: Events
/ ----------------------------------------------------------------------
runSnippet["L9.Snippet18 events callback on/off";{
  .raylib.events.callbacks.clear[];
  `seen set 0i;
  id:.raylib.events.on {[ev] `seen set (value `seen)+count ev; :0};
  `eventBlob set "1|1000|mouse_move|10|20|0|0\n";
  ev:.raylib.events.pump[];
  assertEq[count ev;1;"event count"];
  assertEq[value `seen;1i;"callback fired"];

  .raylib.events.off id;
  `eventBlob set "2|1001|key_down|65|0|0|0\n";
  .raylib.events.pump[];
  assertEq[value `seen;1i;"callback removed"];
  .raylib.events.callbacks.clear[];
 }];

runSnippet["L9.Snippet20 timer capture/restore";{
  state:.raylib._timer.capture[];
  system "t 77";
  .z.ts:{[x] `changed};
  .raylib._timer.restore state;
  assertEq["i"$system "t";state`timerMs;"timer restored"];
  tsProbe:.[.z.ts;enlist 42;{x}];
  assertTrue[10h<>type tsProbe;"ts callable after restore"];
 }];

/ ----------------------------------------------------------------------
/ Lesson 10: UI
/ ----------------------------------------------------------------------
runSnippet["L10.Snippet21 ui.hit.rect booleans";{
  `mx set 50f;
  `my set 50f;
  `mpressed set 0b;
  `mbutton set -1i;
  hit:.raylib.ui.hit.rect ([] x:20 200f; y:30 20f; w:60 30f; h:40 20f);
  assertEq[count hit;2;"two rows"];
  assertEq[hit 0;1b;"first hit"];
  assertEq[hit 1;0b;"second miss"];
 }];

runSnippet["L10.Snippet22 ui.button commands";{
  `msgs set ();
  `mx set 50f;
  `my set 50f;
  `mpressed set 1b;
  `mbutton set 0i;
  n:.raylib.ui.button ([] x:enlist 20f; y:enlist 30f; w:enlist 100f; h:enlist 32f; label:enlist "Go");
  assertEq[n;1;"button rows"];
  assertTrue[count msgs>0;"button emitted commands"];
  assertTrue[any {0<count x ss "ADD_RECT"} each msgs;"button draws rect"];
  assertTrue[any {0<count x ss "ADD_TEXT"} each msgs;"button draws text"];
 }];

/ ----------------------------------------------------------------------
/ Lesson 11: Testing
/ ----------------------------------------------------------------------
runSnippet["L11.Snippet24 mock transport capture";{
  `msgs set ();
  .raylib.circle ([] x:enlist 10f; y:enlist 20f; r:enlist 5f);
  assertEq[count msgs;1;"captured one command"];
  assertEq[msgs 0;"ADD_CIRCLE 10 20 5 0 121 241 255";"captured command payload"];
 }];

/ ----------------------------------------------------------------------
/ Quick Reference: listed functions exist and are callable
/ ----------------------------------------------------------------------
runSnippet["QuickRef callable surface";{
  assertTrue[.raylib._isCallable .raylib.open;"open"];
  assertTrue[.raylib._isCallable .raylib.start;"start"];
  assertTrue[.raylib._isCallable .raylib.clear;"clear"];
  assertTrue[.raylib._isCallable .raylib.refresh;"refresh"];
  assertTrue[.raylib._isCallable .raylib.close;"close"];
  assertTrue[.raylib._isCallable .raylib.circle;"circle"];
  assertTrue[.raylib._isCallable .raylib.rect;"rect"];
  assertTrue[.raylib._isCallable .raylib.line;"line"];
  assertTrue[.raylib._isCallable .raylib.text;"text"];
  assertTrue[.raylib._isCallable .raylib.draw;"draw"];
  assertTrue[.raylib._isCallable .raylib.scene.circle;"scene.circle"];
  assertTrue[.raylib._isCallable .raylib.scene.upsertEx;"scene.upsertEx"];
  assertTrue[.raylib._isCallable .raylib.scene.set;"scene.set"];
  assertTrue[.raylib._isCallable .raylib.scene.delete;"scene.delete"];
  assertTrue[.raylib._isCallable .raylib.scene.visible;"scene.visible"];
  assertTrue[.raylib._isCallable .raylib.scene.list;"scene.list"];
  assertTrue[.raylib._isCallable .raylib.scene.reset;"scene.reset"];
  assertTrue[.raylib._isCallable .raylib.animate.circle;"animate.circle"];
  assertTrue[.raylib._isCallable .raylib.anim;"anim"];
  assertTrue[.raylib._isCallable .raylib.animate.apply;"animate.apply"];
  assertTrue[.raylib._isCallable .raylib.animate.stop;"animate.stop"];
  assertTrue[.raylib._isCallable .raylib.animate.start;"animate.start"];
  assertTrue[.raylib._isCallable .raylib.tween.table;"tween.table"];
  assertTrue[.raylib._isCallable .raylib.keyframesTable;"keyframesTable"];
  assertTrue[.raylib._isCallable .raylib.interactive.start;"interactive.start"];
  assertTrue[.raylib._isCallable .raylib.interactive.tick;"interactive.tick"];
  assertTrue[.raylib._isCallable .raylib.interactive.live.list;"interactive.live.list"];
  assertTrue[.raylib._isCallable .raylib.events.on;"events.on"];
  assertTrue[.raylib._isCallable .raylib.events.callbacks.clear;"events.callbacks.clear"];
  assertTrue[.raylib._isCallable .raylib.frame.on;"frame.on"];
  assertTrue[.raylib._isCallable .raylib.ui.frame;"ui.frame"];
  assertTrue[.raylib._isCallable .raylib.ui.buttonClick;"ui.buttonClick"];
  assertTrue[.raylib._isCallable .raylib.ui.slider;"ui.slider"];
  assertTrue[.raylib._isCallable .raylib.help;"help"];
  assertTrue[.raylib._isCallable .raylib.colors;"colors"];
  assertTrue[.raylib._isCallable .raylib.easings;"easings"];
 }];

/ ----------------------------------------------------------------------
/ Summary / exit code
/ ----------------------------------------------------------------------
total:count snNames;
failed:sum not snOk;
passed:total-failed;

-1 "";
-1 "Tutorial snippet results:";
-1 "  Per-snippet:";
ri:0;
while[ri<count snNames;
  s:snNames ri;
  ok:snOk ri;
  d:snDetail ri;
  $[ok;
    printLine ("    PASS ";s);
    printLine ("    FAIL ";s;" :: ";$[10h=type d;d;-3!d])];
  ri+:1];
-1 "  Passed: ",string passed;
-1 "  Failed: ",string failed;

if[failed>0;
  -1 "  Failing snippets:";
  bad:where not snOk;
  {printLine ("    - ";snNames x)} each bad;
  exit 1];

exit 0;
