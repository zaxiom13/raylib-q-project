/ Step 6: renderer -> q input event pipeline.

.raylib.events.path:getenv`RAYLIB_Q_EVENTS_PATH;
if[0=count .raylib.events.path; .raylib.events.path:"/Users/zak1726/.kx/raylib_q.events"];

.raylib.events._empty:{
  :flip `seq`time`type`a`b`c`d!(0#0j;0#0j;`symbol$();`int$();`int$();`int$();`int$())
 };

.raylib.events._parseLine:{[line]
  p:"|" vs line;
  if[(count p)<>7; :()];
  :`seq`time`type`a`b`c`d!("J"$p 0;"J"$p 1;`$p 2;"I"$p 3;"I"$p 4;"I"$p 5;"I"$p 6)
 };

.raylib.events.clear:{
  .raylib.transport.events.clear[];
  .raylib.events.last:.raylib.events._empty[];
  :.raylib.events.last
 };

.raylib.events.poll:{
  raw:.raylib.transport.events.poll[];
  if[0=count raw; :.raylib.events._empty[]];
  lines:$[10h=type raw; "\n" vs raw; raw];
  lines:lines where 0<count each lines;

  seq:0#0j;
  tim:0#0j;
  typ:`symbol$();
  a:`int$();
  b:`int$();
  c:`int$();
  d:`int$();

  i:0;
  while[i<count lines;
    rec:.raylib.events._parseLine lines i;
    if[99h=type rec;
      seq,:enlist rec`seq;
      tim,:enlist rec`time;
      typ,:enlist rec`type;
      a,:enlist rec`a;
      b,:enlist rec`b;
      c,:enlist rec`c;
      d,:enlist rec`d];
    i+:1];

  :flip `seq`time`type`a`b`c`d!(seq;tim;typ;a;b;c;d)
 };

.raylib.events._callbacks:.raylib._callbacks.empty[];
.raylib.events._nextId:0i;
.raylib.events.last:.raylib.events._empty[];

.raylib.events.on:{[fn]
  :.raylib._callbacks.on[`.raylib.events._callbacks;`.raylib.events._nextId;fn]
 };

.raylib.events.off:{[id]
  :.raylib._callbacks.off[`.raylib.events._callbacks;id;"usage: .raylib.events.off[id] or .raylib.events.off[idList]"]
 };

.raylib.events.callbacks.clear:{
  :.raylib._callbacks.clear[`.raylib.events._callbacks]
 };

.raylib.events.dispatch:{[ev]
  :.raylib._callbacks.dispatch[.raylib.events._callbacks;ev]
 };

.raylib.events.pump:{
  ev:.raylib.events.poll[];
  .raylib.events.last:ev;
  if[count ev;
    .raylib.events.dispatch ev];
  :ev
 };

.raylib.tick:{
  :.raylib.events.pump[]
 };

.raylib.interactive.active:0b;
.raylib.interactive.intervalMs:16f;
.raylib.interactive._timerMs:16i;
.raylib.interactive._ticksPerBeat:1i;
.raylib.interactive._timerState:`timerMs`hadTs`ts!(0i;0b;{[]::});
.raylib.interactive._isReplaying:0b;
.raylib.interactive.lastError:`;
.raylib.interactive._live:([] id:`int$(); kind:`symbol$(); src:());
.raylib.interactive._nextLive:0i;
.raylib.interactive.spinActive:0b;
.raylib.interactive._escKey:256i;
.raylib.interactive._timerOwned:0b;

.raylib.interactive._ensureMouseVars:{
  if[10h=type .[value;enlist `mx;{x}]; `mx set 0f];
  if[10h=type .[value;enlist `my;{x}]; `my set 0f];
  if[10h=type .[value;enlist `mdx;{x}]; `mdx set 0f];
  if[10h=type .[value;enlist `mdy;{x}]; `mdy set 0f];
  if[10h=type .[value;enlist `mwheel;{x}]; `mwheel set 0f];
  if[10h=type .[value;enlist `mbutton;{x}]; `mbutton set -1i];
  if[10h=type .[value;enlist `mpressed;{x}]; `mpressed set 0b];
  if[10h=type .[value;enlist `mkey;{x}]; `mkey set 0i];
  if[10h=type .[value;enlist `charcode;{x}]; `charcode set 0i];
  if[10h=type .[value;enlist `windowW;{x}]; `windowW set 800i];
  if[10h=type .[value;enlist `windowH;{x}]; `windowH set 450i];
  if[10h=type .[value;enlist `windowFocused;{x}]; `windowFocused set 1b];
  :1b
 };

.raylib.interactive._remember:{[kind;src]
  if[.raylib.interactive._isReplaying; :0N];
  s:.raylib.interactive._live;
  i:0;
  while[i<count s;
    if[(s[`kind] i)=kind;
      if[(s[`src] i)~src; :s[`id] i]];
    i+:1];
  sid:.raylib.interactive._nextLive;
  .raylib.interactive._nextLive+:1i;
  s,: ([] id:enlist sid; kind:enlist kind; src:enlist src);
  .raylib.interactive._live:s;
  :sid
 };

