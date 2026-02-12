.raylib.debug._traceLog:();
.raylib.debug.enabled:0b;
.raylib.debug.level:`info;
.raylib.debug._levels:`trace`debug`info`warn`error`fatal;
.raylib.debug._levelOrder:`trace`debug`info`warn`error`fatal!(0;1;2;3;4;5);

.raylib.debug.enable:{[on]
  .raylib.debug.enabled:$[on;1b;0b];
  :.raylib.debug.enabled
 };

.raylib.debug.setLevel:{[level]
  if[not level in .raylib.debug._levels; '"invalid level"];
  .raylib.debug.level:level;
  :level
 };

.raylib.debug._shouldLog:{[level]
  if[not .raylib.debug.enabled; :0b];
  :.raylib.debug._levelOrder[level]>=.raylib.debug._levelOrder[.raylib.debug.level]
 };

.raylib.debug._formatMsg:{[level;msg]
  ts:string .z.t;
  :raze ("[",ts,"] [",string level,"] ",msg)
 };

.raylib.debug.log:{[level;msg]
  if[not .raylib.debug._shouldLog level; :0b];
  entry:`ts`level`msg!(.z.t;level;msg);
  .raylib.debug._traceLog,:enlist entry;
  formatted:.raylib.debug._formatMsg[level;msg];
  $[level in `error`fatal;-2 formatted;-1 formatted];
  :1b
 };

.raylib.debug.trace:{[msg] :.raylib.debug.log[`trace;msg] };
.raylib.debug.debug:{[msg] :.raylib.debug.log[`debug;msg] };
.raylib.debug.info:{[msg] :.raylib.debug.log[`info;msg] };
.raylib.debug.warn:{[msg] :.raylib.debug.log[`warn;msg] };
.raylib.debug.error:{[msg] :.raylib.debug.log[`error;msg] };
.raylib.debug.fatal:{[msg] :.raylib.debug.log[`fatal;msg] };

.raylib.debug.clearLog:{
  .raylib.debug._traceLog:();
  :0
 };

.raylib.debug.getLog:{
  :.raylib.debug._traceLog
 };

.raylib.debug.getLogByLevel:{[level]
  :select from .raylib.debug._traceLog where level=level
 };

.raylib.debug.dump:{
  -1 "\n=== raylib-q debug dump ===";
  -1 "Version: ",.raylib.runtime.version;
  -1 "Runtime open: ",string .raylib._runtimeOpen;
  -1 "Native loaded: ",string .raylib.native.loaded;
  -1 "AutoPump: ",string .raylib.autoPump.active;
  -1 "Scene items: ",string count .raylib.scene._rows;
  -1 "UI state entries: ",string count .raylib.ui._btnState;
  -1 "Particle systems: ",string count .raylib.particle._systems;
  -1 "Log entries: ",string count .raylib.debug._traceLog;
  -1 "===========================\n";
  :0
 };

.raylib.debug.perf._timers:()!();
.raylib.debug.perf._samples:()!();

.raylib.debug.perf.start:{[name]
  .raylib.debug.perf._timers[name]:.z.p;
  :0b
 };

.raylib.debug.perf.end:{[name]
  if[not name in key .raylib.debug.perf._timers; :0f];
  elapsed:.z.p-.raylib.debug.perf._timers name;
  ms:"f"$elapsed%1000000;
  if[not name in key .raylib.debug.perf._samples;
    .raylib.debug.perf._samples[name]:()];
  .raylib.debug.perf._samples[name],:enlist ms;
  .raylib.debug.perf._timers:@[.raylib.debug.perf._timers;name;:;];
  :ms
 };

.raylib.debug.perf.stats:{[name]
  if[not name in key .raylib.debug.perf._samples; :()!()];
  s:.raylib.debug.perf._samples[name];
  :`min`max`avg`count`last!(min s;max s;(sum s)%count s;count s;last s)
 };

.raylib.debug.perf.report:{
  out:"\n=== Performance Report ===\n";
  perfKeys:key .raylib.debug.perf._samples;
  i:0;
  while[i<count perfKeys;
    k:perfKeys i;
    stats:.raylib.debug.perf.stats k;
    out,:raaze ("\n  ",string k,": avg=",string stats`avg,"ms, min=",string stats`min,"ms, max=",string stats`max,"ms, count=",string stats`count);
    i+:1];
  out,"\n=========================\n";
  -1 out;
  :0
 };

.raylib.debug.perf.clear:{
  .raylib.debug.perf._timers:()!();
  .raylib.debug.perf._samples:()!();
  :0
 };

.raylib.debug.inspect:{[val]
  t:type val;
  -1 "\n=== Inspect ===";
  -1 "Type: ",string t;
  -1 "Count: ",string count val;
  if[98h=type val;
    -1 "Cols: "," " sv string each cols val];
  if[99h=type val;
    -1 "Keys: "," " sv string each key val];
  -1 "==============";
  :val
 };

.raylib.debug.watch:{[name;expr]
  v:.[value;enlist expr;{`error}];
  ts:string .z.t;
  msg:raze ("[WATCH ",ts,"] ",string name,": ",$[`error~v;"ERROR";string v]);
  -1 msg;
  :v
 };

.raylib.debug.breakpoint:{[cond]
  if[cond;
    -1 "\n=== BREAKPOINT ===";
    -1 "Condition met at ",string .z.t;
    -1 "Press Enter to continue...";
    system "read _"];
  :0
 };

.raylib.debug.assert:{[cond;msg]
  if[not cond;
    emsg:"Assertion failed: ",msg," at ",string .z.t;
    .raylib.debug.error emsg;
    'emsg];
  :1b
 };
