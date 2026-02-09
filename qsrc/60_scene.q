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
  if[-11h=type src;
    srcVal:.[value;enlist src;{::}];
    if[98h=type srcVal; :srcVal]];
  :src
 };

.raylib.scene._resolveSrcById:{[id;src]
  / Prefer explicit source symbol first, then id-matching table variable.
  / This supports scene ids that differ from the underlying mutable table name.
  if[-11h=type src;
    srcVal:.[value;enlist src;{::}];
    if[98h=type srcVal; :srcVal]];
  idVal:.[value;enlist id;{::}];
  if[98h=type idVal; :idVal];
  :.raylib.scene._resolveSrc src
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

.raylib.scene._drawFns:`triangle`square`circle`rect`line`point`text`pixels!(
  `.raylib.triangle;
  `.raylib.square;
  `.raylib.circle;
  `.raylib.rect;
  `.raylib.line;
  `.raylib.point;
  `.raylib.text;
  `.raylib.pixels);

.raylib.scene._drawKind:{[kind;t]
  usage:"usage: scene kind must be one of triangle|square|circle|rect|line|point|text|pixels";
  fnSym:$[kind in key .raylib.scene._drawFns; .raylib.scene._drawFns kind; `missing];
  if[`missing~fnSym; 'usage];
  :(value fnSym) t
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
      t:.raylib.scene._resolveWithBindings[.raylib.scene._resolveSrcById[s[`id] j;s[`src] j];s[`bindings] j];
      total+:.raylib.scene._drawKind[kind;t]];
    i+:1];
  :total
 };

.raylib.scene.upsertEx:{[id;kind;src;bindings;layer;visible]
  usage:"usage: .raylib.scene.upsertEx[`id;`kind;table;bindingsDict;layerInt;visibleBool]";
  rid:.[.raylib.scene._requireId;(id;usage);{x}];
  if[10h=type rid; 'usage];
  rkind:.[.raylib.scene._requireKind;(kind;usage);{x}];
  if[10h=type rkind; 'usage];
  et:.[.raylib._requireTable;enlist .raylib.scene._resolveSrc src;{x}];
  if[10h=type et; 'usage];
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
  removed:(count s)-sum keep;
  .raylib.scene._rows:s where keep;
  if[removed=0; :.raylib._noop["scene.delete matched no ids";0]];
  :.raylib.scene._afterMutate removed
 };

.raylib.scene.visible:{[id;flag]
  usage:"usage: .raylib.scene.visible[`id;0|1]";
  rid:.[.raylib.scene._requireId;(id;usage);{x}];
  if[10h=type rid; 'usage];
  s:.raylib.scene._rows;
  idx:where s[`id]=rid;
  if[0=count idx; :.raylib._noop["scene.visible: id not found";0]];
  s[`visible]:@[s[`visible];idx;:;(count idx)#(.raylib.scene._bool flag)];
  .raylib.scene._rows:s;
  :.raylib.scene._afterMutate 1
 };

.raylib.scene.clearLayer:{[layer]
  lyr:"i"$layer;
  s:.raylib.scene._rows;
  keep:s[`layer]<>lyr;
  removed:(count s)-sum keep;
  .raylib.scene._rows:s where keep;
  if[removed=0; :.raylib._noop["scene.clearLayer: layer has no rows";0]];
  :.raylib.scene._afterMutate removed
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
  if[0=count idx; :.raylib._noop["scene.set: id not found";0]];
  i:first idx;
  t:.raylib.scene._resolveSrcById[rid;s[`src] i];
  if[98h<>type t; 'usage];
  j:0;
  while[j<count c;
    t:![t;();0b;(enlist c j)!enlist setVals j];
    j+:1];
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
