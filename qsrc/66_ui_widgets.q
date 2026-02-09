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
