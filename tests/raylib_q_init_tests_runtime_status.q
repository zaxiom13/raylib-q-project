/ --- Test Group 15: Runtime status, versions, and no-op controls ---
origNoopNotify:.raylib.noop.notify;
origNoopCount:.raylib.noop.count;
origNoopLastMsg:.raylib.noop.lastMsg;
origNoopLastTs:.raylib.noop.lastTs;

errNoopMode:.[.raylib.noop.mode;enlist 2i;{x}];
assertEq["noop.mode usage";errNoopMode;"usage: .raylib.noop.mode[0|1]"];
assertEq["noop.mode off";.raylib.noop.mode 0i;0b];
assertEq["noop.mode on";.raylib.noop.mode 1i;1b];

noopBefore:.raylib.noop.count;
.raylib._noop["status smoke";0N];
noopSnap:.raylib.noop.status[];
assertEq["noop.status notify";noopSnap`notify;.raylib.noop.notify];
assertEq["noop.status count increment";noopSnap`count;noopBefore+1i];
assertEq["noop.status last msg";noopSnap`lastMsg;"status smoke"];
assertEq["noop.status last ts set";(noopSnap`lastTs)=0Np;0b];

ver:.raylib.version[];
assertEq["version keys";key ver;`init`expectedRuntime`runtime`compatible];
assertEq["version init value";ver`init;.raylib.init.version];
assertEq["version expected value";ver`expectedRuntime;.raylib.runtime.expectedVersion];
assertEq["version runtime non-empty";0<count ver`runtime;1b];
assertEq["version compatible";ver`compatible;1b];

docStatus:.raylib.help `status;
assertEq["help status exact";docStatus;"Return runtime diagnostics snapshot (transport, callbacks, scene/live counts, versions).\nusage: .raylib.status[]"];
docVersion:.raylib.help `version;
assertEq["help version exact";docVersion;"Return init/runtime version metadata and compatibility flag.\nusage: .raylib.version[]"];
docNoopMode:.raylib.help `noop.mode;
assertEq["help noop.mode exact";docNoopMode;"Enable or disable no-op console notifications.\nusage: .raylib.noop.mode[0|1]"];
docNoopStatus:.raylib.help `noop.status;
assertEq["help noop.status exact";docNoopStatus;"Return no-op notification state and last message metadata.\nusage: .raylib.noop.status[]"];

origSceneRows:.raylib.scene._rows;
origSceneNextOrd:.raylib.scene._nextOrd;
origFrameCbs:.raylib.frame._callbacks;
origFrameNextId:.raylib.frame._nextId;
origEventCbs:.raylib.events._callbacks;
origEventNextId:.raylib.events._nextId;
origLive:.raylib.interactive._live;
origLiveNext:.raylib.interactive._nextLive;

.raylib.scene._rows:([] id:`s1`s2`s3; kind:`circle`rect`text; src:(`a;`b;`c); bindings:(()!();()!();()!()); layer:0 0 1i; visible:101b; ord:0 1 2i);
.raylib.scene._nextOrd:3i;
.raylib.frame._callbacks:.raylib._callbacks.empty[];
.raylib.frame._nextId:0i;
.raylib._callbacks.on[`.raylib.frame._callbacks;`.raylib.frame._nextId;{[state] :state}];
.raylib._callbacks.on[`.raylib.frame._callbacks;`.raylib.frame._nextId;{[state] :state}];
.raylib.events._callbacks:.raylib._callbacks.empty[];
.raylib.events._nextId:0i;
.raylib._callbacks.on[`.raylib.events._callbacks;`.raylib.events._nextId;{[ev] :ev}];
.raylib.interactive._live:([] id:0 1i; kind:`circle`text; src:(`l1;`l2));
.raylib.interactive._nextLive:2i;

st:.raylib.status[];
assertEq["status draw target mirrors getter";st`drawTarget;.draw.target.get[]];
assertEq["status transport mode";st`transportMode;.raylib.transport.mode];
assertEq["status scene rows";st`sceneRows;3i];
assertEq["status scene visible";st`sceneVisible;2i];
assertEq["status frame callbacks";st`frameCallbacks;2i];
assertEq["status event callbacks";st`eventCallbacks;1i];
assertEq["status interactive live";st`interactiveLive;2i];
assertEq["status noop count mirrors state";st`noopCount;.raylib.noop.count];
assertEq["status noop msg mirrors state";st`noopLast;.raylib.noop.lastMsg];
assertEq["status init version";st`initVersion;.raylib.init.version];
assertEq["status runtime version";st`runtimeVersion;ver`runtime];
assertEq["status version compatible";st`versionCompatible;ver`compatible];

.raylib.scene._rows:origSceneRows;
.raylib.scene._nextOrd:origSceneNextOrd;
.raylib.frame._callbacks:origFrameCbs;
.raylib.frame._nextId:origFrameNextId;
.raylib.events._callbacks:origEventCbs;
.raylib.events._nextId:origEventNextId;
.raylib.interactive._live:origLive;
.raylib.interactive._nextLive:origLiveNext;
.raylib.noop.notify:origNoopNotify;
.raylib.noop.count:origNoopCount;
.raylib.noop.lastMsg:origNoopLastMsg;
.raylib.noop.lastTs:origNoopLastTs;
