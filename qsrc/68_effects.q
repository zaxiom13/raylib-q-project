.raylib.fx._shadowUsage:"usage: .raylib.fx.shadow[t] where t has x y w h (optional radius,offsetX,offsetY,color,alpha,blur)";
.raylib.fx._glowUsage:"usage: .raylib.fx.glow[t] where t has x y w h (optional radius,color,alpha,pulse,pulseSpeed)";
.raylib.fx._gradientUsage:"usage: .raylib.fx.gradient[t] where t has x y w h color1 color2 (optional direction`h`v`d,steps,alpha)";
.raylib.fx._outlineUsage:"usage: .raylib.fx.outline[t] where t has x y w h (optional thickness,color,alpha,round)";
.raylib.fx._roundRectUsage:"usage: .raylib.fx.roundRect[t] where t has x y w h radius (optional color,alpha,border,borderColor,borderThickness)";

.raylib.fx.shadow:{[t]
  usage:.raylib.fx._shadowUsage;
  rt:.raylib._resolveRefs[t;usage];
  n:.raylib._prepareDrawOrUsage[rt;`x`y`w`h;`radius`offsetX`offsetY`color`alpha`blur;usage];
  i:0;
  while[i<n;
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    w:"f"$rt[`w] i;
    h:"f"$rt[`h] i;
    r:"f"$.[{x`radius};(rt;i);{8f}];
    ox:"f"$.[{x`offsetX};(rt;i);{4f}];
    oy:"f"$.[{x`offsetY};(rt;i);{4f}];
    blur:"f"$.[{x`blur};(rt;i);{0f}];
    sc:.raylib._rgba4 .raylib.ui._colOr[rt;`color;i;0 0 0 128i];
    sc[3]:"i"$sc[3]*.[{x`alpha};(rt;i);{0.5f}];
    layers:$[blur>0f;6i;3i];
    li:0;
    while[li<layers;
      f:1f+(("f"$li)%("f"$layers))*blur*0.3f;
      a:sc[3]*(1f-(("f"$li)%("f"$layers))*0.6f);
      c:(sc 0;sc 1;sc 2;"i"$a);
      .raylib._sendRect[x+ox-f;y+oy-f;w+2f*f;h+2f*f;c];
      li+:1];
    i+:1];
  :n
 };

.raylib.fx.glow:{[t]
  usage:.raylib.fx._glowUsage;
  rt:.raylib._resolveRefs[t;usage];
  n:.raylib._prepareDrawOrUsage[rt;`x`y`w`h;`radius`color`alpha`pulse`pulseSpeed;usage];
  i:0;
  while[i<n;
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    w:"f"$rt[`w] i;
    h:"f"$rt[`h] i;
    r:"f"$.[{x`radius};(rt;i);{12f}];
    gc:.raylib._rgba4 .raylib.ui._colOr[rt;`color;i;0 121 241 255i];
    pulse:.raylib.ui._bool .raylib.ui._colOr[rt;`pulse;i;0b];
    ps:"f"$.[{x`pulseSpeed};(rt;i);{2f}];
    alpha:.[{x`alpha};(rt;i);{0.6f}];
    layers:5i;
    li:0;
    while[li<layers;
      f:("f"$li)*r%("f"$layers);
      pa:alpha;
      if[pulse; pa:(0.5f+0.5f*sin(.z.t%1000000000f*ps))*alpha];
      a:"i"$(gc 3i)*pa*(1f-("f"$li)%("f"$layers));
      c:(gc 0i;gc 1i;gc 2i;a);
      .raylib._sendRect[x-f;y-f;w+2f*f;h+2f*f;c];
      li+:1];
    i+:1];
  :n
 };

.raylib.fx._lerpColor:{[c1;c2;t;alpha]
  r:"i"$c1[0]*(1f-t)+c2[0]*t;
  g:"i"$c1[1]*(1f-t)+c2[1]*t;
  b:"i"$c1[2]*(1f-t)+c2[2]*t;
  a:"i"$c1[3]*(1f-t)+c2[3]*t*alpha;
  :(r;g;b;a)
 };

.raylib.fx.gradient:{[t]
  usage:.raylib.fx._gradientUsage;
  rt:.raylib._resolveRefs[t;usage];
  n:.raylib._prepareDrawOrUsage[rt;`x`y`w`h`color1`color2;`direction`steps`alpha;usage];
  i:0;
  while[i<n;
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    w:"f"$rt[`w] i;
    h:"f"$rt[`h] i;
    c1:.raylib._rgba4 rt[`color1] i;
    c2:.raylib._rgba4 rt[`color2] i;
    dir:$[`direction in cols rt;rt[`direction] i;`v];
    steps:"i"$.[{x`steps};(rt;i);{32i}];
    if[steps<2; steps:2i];
    alpha:.[{x`alpha};(rt;i);{1f}];
    j:0;
    while[j<steps-1;
      t0:("f"$j)%("f"$steps-1);
      c0:.raylib.fx._lerpColor[c1;c2;t0;alpha];
      $[dir=`v;
        .raylib._sendRect[x;y+h*t0;w;h%(steps-1)+1f;c0];
        dir=`h;
        .raylib._sendRect[x+w*t0;y;w%(steps-1)+1f;h;c0];
        .raylib._sendRect[x;y;w%(steps-1)+1f;h%(steps-1)+1f;c0]];
      j+:1];
    i+:1];
  :n
 };

