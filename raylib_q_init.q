/ Global q init that exposes raylib window helpers in every session.

.raylib.execPath:$[-11h=type getenv`RAYLIB_Q_WINDOW_BIN;string getenv`RAYLIB_Q_WINDOW_BIN;getenv`RAYLIB_Q_WINDOW_BIN];
if[0=count .raylib.execPath; .raylib.execPath:"/Users/zak1726/.kx/bin/raylib_q_window"];
.raylib.transport.mode:`native;

.raylib._runCmd:{[cmd]
  :system cmd
 };

.raylib.native.loaded:0b;
.raylib.native._initFn:{[x] x};
.raylib.native._submitFn:{[x] x};
.raylib.native._pumpFn:{[x] x};
.raylib.native._pollEventsFn:{[x] ""};
.raylib.native._clearEventsFn:{[x] 0};
.raylib.native._closeFn:{[x] 0};
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

.raylib.native._load:{
  if[.raylib.native.loaded; :1b];
  ok:.[{[dummy]
      .raylib.native._initFn:(`raylib_q_runtime 2:(`rq_init;1));
      .raylib.native._submitFn:(`raylib_q_runtime 2:(`rq_submit;1));
      .raylib.native._pumpFn:(`raylib_q_runtime 2:(`rq_pump;1));
      .raylib.native._pollEventsFn:(`raylib_q_runtime 2:(`rq_poll_events;1));
      .raylib.native._clearEventsFn:(`raylib_q_runtime 2:(`rq_clear_events;1));
      .raylib.native._closeFn:(`raylib_q_runtime 2:(`rq_close;1));
      :1b};enlist 0;{0b}];
  .raylib.native.loaded:ok;
  :ok
 };

.raylib.transport.open:{[]
  if[not .raylib.native._load[]; :0];
  :.raylib.native.init[]
 };

.raylib.transport.submit:{[body]
  if[not .raylib.native._load[]; :0];
  .raylib.native.submit body;
  :.raylib.native.pump[]
 };

.raylib.transport.pump:{[]
  if[.raylib.native._load[]; :.raylib.native.pump[]];
  :0
 };

.raylib.transport.events.poll:{[]
  if[not .raylib.native._load[]; :""];
  .raylib.native.pump[];
  :.raylib.native.pollEvents[]
 };

.raylib.transport.events.clear:{[]
  if[.raylib.native._load[]; :.raylib.native.clearEvents[]];
  :0
 };

.raylib.transport.close:{[]
  if[.raylib.native._load[]; :.raylib.native.close[]];
  :0
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
  if[.raylib._runtimeOpen; :1b];
  ok:.raylib.transport.open[];
  okb:.raylib._flag ok;
  if[okb;
    .raylib._runtimeOpen:1b;
    .raylib._onFirstOpen[]];
  :okb
 };

.raylib.start:{:.raylib.open[]};

.raylib.window:.raylib.open;

.raylib.Color.RED:255 0 0 255i;
.raylib.Color.GREEN:0 180 0 255i;
.raylib.Color.BLUE:0 121 241 255i;
.raylib.Color.YELLOW:253 249 0 255i;
.raylib.Color.ORANGE:255 161 0 255i;
.raylib.Color.PURPLE:200 122 255 255i;
.raylib.Color.WHITE:255 255 255 255i;
.raylib.Color.BLACK:0 0 0 255i;
.raylib.Color.MAROON:190 33 55 255i;

