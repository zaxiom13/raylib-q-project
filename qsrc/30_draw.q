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

.raylib._drawRowFns:`triangle`circle`square`rect`line`point`text!(
  {[rt;i;clr;lineHasThickness] .raylib._sendTriangle[rt[`x] i;rt[`y] i;rt[`r] i;clr]};
  {[rt;i;clr;lineHasThickness] .raylib._sendCircle[rt[`x] i;rt[`y] i;rt[`r] i;clr]};
  {[rt;i;clr;lineHasThickness] .raylib._sendSquare[rt[`x] i;rt[`y] i;rt[`r] i;clr]};
  {[rt;i;clr;lineHasThickness] .raylib._sendRect[rt[`x] i;rt[`y] i;rt[`w] i;rt[`h] i;clr]};
  {[rt;i;clr;lineHasThickness]
    th:$[lineHasThickness; rt[`thickness] i; 1f];
    .raylib._sendLine[rt[`x1] i;rt[`y1] i;rt[`x2] i;rt[`y2] i;th;clr]};
  {[rt;i;clr;lineHasThickness] .raylib._sendPixel[rt[`x] i;rt[`y] i;clr]};
  {[rt;i;clr;lineHasThickness] .raylib._sendText[rt[`x] i;rt[`y] i;rt[`text] i;rt[`size] i;clr]});

.raylib._drawKindRow:{[kind;rt;i;defaultColor;lineHasThickness]
  usage:"usage: draw kind must be one of triangle|circle|square|rect|line|point|text";
  rowFn:$[kind in key .raylib._drawRowFns; .raylib._drawRowFns kind; `missing];
  if[`missing~rowFn; 'usage];
  clr:.raylib._colorAt[rt;i;defaultColor];
  :rowFn[rt;i;clr;lineHasThickness]
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
