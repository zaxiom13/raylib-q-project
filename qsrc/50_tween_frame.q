.raylib._easeLinear:{[u]
  :u
 };

.raylib._easeInQuad:{[u]
  :u*u
 };

.raylib._easeOutQuad:{[u]
  :1f-(1f-u)*(1f-u)
 };

.raylib._easeInOutQuad:{[u]
  :$[u<0.5f;2f*u*u;1f-((-2f*u+2f)*(-2f*u+2f))%2f]
 };

.raylib._easeFns:`linear`inQuad`outQuad`inOutQuad!(
  .raylib._easeLinear;
  .raylib._easeInQuad;
  .raylib._easeOutQuad;
  .raylib._easeInOutQuad
 );

.raylib._easeUsage:"usage: easing must be one of `linear`inQuad`outQuad`inOutQuad (see .raylib.easings[])";

.raylib.easings:{[]
  :key .raylib._easeFns
 };

.raylib._easeFn:{[easing]
  usage:.raylib._easeUsage;
  sym:$[-11h=type easing;easing;`$string easing];
  if[not sym in key .raylib._easeFns; 'usage];
  :.raylib._easeFns sym
 };

.raylib._tweenProgress:{[steps]
  n:"i"$steps;
  if[n<1i; '"steps"];
  :("f"$til 1+n)%("f"$n)
 };

.raylib._isNumericAtom:{[x]
  t:type x;
  if[t>0h; :0b];
  t:0h-t;
  :any ("i"$t)=/:1 4 5 6 7 8 9
 };

.raylib._isNumericList:{[x]
  t:type x;
  if[t<0h; :0b];
  :any ("i"$t)=/:1 4 5 6 7 8 9
 };

.raylib._castLike:{[vals;atom]
  t:abs type atom;
  ti:"i"$t;
  if[ti=1; :0<"i"$vals];
  if[any ti=/:4 5 6 7; :"i"$floor vals];
  if[ti=8; :"e"$vals];
  if[ti=9; :"f"$vals];
  :vals
 };

.raylib._tweenCol:{[a;b;eased]
  if[.raylib._isNumericAtom[a]&.raylib._isNumericAtom[b];
    raw:("f"$a)+(("f"$b)-("f"$a))*eased;
    :.raylib._castLike[raw;a]];
  if[.raylib._isNumericList[a]&.raylib._isNumericList[b]&count a~count b;
    interp:{[aa;bb;u] ("f"$aa)+(("f"$bb)-("f"$aa))*u};
    raw:interp[a;b] each eased;
    :(.raylib._castLike[;a]) each raw];
  :$[a~b;(count eased)#enlist a;(((count eased)-1)#enlist a),enlist b]
 };

.raylib.tween.table:{[from;to;duration;steps;easing]
  usage:"usage: .raylib.tween.table[from;to;duration;steps;easing] where from/to are 1-row tables with same columns";
  ef:.[.raylib._requireTable;enlist from;{x}];
  if[10h=type ef; 'usage];
  et:.[.raylib._requireTable;enlist to;{x}];
  if[10h=type et; 'usage];
  if[(count from)<>1i; 'usage];
  if[(count to)<>1i; 'usage];
  c:cols from;
  if[not c~cols to; 'usage];
  dur:"f"$duration;
  if[not dur>0f; 'usage];
  p:.[.raylib._tweenProgress;enlist steps;{x}];
  if[10h=type p; 'usage];
  ease:.raylib._easeFn easing;
  eased:ease each p;
  vals:();
  i:0;
  while[i<count c;
    col:c i;
    vals,:enlist .raylib._tweenCol[from[col] 0;to[col] 0;eased];
    i+:1];
  out:flip c!vals;
  if[not `rate in cols out;
    out[`rate]:(count out)#enlist dur%("f"$steps);
   ];
  :out
 };

.raylib.keyframesTable:{[kf;fps;easing]
  usage:"usage: .raylib.keyframesTable[kf;fps;easing] where kf is a table with required `at` column in seconds";
  et:.[.raylib._requireTable;enlist kf;{x}];
  if[10h=type et; 'usage];
  if[not `at in cols kf; 'usage];
  hz:"f"$fps;
  if[not hz>0f; 'usage];
  k:`at xasc kf;
  keep:(cols k) except `at;
  n:count k;
  if[n<1; :k];
  if[n=1;
    out:k[;keep];
    if[not `rate in cols out;
      out[`rate]:(count out)#enlist 1f%hz];
    :out];
  ats:"f"$k[`at];
  if[any 0f>=(1_ats)-(-1_ats); 'usage];
  parts:();
  i:0;
  while[i<n-1;
    da:k i;
    db:k i+1;
    a:flip keep!enlist each da keep;
    b:flip keep!enlist each db keep;
    dur:(ats i+1)-(ats i);
    st:"i"$ceiling dur*hz;
    if[st<1i; st:1i];
    seg:.raylib.tween.table[a;b;dur;st;easing];
    if[i>0; seg:1_ seg];
    parts,:enlist seg;
    i+:1];
  :raze parts
 };

.raylib.frame.dt:1f%60f;
.raylib.frame.autoRefresh:0b;
.raylib.frame._callbacks:.raylib._callbacks.empty[];
.raylib.frame._nextId:0i;
.raylib.frame._state:`frame`time`dt!(0i;0f;.raylib.frame.dt);

.raylib.frame.reset:{
  .raylib.frame._state:`frame`time`dt!(0i;0f;.raylib.frame.dt);
  :.raylib.frame._state
 };

.raylib.frame.setDt:{[seconds]
  usage:"usage: .raylib.frame.setDt[seconds] where seconds>0";
  s:"f"$seconds;
  if[not s>0f; 'usage];
  .raylib.frame.dt:s;
  .raylib.frame._state[`dt]:s;
  :s
 };

.raylib.frame.on:{[fn]
  :.raylib._callbacks.on[`.raylib.frame._callbacks;`.raylib.frame._nextId;fn]
 };

.raylib.each.frame:{[fn]
  usage:"usage: .raylib.each.frame[{...}]";
  t:"i"$type fn;
  if[not t in 100 101 102 103 104; 'usage];
  :.raylib.frame.on {[state;cb] cb[]}[;fn]
 };

.raylib.frame.off:{[id]
  :.raylib._callbacks.off[`.raylib.frame._callbacks;id;"usage: .raylib.frame.off[id] or .raylib.frame.off[idList]"]
 };

.raylib.frame.clear:{
  :.raylib._callbacks.clear[`.raylib.frame._callbacks]
 };

.raylib.frame.tick:{
  s:.raylib.frame._state;
  dt:.raylib.frame.dt;
  nxt:`frame`time`dt!((s`frame)+1i;(s`time)+dt;dt);
  .raylib.frame._state:nxt;
  .raylib._callbacks.dispatch[.raylib.frame._callbacks;nxt];
  if[.raylib.frame.autoRefresh; .raylib.refresh[]];
  :nxt
 };

.raylib.frame.step:{[steps]
  usage:"usage: .raylib.frame.step[steps] where steps>=0";
  n:"i"$steps;
  if[n<0i; 'usage];
  out:.raylib.frame._state;
  i:0;
  while[i<n;
    out:.raylib.frame.tick[];
    i+:1];
  :out
 };

.raylib.frame.run:{[steps]
  usage:"usage: .raylib.frame.run[steps] where steps>=0";
  n:"i"$steps;
  if[n<0i; 'usage];
  out:.raylib.frame._state;
  i:0;
  while[i<n;
    out:.raylib.frame.tick[];
    .raylib._runCmd raze ("sleep ";string "f"$.raylib.frame.dt);
    i+:1];
  :out
 };

/ Clear all drawn shapes.
.raylib.clear:{
  .raylib._ensureReady[];
  :.raylib._sendMsg .raylib._cmd[`clear;()]
 };

/ Close renderer window.
.raylib.close:{
  wasinteractive:.raylib.interactive.active;
  shouldclose:.raylib._runtimeOpen|wasinteractive;
  if[.raylib.interactive.active;
    .raylib.interactive._stop[]];
  .raylib.autoPump.stop[];
  if[shouldclose; .raylib.transport.close[]];
  .raylib._runtimeOpen:0b;
  :1b
 };

/ Scene API: upsert/delete object sources by id, then redraw via refresh.