.raylib.interactive.live.clear:{
  .raylib.interactive._live:([] id:`int$(); kind:`symbol$(); src:());
  :0
 };

.raylib.interactive.live.list:{
  :select id,kind from .raylib.interactive._live
 };

.raylib.interactive._stop:{
  .raylib.interactive.active:0b;
  .raylib.interactive.spinActive:0b;
  .raylib.interactive._isReplaying:0b;
  if[.raylib.interactive._timerOwned;
    .raylib._timer.restore .raylib.interactive._timerState];
  .raylib.interactive._timerOwned:0b;
  :0b
 };

.raylib.interactive._boot:{[timerMode]
  if[.raylib.interactive.active; .raylib.interactive._stop[]];
  .raylib._ensureReady[];
  .raylib.interactive._ensureMouseVars[];
  .raylib.interactive._isReplaying:0b;
  .raylib.interactive.lastError:`;
  .raylib.interactive._timerOwned:timerMode;
  if[timerMode;
    .raylib.interactive._timerState:.raylib._timer.capture[];
    .z.ts:{[].raylib.interactive.tick[];::}];
  .raylib.interactive.active:1b;
  :1b
 };

.raylib.interactive._applyEvents:{[ev]
  i:0;
  while[i<count ev;
    typ:ev[`type] i;
    if[typ=`mouse_move;
      `mx set "f"$ev[`a] i;
      `my set "f"$ev[`b] i;
      `mdx set "f"$ev[`c] i;
      `mdy set "f"$ev[`d] i];
    if[typ=`mouse_state;
      `mx set "f"$ev[`a] i;
      `my set "f"$ev[`b] i;
      `mdx set "f"$ev[`c] i;
      `mdy set "f"$ev[`d] i];
    if[typ=`mouse_down;
      `mbutton set "i"$ev[`a] i;
      `mx set "f"$ev[`b] i;
      `my set "f"$ev[`c] i;
      `mpressed set 1b];
    if[typ=`mouse_up;
      `mbutton set "i"$ev[`a] i;
      `mx set "f"$ev[`b] i;
      `my set "f"$ev[`c] i;
      `mpressed set 0b];
    if[typ=`mouse_wheel;
      `mwheel set ("f"$ev[`a] i)%1000f;
      `mx set "f"$ev[`b] i;
      `my set "f"$ev[`c] i];
    if[typ=`key_down;
      `mkey set "i"$ev[`a] i;
      if[("i"$ev[`a] i)=.raylib.interactive._escKey;
        .raylib.interactive.spinActive:0b;
        .raylib.interactive.active:0b]];
    if[typ=`char_input;
      `charcode set "i"$ev[`a] i];
    if[typ=`window_resize;
      `windowW set "i"$ev[`a] i;
      `windowH set "i"$ev[`b] i];
    if[typ=`window_focus;
      `windowFocused set 0<"i"$ev[`a] i];
    if[typ=`window_close;
      .raylib.interactive.active:0b];
    i+:1];
  :ev
 };

.raylib.interactive._drawLive:{
  live:.raylib.interactive._live;
  if[0=count live; :0];
  i:0;
  while[i<count live;
    .raylib.scene._drawKind[live[`kind] i;live[`src] i];
    i+:1];
  :count live
 };

.raylib.interactive._redraw:{
  hasScene:count .raylib.scene._rows;
  hasLive:count .raylib.interactive._live;
  if[(hasScene+hasLive)=0; :0];
  .raylib._batch.begin[];
  redrawRes:.[{[hasLive]
      .raylib.clear[];
      s:.raylib.scene._rows;
      if[count s; .raylib.scene._drawVisibleOrdered s];
      if[hasLive; .raylib.interactive._drawLive[]];
      :0};enlist hasLive;{x}];
  if[10h=type redrawRes;
    .raylib._batch.abort[];
    'redrawRes];
  .raylib._batch.flush[];
  :hasScene+hasLive
 };

.raylib.interactive.tick:{
  if[not .raylib.interactive.active; :.raylib.events._empty[]];
  loops:.raylib.interactive._ticksPerBeat;
  ev:.raylib.events._empty[];
  i:0;
  while[i<loops;
    ev:.raylib.events.pump[];
    .raylib.interactive._applyEvents ev;
    if[not .raylib.interactive.active;
      .raylib.interactive._stop[];
      :ev];
    .raylib.interactive.lastError:`;
    tickRes:.[ {[dummy] .raylib.frame.tick[]};enlist 0;{x}];
    if[10h=type tickRes;
      .raylib.interactive.lastError:tickRes;
      .raylib.interactive._stop[];
      :ev];
    .raylib.interactive._isReplaying:1b;
    .[ {[dummy] .raylib.interactive._redraw[]};enlist 0;{
      .raylib.interactive.lastError:x;
      .raylib.interactive._isReplaying:0b;
      .raylib.interactive._stop[];
      :0}];
    .raylib.interactive._isReplaying:0b;
    i+:1];
  :ev
 };

.raylib.interactive.setInterval:{[ms]
  usage:"usage: .raylib.interactive.setInterval[ms] where ms>0 (supports fractional values)";
  v:"f"$ms;
  if[not v>0f; 'usage];
  timer:"i"$ceiling v;
  if[timer<1i; timer:1i];
  loops:$[v<1f; "i"$ceiling 1f%v; 1i];
  if[loops<1i; loops:1i];
  .raylib.interactive.intervalMs:v;
  .raylib.interactive._timerMs:timer;
  .raylib.interactive._ticksPerBeat:loops;
  if[.raylib.interactive.active & .raylib.interactive._timerOwned;
    system "t ",string timer];
  :v
 };

.raylib.interactive.mode:{[flag]
  usage:"usage: .raylib.interactive.mode[0|1]";
  on:"i"$flag;
  if[not any on=/:0 1; 'usage];
  if[on=1i;
    .raylib.autoPump.suspend:1b;
    if[.raylib.autoPump.active;
      .raylib.autoPump.stop[]];
    bootRes:.[{[dummy] .raylib.interactive._boot 1b};enlist 0;{x}];
    .raylib.autoPump.suspend:0b;
    if[10h=type bootRes;
      'bootRes];
    system "t ",string .raylib.interactive._timerMs;
    :1b];
  if[not .raylib.interactive.active; :0b];
  stopped:.raylib.interactive._stop[];
  .raylib.autoPump.ensure[];
  :stopped
 };

.raylib.interactive.spin:{[flag]
  usage:"usage: .raylib.interactive.spin[0|1] (safe timer mode alias: 1=start, 0=stop)";
  on:"i"$flag;
  if[not any on=/:0 1; 'usage];
  :$[on=1i; .raylib.interactive.mode 1; .raylib.interactive.mode 0]
 };

.raylib.interactive.start:{
  :.raylib.interactive.mode 1
 };

.raylib.interactive.stop:{
  :.raylib.interactive.mode 0
 };

.raylib.dev.interactive.mode:.raylib.interactive.mode;
.raylib.dev.interactive.setInterval:.raylib.interactive.setInterval;
.raylib.interative.mode:.raylib.interactive.mode;
