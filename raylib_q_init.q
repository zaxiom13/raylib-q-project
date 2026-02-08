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
  prevTimer:"i"$system "t";
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
  ok:.raylib.transport.open[];
  if[ok;
    if[not .raylib.autoPump.suspend;
      .raylib.autoPump.ensure[]]];
  :0<>"i"$ok
 };

.raylib.start:{
  :.raylib.open[]
 };

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

.raylib._sendMsg:{[msg]
  if[not .raylib._batch.active;
    :.raylib._sendBatch enlist msg];
  .raylib._batch.msgs,:enlist msg;
  :0
 };

.raylib._batch.active:0b;
.raylib._batch.msgs:();

.raylib._sendBatch:{[msgs]
  if[0=count msgs; :0];
  body:"\n" sv msgs;
  :.raylib.transport.submit body
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
  msg:raze ("ADD_TRIANGLE ";string "f"$x;" ";string "f"$y;" ";string "f"$r;" ";string c 0;" ";string c 1;" ";string c 2;" ";string c 3);
  :.raylib._sendMsg msg
 };

.raylib._sendCircle:{[x;y;r;color]
  c:.raylib._rgba4 color;
  msg:raze ("ADD_CIRCLE ";string "f"$x;" ";string "f"$y;" ";string "f"$r;" ";string c 0;" ";string c 1;" ";string c 2;" ";string c 3);
  :.raylib._sendMsg msg
 };

.raylib._sendSquare:{[x;y;r;color]
  c:.raylib._rgba4 color;
  msg:raze ("ADD_SQUARE ";string "f"$x;" ";string "f"$y;" ";string "f"$r;" ";string c 0;" ";string c 1;" ";string c 2;" ";string c 3);
  :.raylib._sendMsg msg
 };

.raylib._sendRect:{[x;y;w;h;color]
  c:.raylib._rgba4 color;
  msg:raze ("ADD_RECT ";string "f"$x;" ";string "f"$y;" ";string "f"$w;" ";string "f"$h;" ";string c 0;" ";string c 1;" ";string c 2;" ";string c 3);
  :.raylib._sendMsg msg
 };

.raylib._sendLine:{[x1;y1;x2;y2;thickness;color]
  c:.raylib._rgba4 color;
  msg:raze ("ADD_LINE ";string "f"$x1;" ";string "f"$y1;" ";string "f"$x2;" ";string "f"$y2;" ";string "f"$thickness;" ";string c 0;" ";string c 1;" ";string c 2;" ";string c 3);
  :.raylib._sendMsg msg
 };

.raylib._sendPixel:{[x;y;color]
  c:.raylib._rgba4 color;
  msg:raze ("ADD_PIXEL ";string "f"$x;" ";string "f"$y;" ";string c 0;" ";string c 1;" ";string c 2;" ";string c 3);
  :.raylib._sendMsg msg
 };

.raylib._sendText:{[x;y;txt;size;color]
  c:.raylib._rgba4 color;
  safe:.raylib._safeText txt;
  msg:raze ("ADD_TEXT ";string "f"$x;" ";string "f"$y;" ";string "i"$size;" ";string c 0;" ";string c 1;" ";string c 2;" ";string c 3;" ";safe);
  :.raylib._sendMsg msg
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
      .raylib._sendMsg "ANIM_PIXELS_CLEAR";
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
            msg:raze ("ANIM_PIXELS_ADD ";string fi;" ";string "f"$(x+("f"$px)*sx);" ";string "f"$(y+("f"$py)*sy);" ";string "f"$sx;" ";string "f"$sy;" ";string clr 0;" ";string clr 1;" ";string clr 2;" ";string clr 3);
            .raylib._sendMsg msg;
            px+:1];
          py+:1];
        fi+:1];
      .raylib._sendMsg raze ("ANIM_PIXELS_RATE ";string rm`rateMs);
      .raylib._sendMsg "ANIM_PIXELS_PLAY";
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
  .raylib._sendMsg raze ("ANIM_CIRCLE_";verb);
  .raylib._sendMsg raze ("ANIM_TRIANGLE_";verb);
  .raylib._sendMsg raze ("ANIM_RECT_";verb);
  .raylib._sendMsg raze ("ANIM_LINE_";verb);
  .raylib._sendMsg raze ("ANIM_POINT_";verb);
  .raylib._sendMsg raze ("ANIM_TEXT_";verb);
  :.raylib._sendMsg raze ("ANIM_PIXELS_";verb)
 };

.raylib._animUsage:`circle`triangle`rect`line`point`text!(
  "usage: .raylib.animate.circle[t] where t is a table with x y r rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), and each rate>0 (seconds)";
  "usage: .raylib.animate.triangle[t] where t is a table with x y r rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), and each rate>0 (seconds)";
  "usage: .raylib.animate.rect[t] where t is a table with x y w h rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), and each rate>0 (seconds)";
  "usage: .raylib.animate.line[t] where t is a table with x1 y1 x2 y2 rate (optional thickness,color,alpha,interpolate,layer,rotation,stroke,fill), and each rate>0 (seconds)";
  "usage: .raylib.animate.point[t] where t is a table with x y rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), and each rate>0 (seconds)";
  "usage: .raylib.animate.text[t] where t is a table with x y text size rate (optional color,alpha,interpolate,layer,rotation,stroke,fill), and each rate>0 (seconds)");

.raylib._animSpec:`circle`triangle`rect`line`point`text!(
  (`x`y`r`rate;.raylib._drawOptionalCommon,`interpolate;.raylib.Color.BLUE;"ANIM_CIRCLE");
  (`x`y`r`rate;.raylib._drawOptionalCommon,`interpolate;.raylib.Color.MAROON;"ANIM_TRIANGLE");
  (`x`y`w`h`rate;.raylib._drawOptionalCommon,`interpolate;.raylib.Color.ORANGE;"ANIM_RECT");
  (`x1`y1`x2`y2`rate;.raylib._drawOptionalCommon,`thickness`interpolate;.raylib.Color.BLACK;"ANIM_LINE");
  (`x`y`rate;.raylib._drawOptionalCommon,`interpolate;.raylib.Color.BLACK;"ANIM_POINT");
  (`x`y`text`size`rate;.raylib._drawOptionalCommon,`interpolate;.raylib.Color.BLACK;"ANIM_TEXT"));

