/ Global q init that exposes raylib window helpers in every session.

.raylib.execPath:$[-11h=type getenv`RAYLIB_Q_WINDOW_BIN;string getenv`RAYLIB_Q_WINDOW_BIN;getenv`RAYLIB_Q_WINDOW_BIN];
if[0=count .raylib.execPath; .raylib.execPath:"/Users/zak1726/.kx/bin/raylib_q_window"];
.raylib.transport.mode:`native;
.raylib.transport.cmdPrefix:"RAYLIB_Q_CMD ";
.raylib.init.version:"2026.02.11";
.raylib.runtime.expectedVersion:.raylib.init.version;
.raylib.runtime.version:"";
.raylib.noop.notify:1b;
.raylib.noop.count:0i;
.raylib.noop.lastMsg:"";
.raylib.noop.lastTs:0Np;

.raylib._noop:{[msg;ret]
  txt:raze string msg;
  .raylib.noop.count+:1i;
  .raylib.noop.lastMsg:txt;
  .raylib.noop.lastTs:.z.p;
  if[.raylib.noop.notify;
    -1 raze ("raylib-q: no-op - ",txt)];
  :ret
 };

.raylib._runCmd:{[cmd]
  :system cmd
 };

.raylib.transport._emitLine:{[line]
  -1 line;
  :1b
 };

.raylib._drawTargetCurrent:{[]
  t:.[value;enlist `.draw.target.current;{`raylib}];
  if[-11h<>type t; :`raylib];
  :t
 };

.raylib._drawTargetIsNative:{[]
  :.raylib._drawTargetCurrent[]~`raylib
 };

.raylib.native.loaded:0b;
.raylib.native._initFn:{[x] x};
.raylib.native._submitFn:{[x] x};
.raylib.native._pumpFn:{[x] x};
.raylib.native._pollEventsFn:{[x] ""};
.raylib.native._clearEventsFn:{[x] 0};
.raylib.native._closeFn:{[x] 0};
.raylib.native._isOpenFn:{[x] 0b};
.raylib.native._versionFn:{[x] ""};
.raylib.native.init:{[]
  :.raylib.native._initFn 0N
 };
.raylib.native.submit:{[body]
  :.raylib.native._submitFn body
 };
.raylib.native.pump:{[]
  :.raylib.native._pumpFn 0N
 };
.raylib.native.pollEvents:{[]
  :.raylib.native._pollEventsFn 0N
 };
.raylib.native.clearEvents:{[]
  :.raylib.native._clearEventsFn 0N
 };
.raylib.native.close:{[]
  :.raylib.native._closeFn 0N
 };
.raylib.native.isOpen:{[]
  :.raylib.native._isOpenFn 0N
 };
.raylib.native.version:{[]
  :raze string .raylib.native._versionFn 0N
 };

.raylib.native._load:{
  if[.raylib.native.loaded; :1b];
  ok:.[{[dummy]
      .raylib.native._initFn:(`raylib_q_runtime 2:(`rq_init;1));
      .raylib.native._submitFn:(`raylib_q_runtime 2:(`rq_submit;1));
      .raylib.native._pumpFn:(`raylib_q_runtime 2:(`rq_pump;1));
      .raylib.native._pollEventsFn:(`raylib_q_runtime 2:(`rq_poll_events;1));
      .raylib.native._clearEventsFn:(`raylib_q_runtime 2:(`rq_clear_events;1));
      .raylib.native._closeFn:(`raylib_q_runtime 2:(`rq_close;1));
      .raylib.native._isOpenFn:(`raylib_q_runtime 2:(`rq_is_open;1));
      .raylib.native._versionFn:(`raylib_q_runtime 2:(`rq_version;1));
      :1b};enlist 0;{0b}];
  .raylib.native.loaded:ok;
  if[ok;
    .raylib.runtime.version:.raylib.native.version[]];
  :ok
 };

.raylib.transport.open:{[]
  if[not .raylib._drawTargetIsNative[]; :1b];
  if[not .raylib.native._load[]; :.raylib._noop["native runtime unavailable; open skipped";0]];
  :.raylib.native.init[]
 };