.raylib.fx.outline:{[t]
  usage:.raylib.fx._outlineUsage;
  rt:.raylib._resolveRefs[t;usage];
  n:.raylib._prepareDrawOrUsage[rt;`x`y`w`h;`thickness`color`alpha`round;usage];
  i:0;
  while[i<n;
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    w:"f"$rt[`w] i;
    h:"f"$rt[`h] i;
    th:"f"$.[{x`thickness};(rt;i);{2f}];
    oc:.raylib._rgba4 .raylib.ui._colOr[rt;`color;i;0 121 241 255i];
    alpha:.[{x`alpha};(rt;i);{1f}];
    oc[3]:"i"$oc[3]*alpha;
    round:.raylib.ui._bool .raylib.ui._colOr[rt;`round;i;0b];
    if[round;
      r:th*2f;
      .raylib._sendCircle[x+r;y+r;r;oc];
      .raylib._sendCircle[x+w-r;y+r;r;oc];
      .raylib._sendCircle[x+r;y+h-r;r;oc];
      .raylib._sendCircle[x+w-r;y+h-r;r;oc];
      .raylib._sendRect[x+r;y;w-2f*r;th;oc];
      .raylib._sendRect[x+r;y+h-th;w-2f*r;th;oc];
      .raylib._sendRect[x;y+r;th;h-2f*r;oc];
      .raylib._sendRect[x+w-th;y+r;th;h-2f*r;oc];
     ;
      .raylib._sendRect[x;y;w;th;oc];
      .raylib._sendRect[x;y+h-th;w;th;oc];
      .raylib._sendRect[x;y;th;h;oc];
      .raylib._sendRect[x+w-th;y;th;h;oc]];
    i+:1];
  :n
 };

.raylib.fx.roundRect:{[t]
  usage:.raylib.fx._roundRectUsage;
  rt:.raylib._resolveRefs[t;usage];
  n:.raylib._prepareDrawOrUsage[rt;`x`y`w`h`radius;`color`alpha`border`borderColor`borderThickness;usage];
  i:0;
  while[i<n;
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    w:"f"$rt[`w] i;
    h:"f"$rt[`h] i;
    r:"f"$rt[`radius] i;
    minDim:w;
    if[h<w; minDim:h];
    if[r>minDim%2f; r:minDim%2f];
    bg:.raylib._colorAt[rt;i;240 240 240 255i];
    hasBorder:`border in cols rt;
    bc:.raylib._rgba4 .raylib.ui._colOr[rt;`borderColor;i;60 60 60 255i];
    bth:"f"$.[{x`borderThickness};(rt;i);{1f}];
    .raylib._sendRect[x+r;y;w-2f*r;h;bg];
    .raylib._sendRect[x;y+r;w;h-2f*r;bg];
    .raylib._sendCircle[x+r;y+r;r;bg];
    .raylib._sendCircle[x+w-r;y+r;r;bg];
    .raylib._sendCircle[x+r;y+h-r;r;bg];
    .raylib._sendCircle[x+w-r;y+h-r;r;bg];
    if[hasBorder;
      .raylib._sendRect[x+r;y;w-2f*r;bth;bc];
      .raylib._sendRect[x+r;y+h-bth;w-2f*r;bth;bc];
      .raylib._sendRect[x;y+r;bth;h-2f*r;bc];
      .raylib._sendRect[x+w-bth;y+r;bth;h-2f*r;bc]];
    i+:1];
  :n
 };

.raylib.fx.pulse:{[t]
  usage:"usage: .raylib.fx.pulse[t] where t has x y w h (optional color,minAlpha,maxAlpha,speed)";
  rt:.raylib._resolveRefs[t;usage];
  n:.raylib._prepareDrawOrUsage[rt;`x`y`w`h;`color`minAlpha`maxAlpha`speed;usage];
  i:0;
  while[i<n;
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    w:"f"$rt[`w] i;
    h:"f"$rt[`h] i;
    pc:.raylib._rgba4 .raylib.ui._colOr[rt;`color;i;0 121 241 255i];
    minA:.[{x`minAlpha};(rt;i);{0.3f}];
    maxA:.[{x`maxAlpha};(rt;i);{1f}];
    speed:"f"$.[{x`speed};(rt;i);{2f}];
    alpha:minA+(maxA-minA)*0.5f*(1f+sin(.z.t%1000000000f*speed));
    pc[3]:"i"$pc[3]*alpha;
    .raylib._sendRect[x;y;w;h;pc];
    i+:1];
  :n
 };

.raylib.fx.fadeIn:{[t]
  usage:"usage: .raylib.fx.fadeIn[t] where t has x y w h duration (optional color,startTime)";
  rt:.raylib._resolveRefs[t;usage];
  n:.raylib._prepareDrawOrUsage[rt;`x`y`w`h;`duration`color`startTime;usage];
  i:0;
  while[i<n;
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    w:"f"$rt[`w] i;
    h:"f"$rt[`h] i;
    dur:"f"$.[{x`duration};(rt;i);{1f}];
    start:.[{x`startTime};(rt;i);{.z.t}];
    fc:.raylib._rgba4 .raylib.ui._colOr[rt;`color;i;0 121 241 255i];
    elapsed:(.z.t-start)%1000000000f;
    alpha:1f;
    if[elapsed<dur; alpha:elapsed%dur];
    fc[3]:"i"$fc[3]*alpha;
    .raylib._sendRect[x;y;w;h;fc];
    i+:1];
  :n
 };
