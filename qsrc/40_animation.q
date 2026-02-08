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