.raylib.transport.submit:{[body]
  if[not .raylib._drawTargetIsNative[];
    i:0;
    while[i<count body;
      .raylib.transport._emitLine raze (.raylib.transport.cmdPrefix;.raylib._cmdToText body i);
      i+:1];
    :1b];
  if[not .raylib.native._load[]; :.raylib._noop["native runtime unavailable; submit skipped";0]];
  .raylib.native.submit body;
  :.raylib.native.pump[]
 };

.raylib.transport.pump:{[]
  if[not .raylib._drawTargetIsNative[]; :1b];
  if[.raylib.native._load[]; :.raylib.native.pump[]];
  :0
 };

.raylib.transport.events.poll:{[]
  if[not .raylib._drawTargetIsNative[];
    ep:.[value;enlist `.electron.events.poll;{`missing}];
    if[not `missing~ep; :.[ep;();{""}]];
    :""];
  if[not .raylib.native._load[]; :.raylib._noop["native runtime unavailable; poll events skipped";""]];
  .raylib.native.pump[];
  :.raylib.native.pollEvents[]
 };

.raylib.transport.events.clear:{[]
  if[not .raylib._drawTargetIsNative[];
    .[set;enlist `.electron.eventBlob;""];
    :0];
  if[.raylib.native._load[]; :.raylib.native.clearEvents[]];
  :.raylib._noop["native runtime unavailable; clear events skipped";0]
 };

.raylib.transport.close:{[]
  if[not .raylib._drawTargetIsNative[];
    .raylib.transport._emitLine raze (.raylib.transport.cmdPrefix;"CLOSE");
    :1b];
  if[.raylib.native._load[]; :.raylib.native.close[]];
  :.raylib._noop["native runtime unavailable; close skipped";0]
 };

.raylib._timer.capture:{[]
  rawTimer:system "t";
  prevTimer:.[{"i"$x};enlist rawTimer;{0i}];
  prevTs:.[value;enlist `.z.ts;{`raylibNoTs}];
  :`timerMs`hadTs`ts!(prevTimer;not prevTs~`raylibNoTs;prevTs)
 };

.raylib._timer.restore:{[state]
  system "t ",string state`timerMs;
  if[state`hadTs;
    .z.ts:state`ts;
   ;
    .z.ts:{[]::}];
  :0b
 };

.raylib.autoPump.enabled:1b;
.raylib.autoPump._env:$[-11h=type getenv`RAYLIB_Q_AUTO_PUMP;`$lower string getenv`RAYLIB_Q_AUTO_PUMP;`];
if[.raylib.autoPump._env in `0`false`off`no; .raylib.autoPump.enabled:0b];
.raylib.autoPump.suspend:0b;
.raylib.autoPump.active:0b;
.raylib.autoPump._timerOwned:0b;
.raylib.autoPump._timerState:`timerMs`hadTs`ts!(0i;0b;{[]::});
.raylib._runtimeOpen:0b;

.raylib._onFirstOpen:{
  sreset:.[value;enlist `.raylib.scene.reset;{`missing}];
  if[`missing~sreset; :0b];
  oldAuto:.raylib.scene.autoRefresh;
  .raylib.scene.autoRefresh:0b;
  sreset[];
  .raylib.scene.autoRefresh:oldAuto;
  :1b
 };

.raylib._flag:{[x]
  if[10h=type x; :0<count x];
  if[-11h=type x; :1b];
  :.[{0<>"i"$x};enlist x;{0b}]
 };

.raylib.autoPump.stop:{
  .raylib.autoPump.active:0b;
  if[.raylib.autoPump._timerOwned;
    .raylib._timer.restore .raylib.autoPump._timerState];
  .raylib.autoPump._timerOwned:0b;
  :0b
 };

.raylib.autoPump._tick:{
  if[not .raylib.autoPump.active; :0b];
  ok:.raylib.transport.pump[];
  if[not ok;
    .raylib.autoPump.stop[];
    :0b];
  :1b
 };

.raylib.autoPump.ensure:{
  if[not .raylib.autoPump.enabled; :0b];
  if[.raylib.autoPump.active; :1b];
  state:.raylib._timer.capture[];
  if[(state`timerMs)<>0i; :0b];
  .raylib.autoPump._timerState:state;
  .z.ts:{[].raylib.autoPump._tick[];::};
  system "t 16";
  .raylib.autoPump._timerOwned:1b;
  .raylib.autoPump.active:1b;
  :1b
 };

