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
