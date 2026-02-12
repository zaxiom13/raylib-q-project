.raylib.safe._lastError:"";
.raylib.safe._errorLog:([] ts:`timestamp$(); msg:(); ctx:());
.raylib.safe._retryCount:3i;
.raylib.safe._retryDelay:100;

.raylib.safe.try:{[fn]
  :.[fn;();{.raylib.safe._lastError:x; x}]
 };

.raylib.safe.tryWith:{[fn;default]
  :.[fn;();{.raylib.safe._lastError:x; default}]
 };

.raylib.safe.tryLog:{[fn;ctx]
  :.[fn;();{.raylib.safe._recordError[x;ctx]; x}]
 };

.raylib.safe._recordError:{[err;ctx]
  .raylib.safe._lastError:string err;
  .raylib.safe._errorLog,: ([] ts:enlist .z.t; msg:enlist err; ctx:enlist ctx);
  :err
 };

.raylib.safe.retry:{[fn;times;delay]
  if[times<1; times:1i];
  i:0i;
  lastErr:"";
  while[i<times;
    r:.[fn;();{lastErr::x; `error}];
    if[not `error~r; :r];
    if[(i<times-1)&(delay>0);
      system "sleep ",string delay%1000];
    i+:1];
  'lastErr
 };

.raylib.safe.retryDefault:{[fn;times;default]
  r:.raylib.safe.retry[fn;times;0];
  if[`error~r; :default];
  :r
 };

.raylib.safe.getError:{
  :.raylib.safe._lastError
 };

.raylib.safe.clearError:{
  .raylib.safe._lastError:"";
  :0
 };

.raylib.safe.getErrorLog:{
  :.raylib.safe._errorLog
 };

.raylib.safe.clearErrorLog:{
  .raylib.safe._errorLog:([] ts:`timestamp$(); msg:(); ctx:());
  :0
 };

.raylib.safe.guard:{[fn;onError]
  :.[fn;();{onError x}]
 };

.raylib.safe.fallback:{[primary;fallback]
  r:.[primary;();{`error}];
  if[`error~r; :.[fallback;();{x}]];
  :r
 };

.raylib.safe.chain:{[fns]
  if[0=count fns; :::];
  i:0;
  v:();
  while[i<count fns;
    fn:fns i;
    v:.[fn;enlist v;{.raylib.safe._recordError[x;`chain@i]; `error}];
    if[`error~v; :v];
    i+:1];
  :v
 };

.raylib.safe.wrap:{[ns;fns]
  if[not -11h=type ns; '"ns must be symbol"];
  if[not 11h=type fns; '"fns must be symbol vector"];
  i:0;
  while[i<count fns;
    fn:fns i;
    origSym:`$raze("/"sv string each (ns;fn));
    safeSym:`$raze("/"sv string each (ns;"_unsafe_",string fn));
    if[not 11h=type value origSym;
      i+:1;
      next];
    origFn:value origSym;
    safeFn:{[f;x] .[f;enlist x;{.raylib.safe._recordError[x;`origSym]; `error}]}[origFn];
    safeFn:@[safeFn;`origSym;:;origSym];
    set[safeSym;origFn];
    set[origSym;safeFn];
    i+:1];
  :count fns
 };

.raylib.safe.draw:{[t;kind]
  usage:"usage: .raylib.safe.draw[t;`kind] - safely draw with error recovery";
  if[not kind in `triangle`circle`square`rect`line`point`text`pixels; 'usage];
  :.[{[tk;tb] .raylib.draw[tk;tb]}(kind;t);{.raylib.safe._recordError[x;`draw@kind]; 0}]
 };

.raylib.safe.sceneUpsert:{[id;kind;src]
  :.[{[i;k;s] .raylib.scene.upsert[i;k;s]}(id;kind;src);{.raylib.safe._recordError[x;`sceneUpsert]; 0}]
 };

.raylib.safe.sceneDraw:{
  :.[{.raylib.refresh[]};{.raylib.safe._recordError[x;`sceneDraw]; 0}]
 };

.raylib.safe.uiFrame:{[fn]
  :.[{.raylib.ui.frame[x]}enlist fn;{.raylib.safe._recordError[x;`uiFrame]; 0}]
 };

.raylib.validate.table:{[t;required;optional]
  if[not any (type t)=98 99; '"type"];
  c:cols t;
  missing:required where not required in c;
  if[0<count missing; '"cols: missing ","," sv string each missing];
  :1b
 };

.raylib.validate.tableSafe:{[t;required;optional]
  :.[{.raylib.validate.table[x;y;z]}(t;required;optional);{0b}]
 };

.raylib.validate.range:{[val;lo;hi]
  :val>=lo&val<=hi
 };

.raylib.validate.positive:{[val]
  :val>0
 };

.raylib.validate.nonEmpty:{[s]
  if[-11h=type s; :0<count s];
  if[10h=type s; :0<count s];
  :0b
 };

.raylib.recover.scene:{
  .raylib.safe.clearError[];
  .raylib.scene.reset[];
  :1b
 };

.raylib.recover.ui:{
  .raylib.ui.state.reset[];
  .raylib.safe.clearError[];
  :1b
 };

.raylib.recover.particles:{
  .raylib.particle.clear[];
  :1b
 };

.raylib.recover.all:{
  .raylib.recover.scene[];
  .raylib.recover.ui[];
  .raylib.recover.particles[];
  .raylib.safe.clearError[];
  :1b
 };