.raylib.open:{
  if[.raylib._runtimeOpen;
    if[not .raylib.autoPump.suspend;
      .raylib.autoPump.ensure[]];
    :1b];
  ok:.raylib.transport.open[];
  okb:.raylib._flag ok;
  if[okb;
    .raylib._runtimeOpen:1b;
    .raylib._onFirstOpen[];
    if[not .raylib.autoPump.suspend;
      .raylib.autoPump.ensure[]]];
  :okb
 };

.raylib.start:{:.raylib.open[]};

.raylib.Color.RED:255 0 0 255i;
.raylib.Color.GREEN:0 180 0 255i;
.raylib.Color.BLUE:0 121 241 255i;
.raylib.Color.YELLOW:253 249 0 255i;
.raylib.Color.ORANGE:255 161 0 255i;
.raylib.Color.PURPLE:200 122 255 255i;
.raylib.Color.WHITE:255 255 255 255i;
.raylib.Color.BLACK:0 0 0 255i;
.raylib.Color.MAROON:190 33 55 255i;
.raylib.Color.GRAY:130 130 130 255i;
.raylib.Color.DARKGRAY:80 80 80 255i;
.raylib.Color.LIGHTGRAY:200 200 200 255i;
.raylib.Color.SKYBLUE:135 206 235 255i;
.raylib.Color.CYAN:0 255 255 255i;
.raylib.Color.MAGENTA:255 0 255 255i;
.raylib.Color.PINK:255 175 209 255i;
.raylib.Color.LIME:0 255 0 255i;
.raylib.Color.NAVY:0 0 128 255i;
.raylib.Color.TEAL:0 128 128 255i;
.raylib.Color.OLIVE:128 128 0 255i;
.raylib.Color.GOLD:255 215 0 255i;
.raylib.Color.SILVER:192 192 192 255i;
.raylib.Color.TRANSPARENT:0 0 0 0i;

.raylib._colorUsage:"usage: color must be RGB/RGBA int vector (e.g. 255 0 0 or 255 0 0 255) or one of .raylib.Color.* (see .raylib.colors[])";
.raylib._colorTable:([] name:`RED`GREEN`BLUE`YELLOW`ORANGE`PURPLE`WHITE`BLACK`MAROON`GRAY`DARKGRAY`LIGHTGRAY`SKYBLUE`CYAN`MAGENTA`PINK`LIME`NAVY`TEAL`OLIVE`GOLD`SILVER`TRANSPARENT; rgba:(.raylib.Color.RED;.raylib.Color.GREEN;.raylib.Color.BLUE;.raylib.Color.YELLOW;.raylib.Color.ORANGE;.raylib.Color.PURPLE;.raylib.Color.WHITE;.raylib.Color.BLACK;.raylib.Color.MAROON;.raylib.Color.GRAY;.raylib.Color.DARKGRAY;.raylib.Color.LIGHTGRAY;.raylib.Color.SKYBLUE;.raylib.Color.CYAN;.raylib.Color.MAGENTA;.raylib.Color.PINK;.raylib.Color.LIME;.raylib.Color.NAVY;.raylib.Color.TEAL;.raylib.Color.OLIVE;.raylib.Color.GOLD;.raylib.Color.SILVER;.raylib.Color.TRANSPARENT));

.raylib.colors:{[]
  :.raylib._colorTable
 };

.raylib._requireTable:{[t]
  if[not any (type t)=98 99; '"type"];
  :1b
 };

.raylib._requireCols:{[t;required]
  c:cols t;
  if[not all (required in c); '"cols"];
  :1b
 };

.raylib._ensureReady:{
  .raylib.open[];
  :1b
 };

.raylib._rgba4:{[color]
  usage:.raylib._colorUsage;
  t:type color;
  if[t<0h; 'usage];
  ti:"i"$t;
  if[not any ti=/:1 4 5 6 7 8 9; 'usage];
  vals:"i"$color;
  n:count vals;
  if[n=3; :0i | 255i & (vals,255i)];
  if[n=4; :0i | 255i & vals];
  'usage
 };

.raylib._colorAt:{[t;i;default]
  clr:$[`color in cols t; t[`color] i; default];
  c:.raylib._rgba4 clr;
  if[`alpha in cols t;
    c[3]:.raylib._clampByte t[`alpha] i];
  :c
 };

.raylib._safeText:{[txt]
  :raze string txt
 };