.raylib._colorUsage:"usage: color must be RGB/RGBA int vector (e.g. 255 0 0 or 255 0 0 255) or one of .raylib.Color.RED|GREEN|BLUE|YELLOW|ORANGE|PURPLE|WHITE|BLACK|MAROON (see .raylib.colors[])";
.raylib._colorTable:([] name:`RED`GREEN`BLUE`YELLOW`ORANGE`PURPLE`WHITE`BLACK`MAROON; rgba:(.raylib.Color.RED;.raylib.Color.GREEN;.raylib.Color.BLUE;.raylib.Color.YELLOW;.raylib.Color.ORANGE;.raylib.Color.PURPLE;.raylib.Color.WHITE;.raylib.Color.BLACK;.raylib.Color.MAROON));

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


.raylib.shape.info:{[x]
  :$[0>type x;();(enlist count x),$[0=count x;();.raylib.shape.info first x]]
 };

.raylib.shape._rowStr:{[row]
  :" " sv string each row
 };

.raylib.shape._rowStrW:{[row;w]
  parts:();
  i:0;
  n:count row;
  while[i<n;
    parts,:enlist .raylib.shape._rpad[string row i;w];
    i+:1];
  :.raylib.shape._join[parts;" "]
 };

.raylib.shape._box2d:{[x]
  rows:.raylib.shape._rowStr each x;
  w:max count each rows;
  lines:enlist raze ("+";(2+w)#"-");
  i:0;
  n:count rows;
  while[i<n;
    lines,:enlist raze ("| ";.raylib.shape._rpad[rows i;w]);
    i+:1];
  :lines,enlist raze ("+";(2+w)#"-")
 };

.raylib.shape._box2dW:{[x;numw]
  rows:();
  i:0;
  n:count x;
  while[i<n;
    rows,:enlist .raylib.shape._rowStrW[x i;numw];
    i+:1];
  w:max count each rows;
  lines:enlist raze ("+";(2+w)#"-");
  i:0;
  while[i<n;
    lines,:enlist raze ("| ";.raylib.shape._rpad[rows i;w]);
    i+:1];
  :lines,enlist raze ("+";(2+w)#"-")
 };

.raylib.shape._spaces:{[n]
  :$[n<1;"";n#" "]
 };

.raylib.shape._rpad:{[s;w]
  d:w-count s;
  :$[d<1;s;s,.raylib.shape._spaces d]
 };

.raylib.shape._join:{[xs;sep]
  n:count xs;
  if[n=0; :""];
  out:first xs;
  i:1;
  while[i<n;
    out,:sep,xs i;
    i+:1];
  :out
 };

.raylib.shape._hcat:{[blocks;gap]
  nb:count blocks;
  if[0=nb; :()];
  h:max count each blocks;
  bw:{max count each x} each blocks;
  out:();
  li:0;
  while[li<h;
    parts:();
    bi:0;
    while[bi<nb;
      b:blocks bi;
      raw:$[li<count b; b li; ""];
      parts,:enlist .raylib.shape._rpad[raw;bw bi];
      bi+:1];
    out,:enlist .raylib.shape._join[parts;gap];
    li+:1];
  :out
 };

.raylib.shape._grid4d:{[x]
  shp:.raylib.shape.info x;
  r0:"i"$shp 0;
  r1:"i"$shp 1;
  vals:raze raze x;
  numw:max count each string each vals;
  rows:();
  colw:r1#0i;
  i:0;
  while[i<r0;
    row:();
    j:0;
    while[j<r1;
      cell:enlist raze ("slice[";string i;", ";string j;"]");
      cell,:.raylib.shape._box2dW[(x i) j;numw];
      row,:enlist cell;
      w:max count each cell;
      if[w>colw j; colw[j]:w];
      j+:1];
    rows,:enlist row;
    i+:1];
  lines:();
  i:0;
  while[i<r0;
    row:rows i;
    h:max count each row;
    li:0;
    while[li<h;
      parts:();
      j:0;
      while[j<r1;
        b:row j;
        raw:$[li<count b; b li; ""];
        parts,:enlist .raylib.shape._rpad[raw;colw j];
        j+:1];
      lines,:enlist .raylib.shape._join[parts;"   "];
      li+:1];
    if[i<r0-1; lines,:enlist ""];
    i+:1];
  :lines
 };

.raylib.shape._grid4dPath:{[x;prefix]
  shp:.raylib.shape.info x;
  r0:"i"$shp 0;
  r1:"i"$shp 1;
  vals:raze raze x;
  numw:max count each string each vals;
  rows:();
  colw:r1#0i;
  i:0;
  while[i<r0;
    row:();
    j:0;
    while[j<r1;
      idx:raze prefix,enlist i,enlist j;
      cell:enlist raze ("slice[";.raylib.shape._join[string each idx;", "];"]");
      cell,:.raylib.shape._box2dW[(x i) j;numw];
      row,:enlist cell;
      w:max count each cell;
      if[w>colw j; colw[j]:w];
      j+:1];
    rows,:enlist row;
    i+:1];
  lines:();
  i:0;
  while[i<r0;
    row:rows i;
    h:max count each row;
    li:0;
    while[li<h;
      parts:();
      j:0;
      while[j<r1;
        b:row j;
        raw:$[li<count b; b li; ""];
        parts,:enlist .raylib.shape._rpad[raw;colw j];
        j+:1];
      lines,:enlist .raylib.shape._join[parts;"   "];
      li+:1];
    if[i<r0-1; lines,:enlist ""];
    i+:1];
  :lines
 };

.raylib.shape._grid5d:{[x]
  shp:.raylib.shape.info x;
  d0:"i"$shp 0;
  d1:"i"$shp 1;
  d2:"i"$shp 2;
  lines:();
  k:0;
  while[k<d2;
    sub:();
    i:0;
    while[i<d0;
      row:();
      j:0;
      while[j<d1;
        row,:enlist (((x i) j) k);
        j+:1];
      sub,:enlist row;
      i+:1];
    lines,:enlist raze ("layer[";string k;"]");
    lines,:.raylib.shape._grid4dPath[sub;enlist k];
    if[k<d2-1;
      lines,:enlist "";
      lines,:enlist ""];
    k+:1];
  :lines
 };

.raylib.shape._prettyLines:{[x;path]
  shp:.raylib.shape.info x;
  r:count shp;
  if[r=0; :enlist string x];
  if[r=1; :.raylib.shape._box2d enlist x];
  if[r=2; :.raylib.shape._box2d x];
  if[r=4; :.raylib.shape._grid4d x];
  if[r=5; :.raylib.shape._grid5d x];
  lines:();
  i:0;
  n:"i"$shp 0;
  while[i<n;
    p:path,enlist i;
    sub:x i;
    sr:count .raylib.shape.info sub;
    if[sr=2;
      lines,:enlist raze ("slice[";", " sv string each p;"]");
      lines,:.raylib.shape._box2d sub;
      if[i<n-1; lines,:enlist ""]];
    if[sr<>2;
      lines,:.raylib.shape._prettyLines[sub;p]];
    i+:1];
  :lines
 };

.raylib.shape.pretty:{[x]
  shp:.raylib.shape.info x;
  hdr:raze ("shape ";$[0=count shp;"()";" " sv string each shp]);
  lines:enlist hdr;
  lines,:.raylib.shape._prettyLines[x;()];
  :"\n" sv lines
 };

.raylib.shape.show:{[x]
  out:.raylib.shape.pretty x;
  -1 out;
  ::
 };



.raylib._clampByte:{[v]
  iv:"i"$v;
  :$[iv<0i;0i;$[iv>255i;255i;iv]]
 };

.raylib._isCallable:{[v]
  :("i"$type v)>=100i
 };

.raylib._resolveRefVal:{[v;usage]
  if[-11h=type v;
    v:.[value;enlist v;{x}];
    if[10h=type v; 'usage]];
  if[.raylib._isCallable v;
    v:.[{x[]};enlist v;{x}];
    if[10h=type v; 'usage]];
  if[-11h=type v;
    v:.[value;enlist v;{x}];
    if[10h=type v; 'usage]];
  :v
 };

.raylib._expandResolvedSingleton:{[v;n;usage]
  tv:type v;
  if[tv<0h; :n#v];
  if[tv=0h;
    if[(count v)=n; :v];
    if[n=1; :enlist v];
    if[(count v)=1; :n#first v];
    'usage];
  if[(count v)=n; :v];
  if[n=1; :enlist v];
  if[(count v)=1; :n#first v];
  'usage
 };

.raylib._tableHasRefs:{[t]
  c:cols t;
  i:0;
  while[i<count c;
    vals:t[c i];
    j:0;
    while[j<count vals;
      if[(-11h=type vals j) | .raylib._isCallable vals j; :1b];
      j+:1];
    i+:1];
  :0b
 };

.raylib._resolveRefs:{[t;usage]
  et:.[.raylib._requireTable;enlist t;{x}];
  if[10h=type et; 'usage];
  c:cols t;
  d:()!();
  i:0;
  while[i<count c;
    col:c i;
    vals:t[col];
    n:count t;
    if[(count vals)=1;
      outVals:.raylib._expandResolvedSingleton[.raylib._resolveRefVal[first vals;usage];n;usage]];
    if[(count vals)<>1;
      outVals:();
      j:0;
      while[j<count vals;
        outVals,:enlist .raylib._resolveRefVal[vals j;usage];
        j+:1]];
    d[col]:outVals;
    i+:1];
  :flip d
 };

.raylib._pixelPayloadMeta:{[payload;usage]
  p:payload;
  shp:.raylib.shape.info p;
  if[(2=count shp)&(0h=type p);
    h:"i"$shp 0;
    w:"i"$shp 1;
    if[(h>0i)&(w>0i);
      flatGray:"i"$raze p;
      if[count flatGray=w*h; :`kind`data`w`h!(1i;flatGray;w;h)]]];
  flat:"i"$raze p;
  n:count flat;
  if[n<1i; 'usage];
  if[0=n mod 4; :`kind`data`w`h!(4i;flat;n div 4;1i)];
  if[0=n mod 3; :`kind`data`w`h!(3i;flat;n div 3;1i)];
  :`kind`data`w`h!(1i;flat;n;1i)
 };

.raylib._pixelDimsForRow:{[t;i;pmeta;usage]
  hasW:`w in cols t;
  hasH:`h in cols t;
  if[hasW<>hasH; 'usage];
  if[not hasW; :`w`h!("i"$pmeta`w;"i"$pmeta`h)];
  rw:"i"$t[`w] i;
  rh:"i"$t[`h] i;
  if[not ((rw>0i)&(rh>0i)); 'usage];
  if[(rw<>pmeta`w)|(rh<>pmeta`h); 'usage];
  :`w`h!(rw;rh)
 };

.raylib._pixelDestForRow:{[t;i;w;h;usage]
  hasScale:`scale in cols t;
  hasDw:`dw in cols t;
  hasDh:`dh in cols t;
  scale:$[hasScale;"f"$t[`scale] i;1f];
  dw:$[hasDw;"f"$t[`dw] i;("f"$w)*scale];
  dh:$[hasDh;"f"$t[`dh] i;("f"$h)*scale];
  if[not ((dw>0f)&(dh>0f)); 'usage];
  :`dw`dh!(dw;dh)
 };

.raylib._pixelAlphaForRow:{[t;i]
  hasAlpha:`alpha in cols t;
  :$[hasAlpha;.raylib._clampByte t[`alpha] i;255i]
 };

.raylib._pixelRateMsAt:{[t;i;usage]
  if[not `rate in cols t; :100i];
  r:"f"$t[`rate] i;
  if[not r>0f; 'usage];
  ms:"i"$1000f*r;
  if[ms<1i; :1i];
  :ms
 };

.raylib._pixelFramesMeta:{[payload;usage;forceFrames]
  p:payload;
  shp:.raylib.shape.info p;
  if[(0h=type p)&((count p)>0)&(forceFrames|(count shp)>2);
    frames:();
    i:0;
    while[i<(count p);
      pm:.raylib._pixelPayloadMeta[p i;usage];
      if[i=0;
        fw:"i"$pm`w;
        fh:"i"$pm`h];
      if[(("i"$pm`w)<>fw)|(("i"$pm`h)<>fh); 'usage];
      frames,:enlist pm;
      i+:1];
    :`animated`frames`w`h!(1b;frames;fw;fh)];
  pm:.[.raylib._pixelPayloadMeta;(p;usage);{x}];
  if[10h=type pm; 'usage];
  :`animated`frames`w`h!(0b;enlist pm;"i"$pm`w;"i"$pm`h)
 };

.raylib._drawOptionalCommon:`color`alpha`layer`rotation`stroke`fill;

.raylib._schemaValidate:{[t;required;optional;usage]
  et:.[.raylib._requireTable;enlist t;{x}];
  if[10h=type et; 'usage];
  c:cols t;
  if[not all required in c; 'usage];
  if[count c except (required,optional); 'usage];
  :1b
 };

.raylib._pixelUsage:"usage: .raylib.pixels[t] where t is a table with pixels x y (optional w,h,scale,dw,dh,alpha,rate,layer,rotation,stroke,fill). payload shape picks static vs looped animation";

.raylib._pixelRowMeta:{[t;i]
  usage:.raylib._pixelUsage;
  forceFrames:`rate in cols t;
  fmeta:.[.raylib._pixelFramesMeta;(t[`pixels] i;usage;forceFrames);{x}];
  if[10h=type fmeta; 'usage];
  p0:first fmeta`frames;
  dims:.[.raylib._pixelDimsForRow;(t;i;p0;usage);{x}];
  if[10h=type dims; 'usage];
  dest:.[.raylib._pixelDestForRow;(t;i;dims`w;dims`h;usage);{x}];
  if[10h=type dest; 'usage];
  alpha:.raylib._pixelAlphaForRow[t;i];
  rateMs:.[.raylib._pixelRateMsAt;(t;i;usage);{x}];
  if[10h=type rateMs; 'usage];
  :`animated`frames`w`h`dw`dh`alpha`rateMs!(fmeta`animated;fmeta`frames;dims`w;dims`h;dest`dw;dest`dh;alpha;rateMs)
 };

.raylib._pixelColorAt:{[pmeta;pixIdx;alphaMul]
  d:pmeta`data;
  k:pmeta`kind;
  base:$[k=1i;pixIdx;$[k=3i;3*pixIdx;4*pixIdx]];
  r:$[k=1i;d base;d base];
  g:$[k=1i;d base;d base+1];
  b:$[k=1i;d base;d base+2];
  a:$[k=4i;d base+3;255i];
  am:.raylib._clampByte alphaMul;
  aa:.raylib._clampByte ("i"$("f"$a)*("f"$am)%255f);
  :(.raylib._clampByte r;.raylib._clampByte g;.raylib._clampByte b;aa)
 };

.raylib.fillColor:{[t;clr]
  tc:t;
  if[-11h=type t;
    tc:value t];
  .raylib._requireTable[tc];
  colors:$[0h=type clr; .raylib._rgba4 each clr; enlist .raylib._rgba4 clr];
  if[0=count colors;
    '"usage: .raylib.fillColor[tOrSym;rgbaOrRgbaList]"];
  tc[`color]:(count tc)#colors;
  if[-11h=type t;
    t set tc];
  :tc
 };

.raylib._cmd:{[op;args]
  argl:$[0h=type args;args;enlist args];
  out:enlist (::);
  out,:enlist op;
  i:0;
  while[i<count argl;
    out,:enlist argl i;
    i+:1];
  :1_ out
 };

.raylib._fmtF:{[x]
  :string "f"$x
 };

.raylib._fmtI:{[x]
  :string "i"$x
 };

.raylib._cmdToText:{[cmd]
  usage:"usage: command must be a list: (`op;arg1;...)";
  op:`raylibUnsetOp;
  args:();
  if[0h=type cmd;
    if[(count cmd)<1; 'usage];
    op:first cmd;
    args:1_ cmd];
  if[11h=type cmd;
    if[(count cmd)<>1; 'usage];
    op:first cmd;
    args:()];
  if[-11h=type cmd;
    op:cmd;
    args:()];
  if[op~`raylibUnsetOp; 'usage];
  if[-11h<>type op; 'usage];
  if[op=`clear; :"CLEAR"];
  if[op=`close; :"CLOSE"];
  if[op=`ping; :"PING"];
  if[op=`eventDrain; :"EVENT_DRAIN"];
  if[op=`eventClear; :"EVENT_CLEAR"];
  if[op=`addTriangle; :raze ("ADD_TRIANGLE ";.raylib._fmtF args 0;" ";.raylib._fmtF args 1;" ";.raylib._fmtF args 2;" ";.raylib._fmtI args 3;" ";.raylib._fmtI args 4;" ";.raylib._fmtI args 5;" ";.raylib._fmtI args 6)];
  if[op=`addCircle; :raze ("ADD_CIRCLE ";.raylib._fmtF args 0;" ";.raylib._fmtF args 1;" ";.raylib._fmtF args 2;" ";.raylib._fmtI args 3;" ";.raylib._fmtI args 4;" ";.raylib._fmtI args 5;" ";.raylib._fmtI args 6)];
  if[op=`addSquare; :raze ("ADD_SQUARE ";.raylib._fmtF args 0;" ";.raylib._fmtF args 1;" ";.raylib._fmtF args 2;" ";.raylib._fmtI args 3;" ";.raylib._fmtI args 4;" ";.raylib._fmtI args 5;" ";.raylib._fmtI args 6)];
  if[op=`addRect; :raze ("ADD_RECT ";.raylib._fmtF args 0;" ";.raylib._fmtF args 1;" ";.raylib._fmtF args 2;" ";.raylib._fmtF args 3;" ";.raylib._fmtI args 4;" ";.raylib._fmtI args 5;" ";.raylib._fmtI args 6;" ";.raylib._fmtI args 7)];
  if[op=`addLine; :raze ("ADD_LINE ";.raylib._fmtF args 0;" ";.raylib._fmtF args 1;" ";.raylib._fmtF args 2;" ";.raylib._fmtF args 3;" ";.raylib._fmtF args 4;" ";.raylib._fmtI args 5;" ";.raylib._fmtI args 6;" ";.raylib._fmtI args 7;" ";.raylib._fmtI args 8)];
  if[op=`addPixel; :raze ("ADD_PIXEL ";.raylib._fmtF args 0;" ";.raylib._fmtF args 1;" ";.raylib._fmtI args 2;" ";.raylib._fmtI args 3;" ";.raylib._fmtI args 4;" ";.raylib._fmtI args 5)];
  if[op=`addText; :raze ("ADD_TEXT ";.raylib._fmtF args 0;" ";.raylib._fmtF args 1;" ";.raylib._fmtI args 2;" ";.raylib._fmtI args 3;" ";.raylib._fmtI args 4;" ";.raylib._fmtI args 5;" ";.raylib._fmtI args 6;" ";raze string args 7)];
  if[op=`animCircleClear; :"ANIM_CIRCLE_CLEAR"];
  if[op=`animCirclePlay; :"ANIM_CIRCLE_PLAY"];
  if[op=`animCircleStop; :"ANIM_CIRCLE_STOP"];
  if[op=`animTriangleClear; :"ANIM_TRIANGLE_CLEAR"];
  if[op=`animTrianglePlay; :"ANIM_TRIANGLE_PLAY"];
  if[op=`animTriangleStop; :"ANIM_TRIANGLE_STOP"];
  if[op=`animRectClear; :"ANIM_RECT_CLEAR"];
  if[op=`animRectPlay; :"ANIM_RECT_PLAY"];
  if[op=`animRectStop; :"ANIM_RECT_STOP"];
  if[op=`animLineClear; :"ANIM_LINE_CLEAR"];
  if[op=`animLinePlay; :"ANIM_LINE_PLAY"];
  if[op=`animLineStop; :"ANIM_LINE_STOP"];
  if[op=`animPointClear; :"ANIM_POINT_CLEAR"];
  if[op=`animPointPlay; :"ANIM_POINT_PLAY"];
  if[op=`animPointStop; :"ANIM_POINT_STOP"];
  if[op=`animTextClear; :"ANIM_TEXT_CLEAR"];
  if[op=`animTextPlay; :"ANIM_TEXT_PLAY"];
  if[op=`animTextStop; :"ANIM_TEXT_STOP"];
  if[op=`animPixelsClear; :"ANIM_PIXELS_CLEAR"];
  if[op=`animPixelsPlay; :"ANIM_PIXELS_PLAY"];
  if[op=`animPixelsStop; :"ANIM_PIXELS_STOP"];
  if[op=`animCircleAdd; :raze ("ANIM_CIRCLE_ADD ";.raylib._fmtF args 0;" ";.raylib._fmtF args 1;" ";.raylib._fmtF args 2;" ";.raylib._fmtI args 3;" ";.raylib._fmtI args 4;" ";.raylib._fmtI args 5;" ";.raylib._fmtI args 6;" ";.raylib._fmtI args 7;" ";.raylib._fmtI args 8)];
  if[op=`animTriangleAdd; :raze ("ANIM_TRIANGLE_ADD ";.raylib._fmtF args 0;" ";.raylib._fmtF args 1;" ";.raylib._fmtF args 2;" ";.raylib._fmtI args 3;" ";.raylib._fmtI args 4;" ";.raylib._fmtI args 5;" ";.raylib._fmtI args 6;" ";.raylib._fmtI args 7;" ";.raylib._fmtI args 8)];
  if[op=`animRectAdd; :raze ("ANIM_RECT_ADD ";.raylib._fmtF args 0;" ";.raylib._fmtF args 1;" ";.raylib._fmtF args 2;" ";.raylib._fmtF args 3;" ";.raylib._fmtI args 4;" ";.raylib._fmtI args 5;" ";.raylib._fmtI args 6;" ";.raylib._fmtI args 7;" ";.raylib._fmtI args 8;" ";.raylib._fmtI args 9)];
  if[op=`animLineAdd; :raze ("ANIM_LINE_ADD ";.raylib._fmtF args 0;" ";.raylib._fmtF args 1;" ";.raylib._fmtF args 2;" ";.raylib._fmtF args 3;" ";.raylib._fmtF args 4;" ";.raylib._fmtI args 5;" ";.raylib._fmtI args 6;" ";.raylib._fmtI args 7;" ";.raylib._fmtI args 8;" ";.raylib._fmtI args 9;" ";.raylib._fmtI args 10)];
  if[op=`animPointAdd; :raze ("ANIM_POINT_ADD ";.raylib._fmtF args 0;" ";.raylib._fmtF args 1;" ";.raylib._fmtI args 2;" ";.raylib._fmtI args 3;" ";.raylib._fmtI args 4;" ";.raylib._fmtI args 5;" ";.raylib._fmtI args 6;" ";.raylib._fmtI args 7)];
  if[op=`animTextAdd; :raze ("ANIM_TEXT_ADD ";.raylib._fmtF args 0;" ";.raylib._fmtF args 1;" ";.raylib._fmtI args 2;" ";.raylib._fmtI args 3;" ";.raylib._fmtI args 4;" ";.raylib._fmtI args 5;" ";.raylib._fmtI args 6;" ";.raylib._fmtI args 7;" ";.raylib._fmtI args 8;" ";raze string args 9)];
  if[op=`animPixelsRate; :raze ("ANIM_PIXELS_RATE ";.raylib._fmtI args 0)];
  if[op=`animPixelsAdd; :raze ("ANIM_PIXELS_ADD ";.raylib._fmtI args 0;" ";.raylib._fmtF args 1;" ";.raylib._fmtF args 2;" ";.raylib._fmtF args 3;" ";.raylib._fmtF args 4;" ";.raylib._fmtI args 5;" ";.raylib._fmtI args 6;" ";.raylib._fmtI args 7;" ";.raylib._fmtI args 8)];
  '"usage: unknown command op"
 };

.raylib._batchToText:{[cmds]
  if[0=count cmds; :""];
  :"\n" sv .raylib._cmdToText each cmds
 };

.raylib._sendMsg:{[cmd]
  if[not .raylib._batch.active;
    :.raylib._sendBatch enlist cmd];
  .raylib._batch.msgs,:enlist cmd;
  :0
 };

.raylib._batch.active:0b;
.raylib._batch.msgs:();

.raylib._sendBatch:{[msgs]
  if[0=count msgs; :0];
  :.raylib.transport.submit msgs
 };

.raylib._batch.begin:{
  .raylib._batch.active:1b;
  .raylib._batch.msgs:();
  :1b
 };

.raylib._batch.flush:{
  msgs:.raylib._batch.msgs;
  .raylib._batch.msgs:();
  .raylib._batch.active:0b;
  :.raylib._sendBatch msgs
 };

.raylib._batch.abort:{
  .raylib._batch.msgs:();
  .raylib._batch.active:0b;
  :0b
 };

.raylib._sendTriangle:{[x;y;r;color]
  c:.raylib._rgba4 color;
  :.raylib._sendMsg .raylib._cmd[`addTriangle;("f"$x;"f"$y;"f"$r;c 0;c 1;c 2;c 3)]
 };

.raylib._sendCircle:{[x;y;r;color]
  c:.raylib._rgba4 color;
  :.raylib._sendMsg .raylib._cmd[`addCircle;("f"$x;"f"$y;"f"$r;c 0;c 1;c 2;c 3)]
 };

.raylib._sendSquare:{[x;y;r;color]
  c:.raylib._rgba4 color;
  :.raylib._sendMsg .raylib._cmd[`addSquare;("f"$x;"f"$y;"f"$r;c 0;c 1;c 2;c 3)]
 };

.raylib._sendRect:{[x;y;w;h;color]
  c:.raylib._rgba4 color;
  :.raylib._sendMsg .raylib._cmd[`addRect;("f"$x;"f"$y;"f"$w;"f"$h;c 0;c 1;c 2;c 3)]
 };

.raylib._sendLine:{[x1;y1;x2;y2;thickness;color]
  c:.raylib._rgba4 color;
  :.raylib._sendMsg .raylib._cmd[`addLine;("f"$x1;"f"$y1;"f"$x2;"f"$y2;"f"$thickness;c 0;c 1;c 2;c 3)]
 };

.raylib._sendPixel:{[x;y;color]
  c:.raylib._rgba4 color;
  :.raylib._sendMsg .raylib._cmd[`addPixel;("f"$x;"f"$y;c 0;c 1;c 2;c 3)]
 };

.raylib._sendText:{[x;y;txt;size;color]
  c:.raylib._rgba4 color;
  safe:.raylib._safeText txt;
  :.raylib._sendMsg .raylib._cmd[`addText;("f"$x;"f"$y;"i"$size;c 0;c 1;c 2;c 3;safe)]
 };

.raylib._prepareDrawOrUsage:{[t;required;optional;usage]
  .raylib._schemaValidate[t;required;optional;usage];
  .raylib._ensureReady[];
  :count t
 };

.raylib._rateMsAt:{[t;i]
  r:"f"$t[`rate] i;
  if[not r>0f; '"rate"];
  ms:"i"$1000f*r;
  if[ms<1i; :1i];
  :ms
 };

.raylib._interpFlagAt:{[t;i]
  if[not `interpolate in cols t; :0i];
  v:t[`interpolate] i;
  iv:"i"$v;
  :$[iv<>0i;1i;0i]
 };

/ Table API:
/ triangle required columns: x y r; optional color, alpha, layer, rotation, stroke, fill.


.raylib._drawUsage:`triangle`circle`square`rect`line`point`text!(
  "usage: .raylib.triangle[t] where t is a table with x y r (optional color,alpha,layer,rotation,stroke,fill)";
  "usage: .raylib.circle[t] where t is a table with x y r (optional color,alpha,layer,rotation,stroke,fill)";
  "usage: .raylib.square[t] where t is a table with x y r (optional color,alpha,layer,rotation,stroke,fill)";
  "usage: .raylib.rect[t] where t is a table with x y w h (optional color,alpha,layer,rotation,stroke,fill)";
  "usage: .raylib.line[t] where t is a table with x1 y1 x2 y2 (optional thickness,color,alpha,layer,rotation,stroke,fill)";
  "usage: .raylib.point[t] where t is a table with x y (optional color,alpha,layer,rotation,stroke,fill)";
  "usage: .raylib.text[t] where t is a table with x y text size (optional color,alpha,layer,rotation,stroke,fill)");

.raylib._drawSpec:`triangle`circle`square`rect`line`point`text!(
  (`x`y`r;.raylib._drawOptionalCommon;.raylib.Color.MAROON);
  (`x`y`r;.raylib._drawOptionalCommon;.raylib.Color.BLUE);
  (`x`y`r;.raylib._drawOptionalCommon;.raylib.Color.ORANGE);
  (`x`y`w`h;.raylib._drawOptionalCommon;.raylib.Color.ORANGE);
  (`x1`y1`x2`y2;.raylib._drawOptionalCommon,`thickness;.raylib.Color.BLACK);
  (`x`y;.raylib._drawOptionalCommon;.raylib.Color.BLACK);
  (`x`y`text`size;.raylib._drawOptionalCommon;.raylib.Color.BLACK));

.raylib._drawKindRow:{[kind;rt;i;defaultColor;lineHasThickness]
  clr:.raylib._colorAt[rt;i;defaultColor];
  if[kind=`triangle; :.raylib._sendTriangle[rt[`x] i;rt[`y] i;rt[`r] i;clr]];
  if[kind=`circle; :.raylib._sendCircle[rt[`x] i;rt[`y] i;rt[`r] i;clr]];
  if[kind=`square; :.raylib._sendSquare[rt[`x] i;rt[`y] i;rt[`r] i;clr]];
  if[kind=`rect; :.raylib._sendRect[rt[`x] i;rt[`y] i;rt[`w] i;rt[`h] i;clr]];
  if[kind=`line;
    th:$[lineHasThickness; rt[`thickness] i; 1f];
    :.raylib._sendLine[rt[`x1] i;rt[`y1] i;rt[`x2] i;rt[`y2] i;th;clr]];
  if[kind=`point; :.raylib._sendPixel[rt[`x] i;rt[`y] i;clr]];
  if[kind=`text; :.raylib._sendText[rt[`x] i;rt[`y] i;rt[`text] i;rt[`size] i;clr]];
  '"usage"
 };

.raylib._drawPrimitive:{[kind;t]
  usage:.raylib._drawUsage kind;
  spec:.raylib._drawSpec kind;
  required:spec 0;
  optional:spec 1;
  defaultColor:spec 2;
  rt:.raylib._resolveRefs[t;usage];
  c:cols rt;
  if[not all required in c; 'usage];
  drawCols:required,optional inter c;
  rt:flip drawCols!(rt drawCols);
  n:.raylib._prepareDrawOrUsage[rt;required;optional;usage];
  hasThickness:(kind=`line)&(`thickness in cols rt);
  i:0;
  while[i<n;
    .raylib._drawKindRow[kind;rt;i;defaultColor;hasThickness];
    i+:1];
  if[.raylib._tableHasRefs t; .raylib.interactive._remember[kind;t]];
  :n
 };

.raylib.triangle:{[t]
  :.raylib._drawPrimitive[`triangle;t]
 };

.raylib.circle:{[t]
  :.raylib._drawPrimitive[`circle;t]
 };

.raylib.square:{[t]
  :.raylib._drawPrimitive[`square;t]
 };

.raylib.rect:{[t]
  :.raylib._drawPrimitive[`rect;t]
 };

.raylib.line:{[t]
  :.raylib._drawPrimitive[`line;t]
 };

.raylib.point:{[t]
  :.raylib._drawPrimitive[`point;t]
 };

.raylib.text:{[t]
  :.raylib._drawPrimitive[`text;t]
 };

.raylib.draw:{[kind;t]
  usage:"usage: .raylib.draw[`kind;t] where kind is one of triangle|square|circle|rect|line|point|text|pixels";
  if[-11h<>type kind; 'usage];
  if[kind=`pixels; :.raylib.pixels t];
  if[not kind in key .raylib._drawSpec; 'usage];
  :.raylib._drawPrimitive[kind;t]
 };

/ pixels required columns: pixels x y.
/ source dimensions/channels are inferred from payload shape.
.raylib.pixels:{[t]
  usage:.raylib._pixelUsage;
  rt:.raylib._resolveRefs[t;usage];
  n:.raylib._prepareDrawOrUsage[rt;`pixels`x`y;`w`h`scale`dw`dh`alpha`rate`layer`rotation`stroke`fill;usage];
  if[n=0; :0];
  i:0;
  while[i<n;
    rm:.[.raylib._pixelRowMeta;(rt;i);{x}];
    if[10h=type rm; 'usage];
    frames:rm`frames;
    w:rm`w;
    h:rm`h;
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    dw:rm`dw;
    dh:rm`dh;
    alpha:rm`alpha;
    if[rm`animated;
      if[n<>1; 'usage];
      .raylib._sendMsg .raylib._cmd[`animPixelsClear;()];
      fi:0;
      while[fi<count frames;
        pmeta:frames fi;
        sx:dw%("f"$w);
        sy:dh%("f"$h);
        py:0;
        while[py<h;
          px:0;
          while[px<w;
            idx:px+py*w;
            clr:.raylib._pixelColorAt[pmeta;idx;alpha];
            .raylib._sendMsg .raylib._cmd[`animPixelsAdd;(fi;x+("f"$px)*sx;y+("f"$py)*sy;sx;sy;clr 0;clr 1;clr 2;clr 3)];
            px+:1];
          py+:1];
        fi+:1];
      .raylib._sendMsg .raylib._cmd[`animPixelsRate;(rm`rateMs)];
      .raylib._sendMsg .raylib._cmd[`animPixelsPlay;()];
      :n];
    pmeta:first frames;
    sx:dw%("f"$w);
    sy:dh%("f"$h);
    py:0;
    while[py<h;
      px:0;
      while[px<w;
        idx:px+py*w;
        clr:.raylib._pixelColorAt[pmeta;idx;alpha];
        .raylib._sendRect[x+("f"$px)*sx;y+("f"$py)*sy;sx;sy;clr];
        px+:1];
      py+:1];
    i+:1];
  if[.raylib._tableHasRefs t; .raylib.interactive._remember[`pixels;t]];
  :n
 };


.raylib._animatePrep:{[t;required;optional;usage]
  n:.raylib._prepareDrawOrUsage[t;required;optional;usage];
  if[n=0; :0];
  :n
 };

.raylib._animMetaAt:{[t;i;usage]
  ms:.[.raylib._rateMsAt;(t;i);{x}];
  if[10h=type ms; 'usage];
  interp:.[.raylib._interpFlagAt;(t;i);{x}];
  if[10h=type interp; 'usage];
  :`ms`interp!(ms;interp)
 };

.raylib._animControl:{[verb]
  if[verb~"STOP";
    .raylib._sendMsg .raylib._cmd[`animCircleStop;()];
    .raylib._sendMsg .raylib._cmd[`animTriangleStop;()];
    .raylib._sendMsg .raylib._cmd[`animRectStop;()];
    .raylib._sendMsg .raylib._cmd[`animLineStop;()];
    .raylib._sendMsg .raylib._cmd[`animPointStop;()];
    .raylib._sendMsg .raylib._cmd[`animTextStop;()];
    :.raylib._sendMsg .raylib._cmd[`animPixelsStop;()]];
  .raylib._sendMsg .raylib._cmd[`animCirclePlay;()];
  .raylib._sendMsg .raylib._cmd[`animTrianglePlay;()];
  .raylib._sendMsg .raylib._cmd[`animRectPlay;()];
  .raylib._sendMsg .raylib._cmd[`animLinePlay;()];
  .raylib._sendMsg .raylib._cmd[`animPointPlay;()];
  .raylib._sendMsg .raylib._cmd[`animTextPlay;()];
  :.raylib._sendMsg .raylib._cmd[`animPixelsPlay;()]
 };

.raylib._animUsage:`circle`triangle`rect`line`point`text!(
  "usage: .raylib.animate.circle[t] where t is a table with x y r rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), and each rate>0 (seconds)";
  "usage: .raylib.animate.triangle[t] where t is a table with x y r rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), and each rate>0 (seconds)";
  "usage: .raylib.animate.rect[t] where t is a table with x y w h rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), and each rate>0 (seconds)";
  "usage: .raylib.animate.line[t] where t is a table with x1 y1 x2 y2 rate (optional thickness,color,alpha,interpolate,layer,rotation,stroke,fill), and each rate>0 (seconds)";
  "usage: .raylib.animate.point[t] where t is a table with x y rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), and each rate>0 (seconds)";
  "usage: .raylib.animate.text[t] where t is a table with x y text size rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), and each rate>0 (seconds)");

.raylib._animSpec:`circle`triangle`rect`line`point`text!(
  (`x`y`r`rate;.raylib._drawOptionalCommon,`interpolate;.raylib.Color.BLUE;`animCircleClear`animCircleAdd`animCirclePlay);
  (`x`y`r`rate;.raylib._drawOptionalCommon,`interpolate;.raylib.Color.MAROON;`animTriangleClear`animTriangleAdd`animTrianglePlay);
  (`x`y`w`h`rate;.raylib._drawOptionalCommon,`interpolate;.raylib.Color.ORANGE;`animRectClear`animRectAdd`animRectPlay);
  (`x1`y1`x2`y2`rate;.raylib._drawOptionalCommon,`thickness`interpolate;.raylib.Color.BLACK;`animLineClear`animLineAdd`animLinePlay);
  (`x`y`rate;.raylib._drawOptionalCommon,`interpolate;.raylib.Color.BLACK;`animPointClear`animPointAdd`animPointPlay);
  (`x`y`text`size`rate;.raylib._drawOptionalCommon,`interpolate;.raylib.Color.BLACK;`animTextClear`animTextAdd`animTextPlay));

.raylib._animBuildCmd:{[kind;addOp;rt;i;c;ms;interp;hasThickness]
  if[kind=`circle;
    :.raylib._cmd[addOp;("f"$rt[`x] i;"f"$rt[`y] i;"f"$rt[`r] i;c 0;c 1;c 2;c 3;ms;interp)]];
  if[kind=`triangle;
    :.raylib._cmd[addOp;("f"$rt[`x] i;"f"$rt[`y] i;"f"$rt[`r] i;c 0;c 1;c 2;c 3;ms;interp)]];
  if[kind=`rect;
    :.raylib._cmd[addOp;("f"$rt[`x] i;"f"$rt[`y] i;"f"$rt[`w] i;"f"$rt[`h] i;c 0;c 1;c 2;c 3;ms;interp)]];
  if[kind=`line;
    th:$[hasThickness; rt[`thickness] i; 1f];
    :.raylib._cmd[addOp;("f"$rt[`x1] i;"f"$rt[`y1] i;"f"$rt[`x2] i;"f"$rt[`y2] i;"f"$th;c 0;c 1;c 2;c 3;ms;interp)]];
  if[kind=`point;
    :.raylib._cmd[addOp;("f"$rt[`x] i;"f"$rt[`y] i;c 0;c 1;c 2;c 3;ms;interp)]];
  if[kind=`text;
    safe:.raylib._safeText rt[`text] i;
    :.raylib._cmd[addOp;("f"$rt[`x] i;"f"$rt[`y] i;"i"$rt[`size] i;c 0;c 1;c 2;c 3;ms;interp;safe)]];
  '"usage"
 };

.raylib._animateKind:{[kind;t]
  usage:.raylib._animUsage kind;
  spec:.raylib._animSpec kind;
  required:spec 0;
  optional:spec 1;
  defaultColor:spec 2;
  ops:spec 3;
  clearOp:ops 0;
  addOp:ops 1;
  playOp:ops 2;
  rt:.raylib._resolveRefs[t;usage];
  n:.raylib._animatePrep[rt;required;optional;usage];
  if[n=0; :0];
  .raylib._sendMsg .raylib._cmd[clearOp;()];
  hasThickness:(kind=`line)&(`thickness in cols rt);
  i:0;
  while[i<n;
    clr:.raylib._colorAt[rt;i;defaultColor];
    c:.raylib._rgba4 clr;
    m:.raylib._animMetaAt[rt;i;usage];
    .raylib._sendMsg .raylib._animBuildCmd[kind;addOp;rt;i;c;m`ms;m`interp;hasThickness];
    i+:1];
  .raylib._sendMsg .raylib._cmd[playOp;()];
  :n
 };

/ each row is one frame for the same shape; loops infinitely.
.raylib.animate.circle:{[t]
  :.raylib._animateKind[`circle;t]
 };

.raylib.animate.triangle:{[t]
  :.raylib._animateKind[`triangle;t]
 };

.raylib.animate.rect:{[t]
  :.raylib._animateKind[`rect;t]
 };

.raylib.animate.line:{[t]
  :.raylib._animateKind[`line;t]
 };

.raylib.animate.point:{[t]
  :.raylib._animateKind[`point;t]
 };

.raylib.animate.text:{[t]
  :.raylib._animateKind[`text;t]
 };

.raylib.anim:{[kind;t]
  usage:"usage: .raylib.anim[`kind;t] where kind is one of circle|triangle|rect|line|point|text";
  if[-11h<>type kind; 'usage];
  if[not kind in key .raylib._animSpec; 'usage];
  :.raylib._animateKind[kind;t]
 };

.raylib.animate.apply:.raylib.anim;

.raylib.animate.stop:{
  .raylib._ensureReady[];
  :.raylib._animControl["STOP"]
 };

.raylib.animate.start:{
  .raylib._ensureReady[];
  :.raylib._animControl["PLAY"]
 };

/ Step 5: tween/keyframe helpers + fixed-step frame callbacks.


.raylib._callbacks.empty:{[]
  :([] id:`int$(); fn:(); enabled:0#0b)
 };

.raylib._callbacks._idsOrUsage:{[id;usage]
  :$[-6h=type id;enlist "i"$id;$[6h=type id;"i"$id;'usage]]
 };

.raylib._callbacks.on:{[stateSym;nextIdSym;fn]
  id:value nextIdSym;
  nextIdSym set id+1i;
  s:value stateSym;
  s,: ([] id:enlist id; fn:enlist fn; enabled:enlist 1b);
  stateSym set s;
  :id
 };

.raylib._callbacks.off:{[stateSym;id;usage]
  ids:.raylib._callbacks._idsOrUsage[id;usage];
  s:value stateSym;
  keep:not s[`id] in ids;
  stateSym set s where keep;
  :(count s)-sum keep
 };

.raylib._callbacks.clear:{[stateSym]
  stateSym set .raylib._callbacks.empty[];
  :0
 };

.raylib._callbacks.dispatch:{[s;arg]
  i:0;
  while[i<count s;
    if[s[`enabled] i;
      res:.[s[`fn] i;enlist arg;{x}];
      if[10h=type res; 'res]];
    i+:1];
  :arg
 };


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
  .raylib.frame.clear[];
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


.raylib.scene._kinds:`triangle`square`circle`rect`line`point`text`pixels;
.raylib._boundTag:`raylib_bound;

.raylib._isBound:{[src]
  :$[(0h=type src)&(3=count src); .raylib._boundTag~first src; 0b]
 };

.raylib.bind:{[t;b]
  :(.raylib._boundTag;t;b)
 };

.raylib.scene._rows:([] id:`symbol$(); kind:`symbol$(); src:(); bindings:(); layer:`int$(); visible:0#0b; ord:`int$());
.raylib.scene._nextOrd:0i;
.raylib.scene.autoRefresh:1b;

.raylib.scene._afterMutate:{[ret]
  if[.raylib.scene.autoRefresh; .raylib.refresh[]];
  :ret
 };

.raylib.scene.reset:{
  .raylib.scene._rows:([] id:`symbol$(); kind:`symbol$(); src:(); bindings:(); layer:`int$(); visible:0#0b; ord:`int$());
  .raylib.scene._nextOrd:0i;
  :.raylib.scene._afterMutate 0
 };

.raylib.scene._requireId:{[id;usage]
  if[-11h<>type id; 'usage];
  :id
 };

.raylib.scene._requireKind:{[kind;usage]
  if[-11h<>type kind; 'usage];
  if[not kind in .raylib.scene._kinds; 'usage];
  :kind
 };

.raylib.scene._bool:{[v]
  :$["i"$v<>0i;1b;0b]
 };

.raylib.scene._resolveSrc:{[src]
  :$[-11h=type src;value src;src]
 };

.raylib.scene._resolveWithBindings:{[src;bindings]
  t:.raylib.scene._resolveSrc src;
  if[(98h<>type t) | (99h<>type bindings) | (0=count bindings); :t];
  k:key bindings;
  v:value bindings;
  i:0;
  while[i<count k;
    t[k i]:(v i)[];
    i+:1];
  :t
 };

.raylib.scene._drawKind:{[kind;t]
  if[kind=`triangle; :.raylib.triangle t];
  if[kind=`square; :.raylib.square t];
  if[kind=`circle; :.raylib.circle t];
  if[kind=`rect; :.raylib.rect t];
  if[kind=`line; :.raylib.line t];
  if[kind=`point; :.raylib.point t];
  if[kind=`text; :.raylib.text t];
  if[kind=`pixels; :.raylib.pixels t];
  '"usage: scene kind must be one of triangle|square|circle|rect|line|point|text|pixels"
 };

.raylib.scene._drawVisibleOrdered:{[s]
  if[0=count s; :0];
  o:iasc flip `layer`ord!(s[`layer];s[`ord]);
  total:0;
  i:0;
  while[i<count o;
    j:o i;
    if[s[`visible] j;
      kind:s[`kind] j;
      t:.raylib.scene._resolveWithBindings[s[`src] j;s[`bindings] j];
      total+:.raylib.scene._drawKind[kind;t]];
    i+:1];
  :total
 };

.raylib.scene.upsertEx:{[id;kind;src;bindings;layer;visible]
  usage:"usage: .raylib.scene.upsertEx[`id;`kind;tableOrSymbol;bindingsDict;layerInt;visibleBool]";
  rid:.[.raylib.scene._requireId;(id;usage);{x}];
  if[10h=type rid; 'usage];
  rkind:.[.raylib.scene._requireKind;(kind;usage);{x}];
  if[10h=type rkind; 'usage];
  lyr:"i"$layer;
  vis:.raylib.scene._bool visible;
  s:.raylib.scene._rows;
  m:where s[`id]=rid;
  ord:$[count m; s[`ord] first m; .raylib.scene._nextOrd];
  if[0=count m; .raylib.scene._nextOrd+:1i];
  if[count m; s:s where not s[`id]=rid];
  s,: ([] id:enlist rid; kind:enlist rkind; src:enlist src; bindings:enlist bindings; layer:enlist lyr; visible:enlist vis; ord:enlist ord);
  .raylib.scene._rows:s;
  :.raylib.scene._afterMutate 1
 };

.raylib.scene.upsert:{[id;kind;src]
  :.raylib.scene.upsertEx[id;kind;src;()!();0i;1b]
 };

.raylib.scene.delete:{[ids]
  usage:"usage: .raylib.scene.delete[`id] or .raylib.scene.delete[`id1`id2]";
  idv:$[-11h=type ids;enlist ids;$[11h=type ids;ids;'usage]];
  s:.raylib.scene._rows;
  keep:not s[`id] in idv;
  .raylib.scene._rows:s where keep;
  :.raylib.scene._afterMutate ((count s)-sum keep)
 };

.raylib.scene.visible:{[id;flag]
  usage:"usage: .raylib.scene.visible[`id;0|1]";
  rid:.[.raylib.scene._requireId;(id;usage);{x}];
  if[10h=type rid; 'usage];
  s:.raylib.scene._rows;
  idx:where s[`id]=rid;
  if[0=count idx; :0];
  s[`visible]:@[s[`visible];idx;:;(count idx)#(.raylib.scene._bool flag)];
  .raylib.scene._rows:s;
  :.raylib.scene._afterMutate 1
 };

.raylib.scene.clearLayer:{[layer]
  lyr:"i"$layer;
  s:.raylib.scene._rows;
  keep:s[`layer]<>lyr;
  .raylib.scene._rows:s where keep;
  :.raylib.scene._afterMutate ((count s)-sum keep)
 };

.raylib.scene.set:{[pId;pCols;pVals]
  usage:"usage: .raylib.scene.set[`id;`col or `col1`col2;value or (value1;value2)]";
  rid:.[.raylib.scene._requireId;(pId;usage);{x}];
  if[10h=type rid; 'usage];
  c:$[-11h=type pCols;enlist pCols;$[11h=type pCols;pCols;'usage]];
  if[0=count c; 'usage];
  setVals:();
  if[(count c)=1;
    setVals:enlist pVals];
  if[(count c)<>1;
    if[(0h<>type pVals) | ((count pVals)<>count c); 'usage];
    setVals:pVals];
  s:.raylib.scene._rows;
  idx:where s[`id]=rid;
  if[0=count idx; :0];
  i:first idx;
  src:s[`src] i;
  t:.raylib.scene._resolveSrc src;
  if[98h<>type t; 'usage];
  j:0;
  while[j<count c;
    t:![t;();0b;(enlist c j)!enlist setVals j];
    j+:1];
  if[-11h=type src;
    src set t;
    :.raylib.scene.upsertEx[rid;s[`kind] i;src;s[`bindings] i;s[`layer] i;s[`visible] i]];
  :.raylib.scene.upsertEx[rid;s[`kind] i;t;s[`bindings] i;s[`layer] i;s[`visible] i]
 };

.raylib.scene.list:{
  s:.raylib.scene._rows;
  :select id,kind,layer,visible,ord,bound:0<count each bindings from s
 };

.raylib.scene._upsertPrimitive:{[kind;id;src]
  $[.raylib._isBound src;
    .raylib.scene.upsertEx[id;kind;src 1;src 2;0i;1b];
    .raylib.scene.upsert[id;kind;src]]
 };

.raylib.scene.ref._upsert:{[kind;src]
  usage:"usage: .raylib.scene.ref.<kind>[`srcSymbol]";
  if[-11h<>type src; 'usage];
  :.raylib.scene._upsertPrimitive[kind;src;src]
 };

.raylib.scene.triangle:{[id;src]
  :.raylib.scene._upsertPrimitive[`triangle;id;src]
 };

.raylib.scene.circle:{[id;src]
  :.raylib.scene._upsertPrimitive[`circle;id;src]
 };

.raylib.scene.square:{[id;src]
  :.raylib.scene._upsertPrimitive[`square;id;src]
 };

.raylib.scene.rect:{[id;src]
  :.raylib.scene._upsertPrimitive[`rect;id;src]
 };

.raylib.scene.line:{[id;src]
  :.raylib.scene._upsertPrimitive[`line;id;src]
 };

.raylib.scene.point:{[id;src]
  :.raylib.scene._upsertPrimitive[`point;id;src]
 };

.raylib.scene.text:{[id;src]
  :.raylib.scene._upsertPrimitive[`text;id;src]
 };

.raylib.scene.pixels:{[id;src]
  :.raylib.scene._upsertPrimitive[`pixels;id;src]
 };

.raylib.scene.ref.triangle:{[src]
  :.raylib.scene.ref._upsert[`triangle;src]
 };

.raylib.scene.ref.circle:{[src]
  :.raylib.scene.ref._upsert[`circle;src]
 };

.raylib.scene.ref.square:{[src]
  :.raylib.scene.ref._upsert[`square;src]
 };

.raylib.scene.ref.rect:{[src]
  :.raylib.scene.ref._upsert[`rect;src]
 };

.raylib.scene.ref.line:{[src]
  :.raylib.scene.ref._upsert[`line;src]
 };

.raylib.scene.ref.point:{[src]
  :.raylib.scene.ref._upsert[`point;src]
 };

.raylib.scene.ref.text:{[src]
  :.raylib.scene.ref._upsert[`text;src]
 };

.raylib.scene.ref.pixels:{[src]
  :.raylib.scene.ref._upsert[`pixels;src]
 };

.raylib.refresh:{
  .raylib._ensureReady[];
  .raylib._batch.begin[];
  total:.[{[dummy]
      .raylib.clear[];
      s:.raylib.scene._rows;
      if[0=count s; :0];
      :.raylib.scene._drawVisibleOrdered s};enlist 0;{x}];
  if[10h=type total;
    .raylib._batch.abort[];
    'total];
  .raylib._batch.flush[];
  :total
 };


/ Step 7: Data-driven UI toolkit (buttons/sliders/panels/charts/inspectors).

.raylib.ui._panelUsage:"usage: .raylib.ui.panel[t] where t is a table with x y w h (optional color,alpha,border,borderThickness,title,titleSize,titleColor,pad,layer,rotation,stroke,fill)";
.raylib.ui._buttonUsage:"usage: .raylib.ui.button[t] where t is a table with x y w h label (optional color,alpha,textColor,size,pad,border,borderThickness,hot,active,hotColor,activeColor,layer,rotation,stroke,fill)";
.raylib.ui._sliderUsage:"usage: .raylib.ui.slider[t] where t is a table with x y w lo hi val (optional h,color,alpha,fillColor,knobColor,textColor,size,label,showValue,layer,rotation,stroke,fill)";
.raylib.ui._chartLineUsage:"usage: .raylib.ui.chartLine[t] where t is a table with x y w h values (optional color,alpha,bg,axisColor,thickness,pointRadius,min,max,title,titleSize,textColor,layer,rotation,stroke,fill)";
.raylib.ui._chartBarUsage:"usage: .raylib.ui.chartBar[t] where t is a table with x y w h values (optional color,alpha,bg,axisColor,gap,min,max,title,titleSize,textColor,layer,rotation,stroke,fill)";
.raylib.ui._inspectorUsage:"usage: .raylib.ui.inspector[t] where t is a table with x y field val (optional color,alpha,valueColor,size,split,panelW,panelH,bg,border,borderThickness,pad,layer,rotation,stroke,fill)";
.raylib.ui._hitUsage:"usage: .raylib.ui.hit.rect[t] where t is a table with x y w h";
.raylib.ui._frameUsage:"usage: .raylib.ui.begin[] / .raylib.ui.end[]";
.raylib.ui._frameFnUsage:"usage: .raylib.ui.frame[{[] ...}]";
.raylib.ui._buttonClickUsage:"usage: .raylib.ui.buttonClick[`id;rect4;label;onClickFn;`press|`release]";
.raylib.ui._buttonClick4Usage:"usage: .raylib.ui.buttonPress[`id;rect4;label;onClickFn] or .raylib.ui.buttonRelease[...]";
.raylib.ui._uiTextUsage:"usage: .raylib.ui.text[x;y;txt;size]";
.raylib.ui._modeUsage:"usage: mode must be `press or `release";

.raylib.ui._frame.active:0b;
.raylib.ui._frame.input:`mx`my`down`mbutton!(0f;0f;0b;-1i);
.raylib.ui._btnState:([] id:`symbol$(); downPrev:0#0b);

.raylib.ui._bool:{[v]
  :$["i"$v<>0i;1b;0b]
 };

.raylib.ui._colOr:{[t;col;i;default]
  :$[col in cols t; t[col] i; default]
 };

.raylib.ui._textWidth:{[txt;size]
  / Approximate width for default font metrics.
  :("f"$count .raylib._safeText txt) * ("f"$size) * 0.55f
 };

.raylib.ui._valueText:{[v]
  if[0h=type v; :raze string each v];
  :raze string v
 };

.raylib.ui._mouse:{[]
  mx:$[10h=type .[value;enlist `mx;{x}];0f;"f"$value `mx];
  my:$[10h=type .[value;enlist `my;{x}];0f;"f"$value `my];
  mpressed:$[10h=type .[value;enlist `mpressed;{x}];0b;.raylib.ui._bool value `mpressed];
  mbutton:$[10h=type .[value;enlist `mbutton;{x}];-1i;"i"$value `mbutton];
  :`mx`my`mpressed`mbutton!(mx;my;mpressed;mbutton)
 };

.raylib.ui.state.reset:{
  .raylib.ui._btnState:([] id:`symbol$(); downPrev:0#0b);
  :0
 };

.raylib.ui._buttonPrev:{[id]
  s:.raylib.ui._btnState;
  idx:where s[`id]=id;
  if[0=count idx; :0b];
  :s[`downPrev] first idx
 };

.raylib.ui._buttonSetPrev:{[id;down]
  s:.raylib.ui._btnState;
  idx:where s[`id]=id;
  if[count idx;
    s[`downPrev]:@[s[`downPrev];idx;:;(count idx)#enlist .raylib.ui._bool down];
    .raylib.ui._btnState:s;
    :0b];
  s,: ([] id:enlist id; downPrev:enlist .raylib.ui._bool down);
  .raylib.ui._btnState:s;
  :0b
 };

.raylib.ui._modeOrUsage:{[mode]
  usage:.raylib.ui._modeUsage;
  sym:$[-11h=type mode;mode;`$string mode];
  if[not sym in `press`release; 'usage];
  :sym
 };

.raylib.ui._requireFrame:{
  if[not .raylib.ui._frame.active; '".raylib.ui.begin[] must be called before drawing widgets"];
  :1b
 };

.raylib.ui._frameAbort:{
  if[.raylib.ui._frame.active;
    .raylib._batch.abort[]];
  .raylib.ui._frame.active:0b;
  :0b
 };

.raylib.ui.begin:{
  .raylib._ensureReady[];
  if[.raylib.ui._frame.active; .raylib.ui._frameAbort[]];
  m:.raylib.ui._mouse[];
  d:(m`mpressed)&((m`mbutton) in 0 -1);
  .raylib.ui._frame.input:`mx`my`down`mbutton!(m`mx;m`my;d;m`mbutton);
  .raylib._batch.begin[];
  .raylib._sendMsg .raylib._cmd[`clear;()];
  .raylib.ui._frame.active:1b;
  :.raylib.ui._frame.input
 };

.raylib.ui.end:{
  if[not .raylib.ui._frame.active; :0];
  .raylib._batch.flush[];
  .raylib.ui._frame.active:0b;
  :0
 };

.raylib.ui.frame:{[fn]
  usage:.raylib.ui._frameFnUsage;
  if[not .raylib._isCallable fn; 'usage];
  .raylib.ui.begin[];
  r:.[{x[]};enlist fn;{x}];
  if[10h=type r;
    .raylib.ui._frameAbort[];
    'r];
  .raylib.ui.end[];
  :0
 };

.raylib.ui._drawBorder:{[x;y;w;h;th;color]
  t:"f"$th;
  if[t<=0f; :0];
  .raylib._sendRect[x;y;w;t;color];
  .raylib._sendRect[x;y+h-t;w;t;color];
  .raylib._sendRect[x;y+t;t;h-(2f*t);color];
  .raylib._sendRect[x+w-t;y+t;t;h-(2f*t);color];
  :1
 };

.raylib.ui.hit.rect:{[t]
  usage:.raylib.ui._hitUsage;
  rt:.raylib._resolveRefs[t;usage];
  .raylib._schemaValidate[rt;`x`y`w`h;();usage];
  m:.raylib.ui._mouse[];
  n:count rt;
  out:n#0b;
  i:0;
  while[i<n;
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    w:"f"$rt[`w] i;
    h:"f"$rt[`h] i;
    out[i]:((m`mx)>=x)&((m`mx)<=x+w)&((m`my)>=y)&((m`my)<=y+h);
    i+:1];
  :out
 };

.raylib.ui.panel:{[t]
  usage:.raylib.ui._panelUsage;
  rt:.raylib._resolveRefs[t;usage];
  n:.raylib._prepareDrawOrUsage[rt;`x`y`w`h;`color`alpha`border`borderThickness`title`titleSize`titleColor`pad`layer`rotation`stroke`fill;usage];
  i:0;
  while[i<n;
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    w:"f"$rt[`w] i;
    h:"f"$rt[`h] i;
    bg:.raylib._colorAt[rt;i;245 245 245 255i];
    bc:.raylib._rgba4 .raylib.ui._colOr[rt;`border;i;80 80 80 255i];
    bth:"f"$.raylib.ui._colOr[rt;`borderThickness;i;1f];
    pad:"f"$.raylib.ui._colOr[rt;`pad;i;8f];
    .raylib._sendRect[x;y;w;h;bg];
    .raylib.ui._drawBorder[x;y;w;h;bth;bc];
    if[`title in cols rt;
      txt:rt[`title] i;
      if[0<count .raylib._safeText txt;
        ts:"i"$.raylib.ui._colOr[rt;`titleSize;i;18i];
        tc:.raylib._rgba4 .raylib.ui._colOr[rt;`titleColor;i;20 20 20 255i];
        .raylib._sendText[x+pad;y+pad;txt;ts;tc]]];
    i+:1];
  :n
 };

.raylib.ui.buttonState:{[t]
  usage:.raylib.ui._buttonUsage;
  rt:.raylib._resolveRefs[t;usage];
  .raylib._schemaValidate[rt;`x`y`w`h`label;`color`alpha`textColor`size`pad`border`borderThickness`hot`active`hotColor`activeColor`layer`rotation`stroke`fill;usage];
  m:.raylib.ui._mouse[];
  n:count rt;
  hot:n#0b;
  active:n#0b;
  clicked:n#0b;
  i:0;
  while[i<n;
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    w:"f"$rt[`w] i;
    h:"f"$rt[`h] i;
    hh:((m`mx)>=x)&((m`mx)<=x+w)&((m`my)>=y)&((m`my)<=y+h);
    ha:$[`hot in cols rt;.raylib.ui._bool rt[`hot] i;hh];
    aa:$[`active in cols rt;.raylib.ui._bool rt[`active] i;(ha&(m`mpressed)&((m`mbutton) in 0 -1))];
    hot[i]:ha;
    active[i]:aa;
    clicked[i]:ha&(m`mpressed)&((m`mbutton) in 0 -1);
    i+:1];
  out:rt;
  out[`hot]:hot;
  out[`active]:active;
  out[`clicked]:clicked;
  :out
 };

.raylib.ui.buttonTable:{[t]
  usage:.raylib.ui._buttonUsage;
  st:.raylib.ui.buttonState t;
  n:.raylib._prepareDrawOrUsage[st;`x`y`w`h`label;`color`alpha`textColor`size`pad`border`borderThickness`hot`active`clicked`hotColor`activeColor`layer`rotation`stroke`fill;usage];
  i:0;
  while[i<n;
    x:"f"$st[`x] i;
    y:"f"$st[`y] i;
    w:"f"$st[`w] i;
    h:"f"$st[`h] i;
    size:"i"$.raylib.ui._colOr[st;`size;i;18i];
    pad:"f"$.raylib.ui._colOr[st;`pad;i;8f];
    hot:.raylib.ui._bool st[`hot] i;
    active:.raylib.ui._bool st[`active] i;
    base:.raylib._colorAt[st;i;225 225 225 255i];
    hotClr:.raylib._rgba4 .raylib.ui._colOr[st;`hotColor;i;200 220 245 255i];
    actClr:.raylib._rgba4 .raylib.ui._colOr[st;`activeColor;i;170 200 235 255i];
    bg:$[active;actClr;$[hot;hotClr;base]];
    bc:.raylib._rgba4 .raylib.ui._colOr[st;`border;i;70 70 70 255i];
    bth:"f"$.raylib.ui._colOr[st;`borderThickness;i;1f];
    tc:.raylib._rgba4 .raylib.ui._colOr[st;`textColor;i;15 15 15 255i];
    label:st[`label] i;
    tw:.raylib.ui._textWidth[label;size];
    tx:x+0.5f*(w-tw);
    ty:y+0.5f*(h-("f"$size));
    if[tx<x+pad; tx:x+pad];
    .raylib._sendRect[x;y;w;h;bg];
    .raylib.ui._drawBorder[x;y;w;h;bth;bc];
    .raylib._sendText[tx;ty;label;size;tc];
    i+:1];
  :n
 };

.raylib.ui.buttonClick:{[id;rect;label;onClick;mode]
  usage:.raylib.ui._buttonClickUsage;
  if[-11h<>type id; 'usage];
  if[(type rect)<0h; 'usage];
  if[4<>count rect; 'usage];
  if[not .raylib._isCallable onClick; 'usage];
  md:.raylib.ui._modeOrUsage mode;
  .raylib.ui._requireFrame[];
  x:"f"$rect 0;
  y:"f"$rect 1;
  w:"f"$rect 2;
  h:"f"$rect 3;
  if[(w<=0f)|(h<=0f); 'usage];
  inp:.raylib.ui._frame.input;
  hot:((inp`mx)>=x)&((inp`mx)<=x+w)&((inp`my)>=y)&((inp`my)<=y+h);
  down:inp`down;
  wasDown:.raylib.ui._buttonPrev id;
  clicked:$[md=`press; hot&down&not wasDown; hot&(not down)&wasDown];
  if[clicked;
    rr:.[{x[]};enlist onClick;{x}];
    if[10h=type rr; 'rr]];
  .raylib.ui._buttonSetPrev[id;down];
  bt:([] x:enlist x; y:enlist y; w:enlist w; h:enlist h; label:enlist label; hot:enlist hot; active:enlist hot&down);
  .raylib.ui.buttonTable bt;
  :clicked
 };

.raylib.ui.buttonPress:{[id;rect;label;onClick]
  usage:.raylib.ui._buttonClick4Usage;
  :.raylib.ui.buttonClick[id;rect;label;onClick;`press]
 };

.raylib.ui.buttonRelease:{[id;rect;label;onClick]
  usage:.raylib.ui._buttonClick4Usage;
  :.raylib.ui.buttonClick[id;rect;label;onClick;`release]
 };

.raylib.ui.button:{[t]
  :.raylib.ui.buttonTable t
 };

.raylib.ui.sliderValue:{[t]
  usage:.raylib.ui._sliderUsage;
  rt:.raylib._resolveRefs[t;usage];
  .raylib._schemaValidate[rt;`x`y`w`lo`hi`val;`h`color`alpha`fillColor`knobColor`textColor`size`label`showValue`layer`rotation`stroke`fill;usage];
  m:.raylib.ui._mouse[];
  n:count rt;
  out:rt;
  vals:rt[`val];
  i:0;
  while[i<n;
    lo:"f"$rt[`lo] i;
    hi:"f"$rt[`hi] i;
    if[not hi>lo; 'usage];
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    w:"f"$rt[`w] i;
    h:"f"$.raylib.ui._colOr[rt;`h;i;18f];
    hit:((m`mx)>=x)&((m`mx)<=x+w)&((m`my)>=y)&((m`my)<=y+h);
    if[hit&(m`mpressed)&((m`mbutton) in 0 -1);
      u:((m`mx)-x)%w;
      if[u<0f;u:0f];
      if[u>1f;u:1f];
      vals[i]:lo+(hi-lo)*u;
     ;
      v:"f"$vals i;
      if[v<lo;vals[i]:lo];
      if[v>hi;vals[i]:hi]];
    i+:1];
  out[`val]:vals;
  :out
 };

.raylib.ui.slider:{[t]
  usage:.raylib.ui._sliderUsage;
  st:.raylib.ui.sliderValue t;
  n:.raylib._prepareDrawOrUsage[st;`x`y`w`lo`hi`val;`h`color`alpha`fillColor`knobColor`textColor`size`label`showValue`layer`rotation`stroke`fill;usage];
  i:0;
  while[i<n;
    lo:"f"$st[`lo] i;
    hi:"f"$st[`hi] i;
    if[not hi>lo; 'usage];
    x:"f"$st[`x] i;
    y:"f"$st[`y] i;
    w:"f"$st[`w] i;
    h:"f"$.raylib.ui._colOr[st;`h;i;18f];
    v:"f"$st[`val] i;
    if[v<lo;v:lo];
    if[v>hi;v:hi];
    u:(v-lo)%(hi-lo);
    trackY:y+0.5f*h-2f;
    fillW:w*u;
    knobX:x+fillW;
    tc:.raylib._colorAt[st;i;190 190 190 255i];
    fc:.raylib._rgba4 .raylib.ui._colOr[st;`fillColor;i;0 121 241 255i];
    kc:.raylib._rgba4 .raylib.ui._colOr[st;`knobColor;i;30 30 30 255i];
    txtc:.raylib._rgba4 .raylib.ui._colOr[st;`textColor;i;20 20 20 255i];
    ts:"i"$.raylib.ui._colOr[st;`size;i;16i];
    .raylib._sendRect[x;trackY;w;4f;tc];
    if[fillW>0f; .raylib._sendRect[x;trackY;fillW;4f;fc]];
    .raylib._sendCircle[knobX;y+0.5f*h;0.4f*h;kc];
    if[`label in cols st;
      lbl:st[`label] i;
      if[0<count .raylib._safeText lbl;
        .raylib._sendText[x;y-("f"$ts)-4f;lbl;ts;txtc]]];
    showVal:$[`showValue in cols st;.raylib.ui._bool st[`showValue] i;1b];
    if[showVal;
      vt:.raylib.ui._valueText v;
      .raylib._sendText[x+w+6f;y-2f;vt;ts;txtc]];
    i+:1];
  :n
 };

.raylib.ui._chartMinMax:{[vals;hasMin;minV;hasMax;maxV;usage]
  v:"f"$vals;
  if[0=count v; 'usage];
  lo:$[hasMin;"f"$minV;min v];
  hi:$[hasMax;"f"$maxV;max v];
  if[not hi>lo;
    hi:lo+1f];
  :`lo`hi!(lo;hi)
 };

.raylib.ui.chartLine:{[t]
  usage:.raylib.ui._chartLineUsage;
  rt:.raylib._resolveRefs[t;usage];
  n:.raylib._prepareDrawOrUsage[rt;`x`y`w`h`values;`color`alpha`bg`axisColor`thickness`pointRadius`min`max`title`titleSize`textColor`layer`rotation`stroke`fill;usage];
  i:0;
  while[i<n;
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    w:"f"$rt[`w] i;
    h:"f"$rt[`h] i;
    vals:rt[`values] i;
    mm:.raylib.ui._chartMinMax[vals;`min in cols rt;.raylib.ui._colOr[rt;`min;i;0f];`max in cols rt;.raylib.ui._colOr[rt;`max;i;0f];usage];
    lo:mm`lo;
    hi:mm`hi;
    data:"f"$vals;
    cnt:count data;
    bg:.raylib._rgba4 .raylib.ui._colOr[rt;`bg;i;248 248 248 255i];
    axis:.raylib._rgba4 .raylib.ui._colOr[rt;`axisColor;i;90 90 90 255i];
    lc:.raylib._colorAt[rt;i;0 121 241 255i];
    th:"f"$.raylib.ui._colOr[rt;`thickness;i;2f];
    pr:"f"$.raylib.ui._colOr[rt;`pointRadius;i;2.5f];
    txtc:.raylib._rgba4 .raylib.ui._colOr[rt;`textColor;i;20 20 20 255i];
    ts:"i"$.raylib.ui._colOr[rt;`titleSize;i;16i];
    .raylib._sendRect[x;y;w;h;bg];
    .raylib._sendLine[x;y+h;x+w;y+h;1f;axis];
    .raylib._sendLine[x;y;x;y+h;1f;axis];
    if[`title in cols rt;
      ttl:rt[`title] i;
      if[0<count .raylib._safeText ttl;
        .raylib._sendText[x;y-("f"$ts)-4f;ttl;ts;txtc]]];
    if[cnt>1;
      dx:w%("f"$(cnt-1));
      j:0;
      while[j<cnt-1;
        v0:data j;
        v1:data j+1;
        px0:x+dx*("f"$j);
        py0:y+h-(h*(v0-lo)%(hi-lo));
        px1:x+dx*("f"$(j+1));
        py1:y+h-(h*(v1-lo)%(hi-lo));
        .raylib._sendLine[px0;py0;px1;py1;th;lc];
        j+:1]];
    if[(cnt>0)&(pr>0f);
      dx:$[cnt>1;w%("f"$(cnt-1));0f];
      j:0;
      while[j<cnt;
        vj:data j;
        px:x+dx*("f"$j);
        py:y+h-(h*(vj-lo)%(hi-lo));
        .raylib._sendCircle[px;py;pr;lc];
        j+:1]];
    i+:1];
  :n
 };

.raylib.ui.chartBar:{[t]
  usage:.raylib.ui._chartBarUsage;
  rt:.raylib._resolveRefs[t;usage];
  n:.raylib._prepareDrawOrUsage[rt;`x`y`w`h`values;`color`alpha`bg`axisColor`gap`min`max`title`titleSize`textColor`layer`rotation`stroke`fill;usage];
  i:0;
  while[i<n;
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    w:"f"$rt[`w] i;
    h:"f"$rt[`h] i;
    vals:rt[`values] i;
    mm:.raylib.ui._chartMinMax[vals;`min in cols rt;.raylib.ui._colOr[rt;`min;i;0f];`max in cols rt;.raylib.ui._colOr[rt;`max;i;0f];usage];
    lo:mm`lo;
    hi:mm`hi;
    data:"f"$vals;
    cnt:count data;
    gap:"f"$.raylib.ui._colOr[rt;`gap;i;4f];
    bg:.raylib._rgba4 .raylib.ui._colOr[rt;`bg;i;248 248 248 255i];
    axis:.raylib._rgba4 .raylib.ui._colOr[rt;`axisColor;i;90 90 90 255i];
    bc:.raylib._colorAt[rt;i;0 180 0 255i];
    txtc:.raylib._rgba4 .raylib.ui._colOr[rt;`textColor;i;20 20 20 255i];
    ts:"i"$.raylib.ui._colOr[rt;`titleSize;i;16i];
    .raylib._sendRect[x;y;w;h;bg];
    .raylib._sendLine[x;y+h;x+w;y+h;1f;axis];
    .raylib._sendLine[x;y;x;y+h;1f;axis];
    if[`title in cols rt;
      ttl:rt[`title] i;
      if[0<count .raylib._safeText ttl;
        .raylib._sendText[x;y-("f"$ts)-4f;ttl;ts;txtc]]];
    if[cnt>0;
      bw:(w-gap*("f"$(cnt+1)))%("f"$cnt);
      if[bw<1f; bw:1f];
      j:0;
      while[j<cnt;
        vj:data j;
        bh:h*(vj-lo)%(hi-lo);
        if[bh<0f;bh:0f];
        bx:x+gap+(("f"$j)*(bw+gap));
        by:y+h-bh;
        .raylib._sendRect[bx;by;bw;bh;bc];
        j+:1]];
    i+:1];
  :n
 };

.raylib.ui.chart:{[kind;t]
  usage:"usage: .raylib.ui.chart[`kind;t] where kind is line|bar";
  if[-11h<>type kind; 'usage];
  if[kind=`line; :.raylib.ui.chartLine t];
  if[kind=`bar; :.raylib.ui.chartBar t];
  'usage
 };

.raylib.ui.text:{[x;y;txt;size]
  usage:.raylib.ui._uiTextUsage;
  .raylib.ui._requireFrame[];
  t:([] x:enlist "f"$x; y:enlist "f"$y; text:enlist txt; size:enlist "i"$size);
  :.raylib.text t
 };

.raylib.ui.inspector:{[t]
  usage:.raylib.ui._inspectorUsage;
  rt:.raylib._resolveRefs[t;usage];
  n:.raylib._prepareDrawOrUsage[rt;`x`y`field`val;`color`alpha`valueColor`size`split`panelW`panelH`bg`border`borderThickness`pad`layer`rotation`stroke`fill;usage];
  i:0;
  while[i<n;
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    ftxt:.raylib.ui._valueText rt[`field] i;
    vtxt:.raylib.ui._valueText rt[`val] i;
    ts:"i"$.raylib.ui._colOr[rt;`size;i;16i];
    split:"f"$.raylib.ui._colOr[rt;`split;i;120f];
    pad:"f"$.raylib.ui._colOr[rt;`pad;i;8f];
    pw:"f"$.raylib.ui._colOr[rt;`panelW;i;split+140f];
    ph:"f"$.raylib.ui._colOr[rt;`panelH;i;("f"$ts)+2f*pad+4f];
    bg:.raylib._rgba4 .raylib.ui._colOr[rt;`bg;i;250 250 250 255i];
    bc:.raylib._rgba4 .raylib.ui._colOr[rt;`border;i;100 100 100 255i];
    bth:"f"$.raylib.ui._colOr[rt;`borderThickness;i;1f];
    kc:.raylib._colorAt[rt;i;20 20 20 255i];
    vc:.raylib._rgba4 .raylib.ui._colOr[rt;`valueColor;i;0 121 241 255i];
    .raylib._sendRect[x;y;pw;ph;bg];
    .raylib.ui._drawBorder[x;y;pw;ph;bth;bc];
    .raylib._sendText[x+pad;y+pad;ftxt;ts;kc];
    .raylib._sendText[x+pad+split;y+pad;vtxt;ts;vc];
    i+:1];
  :n
 };


.raylib._docs:`open`start`clear`close`refresh`scene.reset`scene.upsert`scene.upsertEx`scene.set`scene.delete`scene.visible`scene.clearLayer`scene.list`scene.triangle`scene.square`scene.circle`scene.rect`scene.line`scene.point`scene.text`scene.pixels`scene.ref.triangle`scene.ref.square`scene.ref.circle`scene.ref.rect`scene.ref.line`scene.ref.point`scene.ref.text`scene.ref.pixels`shape.info`shape.pretty`shape.show`colors`easings`fillColor`triangle`square`circle`rect`line`point`text`pixels`animate.circle`animate.triangle`animate.rect`animate.line`animate.point`animate.text`animate.stop`animate.start`tween.table`keyframesTable`frame.reset`frame.setDt`frame.on`each.frame`frame.off`frame.clear`frame.tick`frame.step`frame.run`tick`events.clear`events.poll`events.pump`events.on`events.off`events.callbacks.clear`interactive.start`interactive.stop`interactive.spin`interactive.mode`interative.mode`interactive.tick`interactive.setInterval`dev.interactive.mode`dev.interactive.setInterval`interactive.live.clear`interactive.live.list!(
  "Open or reuse the renderer runtime. On first successful open, scene rows are reset implicitly.\nusage: .raylib.open[]";
  "Legacy alias of .raylib.open[] (prefer .raylib.open[]).\nusage: .raylib.start[]";
  "Clear all drawn primitives and animation tracks.\nusage: .raylib.clear[]";
  "Close renderer window and reset in-memory state.\nusage: .raylib.close[]";
  "Clear the renderer and redraw current scene entries in layer/order.\nusage: .raylib.refresh[]";
  "Reset all scene entries and insertion order state; auto-refreshes by default.\nusage: .raylib.scene.reset[]";
  "Upsert a scene entry by id at layer 0 and visible=1; auto-refreshes by default.\nusage: .raylib.scene.upsert[`id;`kind;tableOrSymbol]";
  "Upsert a scene entry by id with explicit bindings/layer/visibility; auto-refreshes by default.\nusage: .raylib.scene.upsertEx[`id;`kind;tableOrSymbol;bindingsDict;layerInt;visibleBool]";
  "Patch one scene source table by id (partial column updates); auto-refreshes by default.\nusage: .raylib.scene.set[`id;`col or `col1`col2;value or (value1;value2)]";
  "Delete one or more scene entries by id; auto-refreshes by default.\nusage: .raylib.scene.delete[`id] or .raylib.scene.delete[`id1`id2]";
  "Toggle scene entry visibility by id; auto-refreshes by default.\nusage: .raylib.scene.visible[`id;0|1]";
  "Delete all scene entries on one layer; auto-refreshes by default.\nusage: .raylib.scene.clearLayer[layerInt]";
  "List scene metadata rows.\nusage: .raylib.scene.list[]";
  "Upsert triangle scene source.\nusage: .raylib.scene.triangle[`id;tableOrSymbol]";
  "Upsert square scene source.\nusage: .raylib.scene.square[`id;tableOrSymbol]";
  "Upsert circle scene source.\nusage: .raylib.scene.circle[`id;tableOrSymbol]";
  "Upsert rectangle scene source.\nusage: .raylib.scene.rect[`id;tableOrSymbol]";
  "Upsert line scene source.\nusage: .raylib.scene.line[`id;tableOrSymbol]";
  "Upsert point scene source.\nusage: .raylib.scene.point[`id;tableOrSymbol]";
  "Upsert text scene source.\nusage: .raylib.scene.text[`id;tableOrSymbol]";
  "Upsert pixel-array scene source.\nusage: .raylib.scene.pixels[`id;tableOrSymbol]";
  "Upsert triangle scene source by symbol reference (id=src).\nusage: .raylib.scene.ref.triangle[`srcSymbol]";
  "Upsert square scene source by symbol reference (id=src).\nusage: .raylib.scene.ref.square[`srcSymbol]";
  "Upsert circle scene source by symbol reference (id=src).\nusage: .raylib.scene.ref.circle[`srcSymbol]";
  "Upsert rectangle scene source by symbol reference (id=src).\nusage: .raylib.scene.ref.rect[`srcSymbol]";
  "Upsert line scene source by symbol reference (id=src).\nusage: .raylib.scene.ref.line[`srcSymbol]";
  "Upsert point scene source by symbol reference (id=src).\nusage: .raylib.scene.ref.point[`srcSymbol]";
  "Upsert text scene source by symbol reference (id=src).\nusage: .raylib.scene.ref.text[`srcSymbol]";
  "Upsert pixel-array scene source by symbol reference (id=src).\nusage: .raylib.scene.ref.pixels[`srcSymbol]";
  "Return the shape of a nested array.\nusage: .raylib.shape.info x";
  "Return a Uiua-style pretty string with shape and boxed slices.\nusage: .raylib.shape.pretty x";
  "Print a Uiua-style pretty view of an array, then return that string.\nusage: .raylib.shape.show x";
  "List named color constants with RGBA vectors.\nusage: .raylib.colors[]";
  "List available easing names accepted by tween/keyframes APIs.\nusage: .raylib.easings[]";
  "Fill table rows with one or more RGBA colors (cycled via take). Pass a symbol to mutate in-place.\nusage: .raylib.fillColor[tOrSym;rgbaOrRgbaList]";
  "Draw triangles from table rows.\nusage: .raylib.triangle[t] where t has x y r (optional color,alpha,layer,rotation,stroke,fill)";
  "Draw squares from table rows (center/radius semantics).\nusage: .raylib.square[t] where t has x y r (optional color,alpha,layer,rotation,stroke,fill)";
  "Draw circles from table rows.\nusage: .raylib.circle[t] where t has x y r (optional color,alpha,layer,rotation,stroke,fill)";
  "Draw rectangles from table rows.\nusage: .raylib.rect[t] where t has x y w h (optional color,alpha,layer,rotation,stroke,fill)";
  "Draw lines from table rows.\nusage: .raylib.line[t] where t has x1 y1 x2 y2 (optional thickness,color,alpha,layer,rotation,stroke,fill)";
  "Draw pixels/points from table rows.\nusage: .raylib.point[t] where t has x y (optional color,alpha,layer,rotation,stroke,fill)";
  "Draw text from table rows.\nusage: .raylib.text[t] where t has x y text size (optional color,alpha,layer,rotation,stroke,fill)";
  "Render raster payload rows as scaled pixel cells; nested frame-shape payloads auto-loop.\nusage: .raylib.pixels[t] where t has pixels x y (optional w,h,scale,dw,dh,alpha,rate,layer,rotation,stroke,fill)";
  "Set looping circle animation frames.\nusage: .raylib.animate.circle[t] where t has x y r rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), rate>0";
  "Set looping triangle animation frames.\nusage: .raylib.animate.triangle[t] where t has x y r rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), rate>0";
  "Set looping rectangle animation frames.\nusage: .raylib.animate.rect[t] where t has x y w h rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), rate>0";
  "Set looping line animation frames.\nusage: .raylib.animate.line[t] where t has x1 y1 x2 y2 rate (optional thickness,color,alpha,interpolate,layer,rotation,stroke,fill), rate>0";
  "Set looping point animation frames.\nusage: .raylib.animate.point[t] where t has x y rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), rate>0";
  "Set looping text animation frames.\nusage: .raylib.animate.text[t] where t has x y text size rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), rate>0";
  "Pause all animation tracks (including pixel loops).\nusage: .raylib.animate.stop[]";
  "Resume all animation tracks (including pixel loops).\nusage: .raylib.animate.start[]";
  "Build tween frames between two 1-row tables using easing.\nusage: .raylib.tween.table[from;to;duration;steps;easing]";
  "Build interpolated frames from keyframes table sorted by `at` seconds.\nusage: .raylib.keyframesTable[kf;fps;easing]";
  "Reset frame clock to frame=0,time=0 while keeping dt.\nusage: .raylib.frame.reset[]";
  "Set fixed-step dt used by frame tick loop.\nusage: .raylib.frame.setDt[seconds] where seconds>0";
  "Register a q callback to run on each frame tick; callback gets state dictionary.\nusage: .raylib.frame.on[{[state] ...}]";
  "Register a no-arg callback to run each frame tick.\nusage: .raylib.each.frame[{...}]";
  "Unregister one or more frame callback ids.\nusage: .raylib.frame.off[id] or .raylib.frame.off[idList]";
  "Remove all frame callbacks.\nusage: .raylib.frame.clear[]";
  "Advance one fixed step, run callbacks, and optionally refresh scene.\nusage: .raylib.frame.tick[]";
  "Advance N fixed steps without sleeping.\nusage: .raylib.frame.step[steps]";
  "Advance N fixed steps with real-time sleep(dt) between ticks.\nusage: .raylib.frame.run[steps]";
  "Run one renderer tick by polling and dispatching input/window events.\nusage: .raylib.tick[]";
  "Clear pending renderer input events.\nusage: .raylib.events.clear[]";
  "Drain renderer input events into a table.\nusage: .raylib.events.poll[]";
  "Poll and dispatch events to registered q callbacks.\nusage: .raylib.events.pump[]";
  "Register event callback (callback receives event table).\nusage: .raylib.events.on[{[ev] ...}]";
  "Unregister one or more event callback ids.\nusage: .raylib.events.off[id] or .raylib.events.off[idList]";
  "Remove all event callbacks.\nusage: .raylib.events.callbacks.clear[]";
  "Start safe timer-driven interactive loop (Esc stops).\nusage: .raylib.interactive.start[]";
  "Stop interactive loop if running.\nusage: .raylib.interactive.stop[]";
  "Alias of timer-driven interactive mode toggle.\nusage: .raylib.interactive.spin[0|1]";
  "Developer API: enable/disable timer-based interactive loop.\nusage: .raylib.interactive.mode[0|1]";
  "Alias of .raylib.interactive.mode.\nusage: .raylib.interative.mode[0|1]";
  "Run one interactive tick manually (poll, update vars, redraw).\nusage: .raylib.interactive.tick[]";
  "Developer API: set timer-loop interval in milliseconds.\nusage: .raylib.interactive.setInterval[ms] where ms>0";
  "Developer alias of timer-based interactive mode.\nusage: .raylib.dev.interactive.mode[0|1]";
  "Developer alias of timer-loop interval.\nusage: .raylib.dev.interactive.setInterval[ms]";
  "Clear live interactive draw bindings captured from symbol-referenced draw tables.\nusage: .raylib.interactive.live.clear[]";
  "List live interactive draw bindings.\nusage: .raylib.interactive.live.list[]"
 );

.raylib._docs,:`draw`anim`animate.apply!(
  "Generic draw dispatcher by primitive kind.\nusage: .raylib.draw[`kind;t] where kind is triangle|square|circle|rect|line|point|text|pixels";
  "Generic animation dispatcher by primitive kind.\nusage: .raylib.anim[`kind;t] where kind is circle|triangle|rect|line|point|text";
  "Alias of .raylib.anim.\nusage: .raylib.animate.apply[`kind;t]");

.raylib._docs,:`ui.hit.rect`ui.begin`ui.end`ui.frame`ui.state.reset`ui.panel`ui.buttonState`ui.buttonTable`ui.button`ui.buttonClick`ui.buttonPress`ui.buttonRelease`ui.sliderValue`ui.slider`ui.chartLine`ui.chartBar`ui.chart`ui.text`ui.inspector!(
  "Return row-wise mouse-hit booleans for rectangle rows.\nusage: .raylib.ui.hit.rect[t] where t has x y w h";
  "Begin one batched UI frame (captures input and clears once).\nusage: .raylib.ui.begin[]";
  "End one batched UI frame and flush draw commands.\nusage: .raylib.ui.end[]";
  "Run one UI frame with automatic begin/end batching around callback body.\nusage: .raylib.ui.frame[{[] ...}]";
  "Reset per-button UI state cache.\nusage: .raylib.ui.state.reset[]";
  "Draw panel widgets from table rows.\nusage: .raylib.ui.panel[t] where t has x y w h";
  "Compute button interaction state (`hot`,`active`,`clicked`) from mouse vars.\nusage: .raylib.ui.buttonState[t] where t has x y w h label";
  "Draw button widgets from table rows.\nusage: .raylib.ui.buttonTable[t] where t has x y w h label";
  "Draw button widgets from table rows (alias of buttonTable).\nusage: .raylib.ui.button[t] where t has x y w h label";
  "High-level clickable button with per-id edge state.\nusage: .raylib.ui.buttonClick[`id;rect4;label;onClickFn;`press|`release]";
  "High-level clickable button that fires on press edge.\nusage: .raylib.ui.buttonPress[`id;rect4;label;onClickFn]";
  "High-level clickable button that fires on release-inside edge.\nusage: .raylib.ui.buttonRelease[`id;rect4;label;onClickFn]";
  "Return slider table with `value` updated from mouse drag state.\nusage: .raylib.ui.sliderValue[t] where t has x y w lo hi val";
  "Draw slider widgets from table rows.\nusage: .raylib.ui.slider[t] where t has x y w lo hi val";
  "Draw line-chart widgets from table rows.\nusage: .raylib.ui.chartLine[t] where t has x y w h values";
  "Draw bar-chart widgets from table rows.\nusage: .raylib.ui.chartBar[t] where t has x y w h values";
  "Generic chart dispatcher.\nusage: .raylib.ui.chart[`kind;t] where kind is line|bar";
  "Draw one UI text row inside an active .raylib.ui.begin[]/.end[] frame.\nusage: .raylib.ui.text[x;y;txt;size]";
  "Draw inspector rows (`field` + `val`) with optional boxed panel styling.\nusage: .raylib.ui.inspector[t] where t has x y field val");

.raylib.help:{[name]
  if[-11h<>type name; '"usage: .raylib.help[`functionName]"];
  if[not name in key .raylib._docs;
    msg:raze ("unknown function: ";string name;"\navailable: ";", " sv string each key .raylib._docs);
    -1 msg;
    :msg];
  msg:.raylib._docs name;
  -1 msg;
  :msg
 };


