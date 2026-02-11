/ Public draw namespace facade.
/ Keep .raylib as backend implementation while promoting .draw as outward API.
.draw:.raylib;
.draw.backends:`raylib`canvas;
.draw.target.current:`raylib;
.draw.target.get:{[]
  :.draw.target.current
 };
.draw.target.set:{[name]
  usage:"usage: .draw.target.set[`raylib|`canvas]";
  if[-11h<>type name; 'usage];
  if[not name in .draw.backends; 'usage];
  .draw.target.current:name;
  if[name~`canvas;
    if[count .raylib.frame._callbacks;
      .raylib.frame._ensureCanvasInteractive[]]];
  :name
 };
