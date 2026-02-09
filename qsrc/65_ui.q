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
  if[not .raylib.ui._frame.active; :.raylib._noop["ui.end called without active frame";0]];
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