.raylib._animBuildMsg:{[kind;prefix;rt;i;c;ms;interp;hasThickness]
  if[kind=`circle;
    :raze (prefix;"_ADD ";string "f"$rt[`x] i;" ";string "f"$rt[`y] i;" ";string "f"$rt[`r] i;" ";string c 0;" ";string c 1;" ";string c 2;" ";string c 3;" ";string ms;" ";string interp)];
  if[kind=`triangle;
    :raze (prefix;"_ADD ";string "f"$rt[`x] i;" ";string "f"$rt[`y] i;" ";string "f"$rt[`r] i;" ";string c 0;" ";string c 1;" ";string c 2;" ";string c 3;" ";string ms;" ";string interp)];
  if[kind=`rect;
    :raze (prefix;"_ADD ";string "f"$rt[`x] i;" ";string "f"$rt[`y] i;" ";string "f"$rt[`w] i;" ";string "f"$rt[`h] i;" ";string c 0;" ";string c 1;" ";string c 2;" ";string c 3;" ";string ms;" ";string interp)];
  if[kind=`line;
    th:$[hasThickness; rt[`thickness] i; 1f];
    :raze (prefix;"_ADD ";string "f"$rt[`x1] i;" ";string "f"$rt[`y1] i;" ";string "f"$rt[`x2] i;" ";string "f"$rt[`y2] i;" ";string "f"$th;" ";string c 0;" ";string c 1;" ";string c 2;" ";string c 3;" ";string ms;" ";string interp)];
  if[kind=`point;
    :raze (prefix;"_ADD ";string "f"$rt[`x] i;" ";string "f"$rt[`y] i;" ";string c 0;" ";string c 1;" ";string c 2;" ";string c 3;" ";string ms;" ";string interp)];
  if[kind=`text;
    safe:.raylib._safeText rt[`text] i;
    :raze (prefix;"_ADD ";string "f"$rt[`x] i;" ";string "f"$rt[`y] i;" ";string "i"$rt[`size] i;" ";string c 0;" ";string c 1;" ";string c 2;" ";string c 3;" ";string ms;" ";string interp;" ";safe)];
  '"usage"
 };

.raylib._animateKind:{[kind;t]
  usage:.raylib._animUsage kind;
  spec:.raylib._animSpec kind;
  required:spec 0;
  optional:spec 1;
  defaultColor:spec 2;
  prefix:spec 3;
  rt:.raylib._resolveRefs[t;usage];
  n:.raylib._animatePrep[rt;required;optional;usage];
  if[n=0; :0];
  .raylib._sendMsg raze (prefix;"_CLEAR");
  hasThickness:(kind=`line)&(`thickness in cols rt);
  i:0;
  while[i<n;
    clr:.raylib._colorAt[rt;i;defaultColor];
    c:.raylib._rgba4 clr;
    m:.raylib._animMetaAt[rt;i;usage];
    msg:.raylib._animBuildMsg[kind;prefix;rt;i;c;m`ms;m`interp;hasThickness];
    .raylib._sendMsg msg;
    i+:1];
  .raylib._sendMsg raze (prefix;"_PLAY");
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
  :.raylib._sendMsg "CLEAR"
 };

/ Close renderer window.
.raylib.close:{
  if[.raylib.interactive.active;
    .raylib.interactive._stop[]];
  .raylib.autoPump.stop[];
  :0<>"i"$.raylib.transport.close[]
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


.raylib._docs:`open`start`clear`close`refresh`scene.reset`scene.upsert`scene.upsertEx`scene.set`scene.delete`scene.visible`scene.clearLayer`scene.list`scene.triangle`scene.square`scene.circle`scene.rect`scene.line`scene.point`scene.text`scene.pixels`scene.ref.triangle`scene.ref.square`scene.ref.circle`scene.ref.rect`scene.ref.line`scene.ref.point`scene.ref.text`scene.ref.pixels`shape.info`shape.pretty`shape.show`colors`easings`fillColor`triangle`square`circle`rect`line`point`text`pixels`animate.circle`animate.triangle`animate.rect`animate.line`animate.point`animate.text`animate.stop`animate.start`tween.table`keyframesTable`frame.reset`frame.setDt`frame.on`each.frame`frame.off`frame.clear`frame.tick`frame.step`frame.run`tick`events.clear`events.poll`events.pump`events.on`events.off`events.callbacks.clear`interactive.start`interactive.stop`interactive.spin`interactive.mode`interative.mode`interactive.tick`interactive.setInterval`dev.interactive.mode`dev.interactive.setInterval`interactive.live.clear`interactive.live.list!(
  "Open or reuse the renderer runtime.\nusage: .raylib.open[]";
  "Start renderer (alias of open).\nusage: .raylib.start[]";
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


