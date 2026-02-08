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

