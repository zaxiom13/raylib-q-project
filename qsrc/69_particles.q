.raylib.particle._usage:"usage: .raylib.particle.emit[t] where t has x y (optional count,life,speed,color,size,gravity,spread,rate,decay)";
.raylib.particle._usageSystem:"usage: .raylib.particle.system[id;config] creates a particle system with config: x y (optional count,life,speed,color,size,gravity,spread,rate,decay,loop)";
.raylib.particle._usageUpdate:"usage: .raylib.particle.update[] updates all particle systems";

.raylib.particle._systems:([] id:`symbol$(); config:(); particles:(); lastEmit:0#0p; active:0#0b);

.raylib.particle._defaultConfig:`x`y`count`life`speed`color`size`gravity`spread`rate`decay`loop!(
  0f;0f;50i;1f;100f;255 200 100 255i;4f;50f;360f;10i;0.98f;1b);

.raylib.particle._rand:{[]
  :((.z.t%1000)%1f)
 };

.raylib.particle._randRange:{[lo;hi]
  :lo+(hi-lo)*.raylib.particle._rand[]
 };

.raylib.particle._initParticle:{[cfg]
  x:"f"$cfg`x;
  y:"f"$cfg`y;
  speed:"f"$.[{x`speed};cfg;{100f}];
  spread:"f"$.[{x`spread};cfg;{360f}];
  angle:.raylib.particle._randRange[0f;spread]*3.14159f%180f;
  vx:speed*cos angle;
  vy:speed*sin angle;
  life:"f"$.[{x`life};cfg;{1f}];
  size:"f"$.[{x`size};cfg;{4f}];
  color:.raylib._rgba4 .[cfg;`color;{255 200 100 255i}];
  decay:"f"$.[{x`decay};cfg;{0.98f}];
  :`x`y`vx`vy`life`maxLife`size`color`decay`age!(x;y;vx;vy;life;life;size;color;decay;0f)
 };

.raylib.particle.emit:{[t]
  usage:.raylib.particle._usage;
  rt:.raylib._resolveRefs[t;usage];
  n:.raylib._prepareDrawOrUsage[rt;`x`y;`count`life`speed`color`size`gravity`spread`rate`decay;usage];
  i:0;
  while[i<n;
    x:"f"$rt[`x] i;
    y:"f"$rt[`y] i;
    pCount:"i"$.[{x`count};(rt;i);{20i}];
    pLife:"f"$.[{x`life};(rt;i);{1f}];
    pSpeed:"f"$.[{x`speed};(rt;i);{100f}];
    pColor:.raylib._rgba4 .[rt;(`color;i);{255 200 100 255i}];
    pSize:"f"$.[{x`size};(rt;i);{4f}];
    pGravity:"f"$.[{x`gravity};(rt;i);{50f}];
    pSpread:"f"$.[{x`spread};(rt;i);{360f}];
    pDecay:"f"$.[{x`decay};(rt;i);{0.98f}];
    j:0;
    while[j<pCount;
      angle:.raylib.particle._randRange[0f;pSpread]*3.14159f%180f;
      s:pSpeed*.raylib.particle._randRange[0.5f;1.5f];
      px:x;
      py:y;
      vx:s*cos angle;
      vy:s*sin angle;
      l:pLife*.raylib.particle._randRange[0.7f;1.3f];
      sz:pSize*.raylib.particle._randRange[0.5f;1.5f];
      c:(pColor 0;pColor 1;pColor 2;pColor 3);
      age:0f;
      maxAge:l;
      while[age<maxAge;
        dt:0.016f;
        px+:vx*dt;
        py+:vy*dt;
        vy+:pGravity*dt;
        vx*:pDecay;
        vy*:pDecay;
        alpha:1f-age%maxAge;
        c[3]:"i"$pColor[3]*alpha;
        .raylib._sendCircle[px;py;sz*alpha;c];
        age+:dt];
      j+:1];
    i+:1];
  :n
 };

.raylib.particle.system:{[id;config]
  if[-11h<>type id; '"id must be symbol"];
  cfg:.raylib.particle._defaultConfig,config;
  s:.raylib.particle._systems;
  idx:where s[`id]=id;
  if[count idx;
    s:s where not s[`id]=id];
  s,: ([] id:enlist id; config:enlist cfg; particles:enlist (); lastEmit:enlist 0p; active:enlist 1b);
  .raylib.particle._systems:s;
  :id
 };

.raylib.particle.start:{[id]
  s:.raylib.particle._systems;
  idx:where s[`id]=id;
  if[0=count idx; :0b];
  s[`active]:@[s[`active];idx;:;1b];
  .raylib.particle._systems:s;
  :1b
 };

.raylib.particle.stop:{[id]
  s:.raylib.particle._systems;
  idx:where s[`id]=id;
  if[0=count idx; :0b];
  s[`active]:@[s[`active];idx;:;0b];
  .raylib.particle._systems:s;
  :1b
 };

.raylib.particle.reset:{[id]
  s:.raylib.particle._systems;
  idx:where s[`id]=id;
  if[0=count idx; :0b];
  s[`particles]:@[s[`particles];idx;:;()];
  s[`lastEmit]:@[s[`lastEmit];idx;:;0p];
  .raylib.particle._systems:s;
  :1b
 };

.raylib.particle.update:{[]
  s:.raylib.particle._systems;
  n:count s;
  i:0;
  while[i<n;
    if[not s[`active] i; i+:1; next];
    cfg:s[`config] i;
    particles:s[`particles] i;
    lastEmit:s[`lastEmit] i;
    rate:"i"$.[{x`rate};cfg;{10i}];
    now:.z.p;
    emitInterval:1000000000%rate;
    if[(now-lastEmit)>emitInterval;
      pCount:"i"$.[{x`count};cfg;{50i}];
      newP:.raylib.particle._initParticle cfg;
      particles,:pCount#enlist newP;
      s[`lastEmit]:@[s[`lastEmit];i;:;now]];
    updatedP:();
    j:0;
    pLen:count particles;
    while[j<pLen;
      p:particles j;
      age:"f"$p`age;
      maxAge:"f"$p`maxLife;
      if[age<maxAge;
        dt:0.016f;
        px:"f"$p`x + p`vx * dt;
        py:"f"$p`y + p`vy * dt;
        vx:"f"$p`vx * p`decay;
        vy:"f"$p`vy * p`decay + (.[{x`gravity};cfg;{50f}])*dt;
        sz:"f"$p`size;
        c:p`color;
        alpha:1f-(age+dt)%maxAge;
        c[3]:"i"$c[3]*alpha;
        .raylib._sendCircle[px;py;sz*alpha;c];
        p[`x]:px;
        p[`y]:py;
        p[`vx]:vx;
        p[`vy]:vy;
        p[`age]:age+dt;
        updatedP,:enlist p];
      j+:1];
    s[`particles]:@[s[`particles];i;:;updatedP];
    i+:1];
  .raylib.particle._systems:s;
  :0
 };

.raylib.particle.draw:{[]
  :.raylib.particle.update[]
 };

.raylib.particle.list:{[]
  :select id,active,particleCount:count each .raylib.particle._systems`particles from .raylib.particle._systems
 };

.raylib.particle.clear:{[]
  .raylib.particle._systems:([] id:`symbol$(); config:(); particles:(); lastEmit:0#0p; active:0#0b);
  :0
 };
