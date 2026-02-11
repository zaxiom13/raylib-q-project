/ Runtime diagnostics and version metadata.

.raylib._stateVal:{[sym;d]
  :.[value;enlist sym;{d}]
 };

.raylib._rowCount:{[sym]
  t:.raylib._stateVal[sym;`missing];
  if[`missing~t; :0i];
  if[not any 98 99h=type t; :0i];
  :"i"$count t
 };

.raylib._sceneVisibleCount:{[]
  s:.raylib._stateVal[`.raylib.scene._rows;`missing];
  if[`missing~s; :0i];
  if[not any 98 99h=type s; :0i];
  :.[{"i"$sum 0<>"i"$x`visible};enlist s;{0i}]
 };

.raylib._runtimeVersionCached:{[]
  if[0<count .raylib.runtime.version; :.raylib.runtime.version];
  :$[.raylib.native.loaded;.raylib.native.version[];""]
 };

.raylib.version:{[]
  rv:.raylib._runtimeVersionCached[];
  if[(0=count rv)&(not .raylib.native.loaded);
    if[.raylib.native._load[];
      rv:.raylib.native.version[];
      .raylib.runtime.version:rv]];
  :`init`expectedRuntime`runtime`compatible!(
    .raylib.init.version;
    .raylib.runtime.expectedVersion;
    rv;
    (0<count rv)&(rv~.raylib.runtime.expectedVersion))
 };

.raylib.noop.mode:{[flag]
  usage:"usage: .raylib.noop.mode[0|1]";
  on:"i"$flag;
  if[not any on=/:0 1; 'usage];
  .raylib.noop.notify:on=1i;
  :.raylib.noop.notify
 };

.raylib.noop.status:{[]
  :`notify`count`lastMsg`lastTs!(
    .raylib.noop.notify;
    .raylib.noop.count;
    .raylib.noop.lastMsg;
    .raylib.noop.lastTs)
 };

.raylib.status:{[]
  rv:.raylib._runtimeVersionCached[];
  compat:(0<count rv)&(rv~.raylib.runtime.expectedVersion);
  :`time`drawTarget`transportMode`runtimeOpen`nativeLoaded`nativeOpen`autoPumpEnabled`autoPumpActive`interactiveActive`sceneRows`sceneVisible`frameCallbacks`eventCallbacks`interactiveLive`noopNotify`noopCount`noopLast`initVersion`runtimeVersion`versionCompatible!(
    .z.p;
    .raylib._drawTargetCurrent[];
    .raylib.transport.mode;
    .raylib._runtimeOpen;
    .raylib.native.loaded;
    $[.raylib.native.loaded;.raylib.native.isOpen[];0b];
    .raylib.autoPump.enabled;
    .raylib.autoPump.active;
    .raylib.interactive.active;
    .raylib._rowCount[`.raylib.scene._rows];
    .raylib._sceneVisibleCount[];
    .raylib._rowCount[`.raylib.frame._callbacks];
    .raylib._rowCount[`.raylib.events._callbacks];
    .raylib._rowCount[`.raylib.interactive._live];
    .raylib.noop.notify;
    .raylib.noop.count;
    .raylib.noop.lastMsg;
    .raylib.init.version;
    rv;
    compat)
 };
