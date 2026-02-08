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
