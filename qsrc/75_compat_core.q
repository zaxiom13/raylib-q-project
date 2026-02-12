/ Legacy binding facade over the table-first raylib-q surface.
/ Exposes full legacy binding names under `.raylib.<BindingName>` with best-effort behavior.

.raylib.api._bindings:`InitWindow`SetTraceLogLevel`SetTargetFPS`GetFrameTime`GetTime`GetFPS`WindowShouldClose`IsWindowReady`IsWindowFullscreen`IsWindowHidden`IsWindowMinimized`IsWindowMaximized`IsWindowFocused`IsWindowResized`IsWindowState`SetWindowState`ClearWindowState`SetConfigFlags`ToggleFullscreen`CloseWindow`GetScreenWidth`GetScreenHeight`GetRenderWidth`GetRenderHeight`GetWindowScaleDPI`GetCurrentMonitor`GetMonitorWidth`GetMonitorHeight`SetWindowSize`ClearBackground`BeginDrawing`EndDrawing`BeginModeThreeD`EndModeThreeD`UpdateCamera`UpdateCameraPro`IsMouseButtonPressed`IsMouseButtonDown`IsMouseButtonReleased`IsMouseButtonUp`GetMousePosition`GetMouseDelta`SetMousePosition`GetMouseWheelMove`GetMouseWheelMoveV`ShowCursor`HideCursor`IsCursorHidden`IsCursorOnScreen`EnableCursor`DisableCursor`IsKeyPressed`IsKeyPressedRepeat`IsKeyDown`IsKeyReleased`IsKeyUp`GetKeyPressed`GetCharPressed`SetExitKey`IsGamepadAvailable`GetGamepadName`IsGamepadButtonPressed`IsGamepadButtonDown`IsGamepadButtonReleased`IsGamepadButtonUp`GetGamepadButtonPressed`GetGamepadAxisCount`GetGamepadAxisMovement`SetGamepadMappings`SetGamepadVibration`DrawPixel`DrawLine`DrawLineEx`DrawLineStrip`DrawLineBezier`DrawCircle`DrawCircleLines`DrawCircleSector`DrawCircleSectorLines`DrawEllipse`DrawEllipseLines`DrawRing`DrawRingLines`DrawRectangle`DrawRectangleLines`DrawTriangle`DrawTriangleLines`DrawPoly`DrawPolyLines`GetFontDefault`LoadFont`LoadFontEx`IsFontValid`UnloadFont`DrawText`DrawTextEx`MeasureText`MeasureTextEx`DrawCube`DrawCubeWires`UploadMesh`GenMeshPoly`GenMeshPlane`GenMeshCube`GenMeshSphere`LoadModel`LoadModelFromMesh`DrawModel`DrawModelEx`GenImageColor`UnloadImage`LoadImageFromScreen`LoadImageFromTexture`LoadTextureFromImage`LoadTexture`UpdateTexture`UpdateTextureRec`UnloadTexture`DrawTexture`DrawTextureEx`DrawTextureRec`DrawTexturePro`LoadRenderTexture`UnloadRenderTexture`BeginTextureMode`EndTextureMode`CheckCollisionRecs`CheckCollisionCircles`CheckCollisionCircleRec`CheckCollisionCircleLine`CheckCollisionPointRec`CheckCollisionPointCircle`CheckCollisionPointTriangle`CheckCollisionPointLine`CheckCollisionPointPoly`CheckCollisionLines`GetCollisionRec`InitAudioDevice`CloseAudioDevice`IsAudioDeviceReady`SetMasterVolume`GetMasterVolume`LoadWave`LoadWaveFromMemory`IsWaveValid`LoadSound`LoadSoundFromWave`LoadSoundAlias`IsSoundValid`UpdateSound`UnloadWave`UnloadSound`UnloadSoundAlias`PlaySound`StopSound`PauseSound`ResumeSound`IsSoundPlaying`SetSoundVolume;
.raylib.api._argCount:.raylib.api._bindings!"I"$" " vs "3 1 1 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0 1 1 2 1 0 0 1 0 3 5 1 1 1 1 0 0 2 0 0 0 0 0 0 0 0 1 1 1 1 1 0 0 1 1 1 2 2 2 2 0 1 2 1 4 2 3 4 3 4 3 3 6 6 5 5 7 7 3 5 4 4 5 5 0 1 4 1 1 5 6 2 4 3 3 3 2 4 3 3 1 1 4 6 3 1 0 1 1 1 2 3 1 3 5 4 6 2 1 1 0 2 4 3 4 2 3 4 4 3 4 2 0 0 0 1 0 1 3 1 1 1 1 1 3 1 1 1 1 1 1 1 1 2";

.raylib.api._usageOf:{[name]
  if[not name in .raylib.api._bindings;
    :"usage: unknown .raylib legacy binding"];
  n:.raylib.api._argCount name;
  argNames:{"arg",string x} each 1+til n;
  args:$[n=0;"";";" sv argNames];
  if[("Draw"~4#string name)&n>1;
    :raze ("Legacy wrapper for ",string name," (table-first preferred).\nusage: .raylib.",string name,"[table] or .raylib.",string name,"[",args,"]")];
  :raze ("Legacy wrapper for binding ",string name,".\nusage: .raylib.",string name,"[",args,"]")
 };

legacyUsageRaw:.raylib.api._usageOf each .raylib.api._bindings;
.raylib.api._usage:.raylib.api._bindings!{raze string x} each legacyUsageRaw;

.raylib.api._ensureUsage:{[name;a]
  if[not name in .raylib.api._bindings;
    '"usage: unknown .raylib legacy binding"];
  usage:.raylib.api._usage name;
  if[((count a)=1)&("Draw"~4#string name)&.raylib.api._isTableFirstDrawArg first a;
    :`ok];
  if[(count a)<>.raylib.api._argCount name;
    :usage];
  :`ok
 };

.raylib.api._state:`traceLog`windowFlags`configFlags`fullscreen`hidden`minimized`maximized`focused`cursorHidden`windowW`windowH`clearColor`exitKey!(3i;0i;0i;0b;0b;0b;0b;1b;0b;800i;450i;.raylib.Color.WHITE;256i);
.raylib.api._nextHandle:0i;
.raylib.api._audioReady:0b;
.raylib.api._masterVolume:1f;
.raylib.api._sounds:([] id:`int$(); playing:0#0b; volume:`float$());

.raylib.api._args:{[args]
  if[0h=type args; :args];
  :enlist args
 };

.raylib.api._isTableFirstDrawArg:{[v]
  :(98h=type v)|(99h=type v)|(-11h=type v)
 };

.raylib.api._arg:{[a;i;d]
  if[i<count a; :a i];
  :d
 };

.raylib.api._int:{[v;d]
  :.[{"i"$x};enlist v;{d}]
 };

.raylib.api._float:{[v;d]
  :.[{"f"$x};enlist v;{d}]
 };

.raylib.api._bool:{[v]
  :0<.raylib.api._int[v;0i]
 };

.raylib.api._vec2:{[v;d]
  if[0h=type v;
    if[count v>=2; :("f"$v 0;"f"$v 1)]];
  if[(type v)>=0h;
    if[count v>=2; :("f"$v 0;"f"$v 1)]];
  :d
 };

.raylib.api._rect4:{[v;d]
  if[0h=type v;
    if[count v>=4; :("f"$v 0;"f"$v 1;"f"$v 2;"f"$v 3)]];
  if[(type v)>=0h;
    if[count v>=4; :("f"$v 0;"f"$v 1;"f"$v 2;"f"$v 3)]];
  :d
 };

.raylib.api._rgba:{[v;d]
  :.[.raylib._rgba4;enlist v;{d}]
 };

.raylib.api._handle:{[kind;payload]
  id:.raylib.api._nextHandle;
  .raylib.api._nextHandle+:1i;
  :`kind`id`payload!(kind;id;payload)
 };

.raylib.api._eventTable:{[]
  ev:.[value;enlist `.raylib.events.last;{.raylib.events._empty[]}];
  if[98h<>type ev; :flip `seq`time`type`a`b`c`d!(0#0j;0#0j;`symbol$();`int$();`int$();`int$();`int$())];
  :ev
 };

.raylib.api._eventAny:{[typ;code]
  ev:.raylib.api._eventTable[];
  if[0=count ev; :0b];
  mask:ev[`type]=typ;
  if[count code;
    mask:mask & ev[`a]=first code];
  :any mask
 };

.raylib.api._rectIntersect:{[a;b]
  ax:a 0; ay:a 1; aw:a 2; ah:a 3;
  bx:b 0; by:b 1; bw:b 2; bh:b 3;
  x:$[ax>bx;ax;bx];
  y:$[ay>by;ay;by];
  x2:$[(ax+aw)<(bx+bw);ax+aw;bx+bw];
  y2:$[(ay+ah)<(by+bh);ay+ah;by+bh];
  w:x2-x;
  h:y2-y;
  if[(w<=0f)|(h<=0f); :(0f;0f;0f;0f)];
  :(x;y;w;h)
 };

.raylib.api._dist2:{[a;b]
  dx:(a 0)-(b 0);
  dy:(a 1)-(b 1);
  :dx*dx+dy*dy
 };

.raylib.api._soundId:{[snd]
  :$[99h=type snd; .raylib.api._int[snd`id;-1i]; -1i]
 };

.raylib.api._noop:{[name;detail;ret]
  msg:raze ("legacy ",string name,": ",string detail);
  :.[.raylib._noop;(msg;ret);{ret}]
 };

/ --- Specific handlers ---
.raylib.api._hInitWindow:{[a] :.[.raylib.open;();{0b}] };
.raylib.api._hCloseWindow:{[a] :.[.raylib.close;();{0N}] };
.raylib.api._hSetTargetFPS:{[a] fps:.raylib.api._float[.raylib.api._arg[a;0;60f];60f]; if[fps<=0f; :.raylib.api._noop[`SetTargetFPS;"fps<=0 ignored";0N]]; :.[.raylib.frame.setDt;enlist 1f%fps;{0N}] };
.raylib.api._hGetFrameTime:{[a] :"f"$.raylib.frame._state`dt };
.raylib.api._hGetTime:{[a] :"f"$.raylib.frame._state`time };
.raylib.api._hGetFPS:{[a] dt:"f"$.raylib.frame._state`dt; :$[dt>0f;"i"$1f%dt;0i] };
.raylib.api._hWindowShouldClose:{[a] :.raylib.api._eventAny[`window_close;()] };
.raylib.api._hIsWindowReady:{[a] :.[{.raylib._runtimeOpen};();{0b}] };
.raylib.api._hSetWindowSize:{[a] w:.raylib.api._int[.raylib.api._arg[a;0;800i];800i]; h:.raylib.api._int[.raylib.api._arg[a;1;450i];450i]; .raylib.api._state[`windowW]:w; .raylib.api._state[`windowH]:h; `windowW set w; `windowH set h; :0N };
.raylib.api._hGetScreenWidth:{[a] :.[{"i"$value `windowW};();{.raylib.api._state`windowW}] };
.raylib.api._hGetScreenHeight:{[a] :.[{"i"$value `windowH};();{.raylib.api._state`windowH}] };
.raylib.api._hGetMousePosition:{[a] :(. [value;enlist `mx;{0f}]; . [value;enlist `my;{0f}]) };
.raylib.api._hGetMouseDelta:{[a] :(. [value;enlist `mdx;{0f}]; . [value;enlist `mdy;{0f}]) };
.raylib.api._hGetMouseWheelMove:{[a] :.[{"f"$value `mwheel};();{0f}] };
.raylib.api._hGetMouseWheelMoveV:{[a] :0f,.raylib.api._hGetMouseWheelMove[()] };
.raylib.api._hIsMouseButtonPressed:{[a] btn:.raylib.api._int[.raylib.api._arg[a;0;0i];0i]; :.raylib.api._eventAny[`mouse_down;enlist btn] };
.raylib.api._hIsMouseButtonReleased:{[a] btn:.raylib.api._int[.raylib.api._arg[a;0;0i];0i]; :.raylib.api._eventAny[`mouse_up;enlist btn] };
.raylib.api._hIsMouseButtonDown:{[a] btn:.raylib.api._int[.raylib.api._arg[a;0;0i];0i]; mp:. [value;enlist `mpressed;{0b}]; mb:. [value;enlist `mbutton;{-1i}]; :("i"$mb=btn)&.raylib.api._bool mp };
.raylib.api._hIsMouseButtonUp:{[a] :not .raylib.api._hIsMouseButtonDown[a] };
.raylib.api._hIsKeyPressed:{[a] k:.raylib.api._int[.raylib.api._arg[a;0;0i];0i]; :.raylib.api._eventAny[`key_down;enlist k] };
.raylib.api._hIsKeyPressedRepeat:{[a] :.raylib.api._hIsKeyPressed[a] };
.raylib.api._hIsKeyDown:{[a] k:.raylib.api._int[.raylib.api._arg[a;0;0i];0i]; mk:. [value;enlist `mkey;{0i}]; :("i"$mk)=k };
.raylib.api._hIsKeyReleased:{[a] k:.raylib.api._int[.raylib.api._arg[a;0;0i];0i]; :.raylib.api._eventAny[`key_up;enlist k] };
.raylib.api._hIsKeyUp:{[a] :not .raylib.api._hIsKeyDown[a] };
.raylib.api._hGetKeyPressed:{[a] ev:.raylib.api._eventTable[]; idx:where ev[`type]=`key_down; :$[count idx; ev[`a] first idx; 0i] };
.raylib.api._hGetCharPressed:{[a] ev:.raylib.api._eventTable[]; idx:where ev[`type]=`char_input; :$[count idx; ev[`a] first idx; 0i] };

.raylib.api._hDrawPixel:{[a]
  t0:.raylib.api._arg[a;0;()];
  if[any 98 99h=type t0; :.[.raylib.point;enlist t0;{0N}]];
  p:.raylib.api._vec2[t0;0 0f]; clr:.raylib.api._rgba[.raylib.api._arg[a;1;.raylib.Color.BLACK];.raylib.Color.BLACK];
  t:([] x:enlist p 0; y:enlist p 1; color:enlist clr);
  :.[.raylib.point;enlist t;{0N}]
 };

.raylib.api._hDrawLine:{[a]
  t0:.raylib.api._arg[a;0;()];
  if[any 98 99h=type t0; :.[.raylib.line;enlist t0;{0N}]];
  p1:.raylib.api._vec2[t0;0 0f]; p2:.raylib.api._vec2[.raylib.api._arg[a;1;0 0f];0 0f]; clr:.raylib.api._rgba[.raylib.api._arg[a;2;.raylib.Color.BLACK];.raylib.Color.BLACK];
  t:([] x1:enlist p1 0; y1:enlist p1 1; x2:enlist p2 0; y2:enlist p2 1; color:enlist clr);
  :.[.raylib.line;enlist t;{0N}]
 };

.raylib.api._hDrawLineEx:{[a]
  t0:.raylib.api._arg[a;0;()];
  if[.raylib.api._isTableFirstDrawArg t0; :.[.raylib.line;enlist t0;{0N}]];
  p1:.raylib.api._vec2[.raylib.api._arg[a;0;0 0f];0 0f]; p2:.raylib.api._vec2[.raylib.api._arg[a;1;0 0f];0 0f]; th:.raylib.api._float[.raylib.api._arg[a;2;1f];1f]; clr:.raylib.api._rgba[.raylib.api._arg[a;3;.raylib.Color.BLACK];.raylib.Color.BLACK];
  t:([] x1:enlist p1 0; y1:enlist p1 1; x2:enlist p2 0; y2:enlist p2 1; thickness:enlist th; color:enlist clr);
  :.[.raylib.line;enlist t;{0N}]
 };

.raylib.api._hDrawCircle:{[a]
  t0:.raylib.api._arg[a;0;()];
  if[any 98 99h=type t0; :.[.raylib.circle;enlist t0;{0N}]];
  c:.raylib.api._vec2[t0;0 0f]; r:.raylib.api._float[.raylib.api._arg[a;1;1f];1f]; clr:.raylib.api._rgba[.raylib.api._arg[a;2;.raylib.Color.BLUE];.raylib.Color.BLUE];
  t:([] x:enlist c 0; y:enlist c 1; r:enlist r; color:enlist clr);
  :.[.raylib.circle;enlist t;{0N}]
 };

.raylib.api._hDrawRectangle:{[a]
  t0:.raylib.api._arg[a;0;()];
  if[any 98 99h=type t0; :.[.raylib.rect;enlist t0;{0N}]];
  p:.raylib.api._vec2[t0;0 0f]; sz:.raylib.api._vec2[.raylib.api._arg[a;1;1 1f];1 1f]; clr:.raylib.api._rgba[.raylib.api._arg[a;2;.raylib.Color.ORANGE];.raylib.Color.ORANGE];
  t:([] x:enlist p 0; y:enlist p 1; w:enlist sz 0; h:enlist sz 1; color:enlist clr);
  :.[.raylib.rect;enlist t;{0N}]
 };

.raylib.api._hDrawText:{[a]
  t0:.raylib.api._arg[a;0;()];
  if[.raylib.api._isTableFirstDrawArg t0; :.[.raylib.text;enlist t0;{0N}]];
  txt:string .raylib.api._arg[a;0;""]; p:.raylib.api._vec2[.raylib.api._arg[a;1;0 0f];0 0f]; sz:.raylib.api._int[.raylib.api._arg[a;2;20i];20i]; clr:.raylib.api._rgba[.raylib.api._arg[a;3;.raylib.Color.BLACK];.raylib.Color.BLACK];
  t:([] x:enlist p 0; y:enlist p 1; text:enlist txt; size:enlist sz; color:enlist clr);
  :.[.raylib.text;enlist t;{0N}]
 };

.raylib.api._hMeasureText:{[a] txt:string .raylib.api._arg[a;0;""]; sz:.raylib.api._int[.raylib.api._arg[a;1;20i];20i]; :"i"$.raylib.ui._textWidth[txt;sz] };
.raylib.api._hMeasureTextEx:{[a] txt:string .raylib.api._arg[a;1;""]; sz:.raylib.api._float[.raylib.api._arg[a;2;20f];20f]; :(.raylib.ui._textWidth[txt;sz];sz) };

.raylib.api._hCollisionRecs:{[a] r1:.raylib.api._rect4[.raylib.api._arg[a;0;0 0 0 0f];0 0 0 0f]; r2:.raylib.api._rect4[.raylib.api._arg[a;1;0 0 0 0f];0 0 0 0f]; rr:.raylib.api._rectIntersect[r1;r2]; :(rr 2)>0f & (rr 3)>0f };
.raylib.api._hCollisionCircles:{[a] c1:.raylib.api._vec2[.raylib.api._arg[a;0;0 0f];0 0f]; r1:.raylib.api._float[.raylib.api._arg[a;1;0f];0f]; c2:.raylib.api._vec2[.raylib.api._arg[a;2;0 0f];0 0f]; r2:.raylib.api._float[.raylib.api._arg[a;3;0f];0f]; :.raylib.api._dist2[c1;c2] <= (r1+r2)*(r1+r2) };
.raylib.api._hCollisionCircleRec:{[a] c:.raylib.api._vec2[.raylib.api._arg[a;0;0 0f];0 0f]; r:.raylib.api._float[.raylib.api._arg[a;1;0f];0f]; rec:.raylib.api._rect4[.raylib.api._arg[a;2;0 0 0 0f];0 0 0 0f]; cx:$[(c 0)<rec 0;rec 0;$[(c 0)>(rec 0+rec 2);rec 0+rec 2;c 0]]; cy:$[(c 1)<rec 1;rec 1;$[(c 1)>(rec 1+rec 3);rec 1+rec 3;c 1]]; :.raylib.api._dist2[c;(cx;cy)]<=r*r };
.raylib.api._hCollisionPointRec:{[a] p:.raylib.api._vec2[.raylib.api._arg[a;0;0 0f];0 0f]; r:.raylib.api._rect4[.raylib.api._arg[a;1;0 0 0 0f];0 0 0 0f]; :((p 0)>=r 0)&((p 0)<=r 0+r 2)&((p 1)>=r 1)&((p 1)<=r 1+r 3) };
.raylib.api._hCollisionPointCircle:{[a] p:.raylib.api._vec2[.raylib.api._arg[a;0;0 0f];0 0f]; c:.raylib.api._vec2[.raylib.api._arg[a;1;0 0f];0 0f]; r:.raylib.api._float[.raylib.api._arg[a;2;0f];0f]; :.raylib.api._dist2[p;c]<=r*r };
.raylib.api._hGetCollisionRec:{[a] r1:.raylib.api._rect4[.raylib.api._arg[a;0;0 0 0 0f];0 0 0 0f]; r2:.raylib.api._rect4[.raylib.api._arg[a;1;0 0 0 0f];0 0 0 0f]; :.raylib.api._rectIntersect[r1;r2] };

.raylib.api._hInitAudio:{[a] .raylib.api._audioReady:1b; :0N };
.raylib.api._hCloseAudio:{[a] .raylib.api._audioReady:0b; :0N };
.raylib.api._hIsAudioReady:{[a] :.raylib.api._audioReady };
.raylib.api._hSetMasterVol:{[a] .raylib.api._masterVolume:.raylib.api._float[.raylib.api._arg[a;0;1f];1f]; :0N };
.raylib.api._hGetMasterVol:{[a] :.raylib.api._masterVolume };
.raylib.api._hLoadSound:{[a] h:.raylib.api._handle[`sound;a]; .raylib.api._sounds,: ([] id:enlist h`id; playing:enlist 0b; volume:enlist 1f); :h };
.raylib.api._hIsSoundValid:{[a] :99h=type .raylib.api._arg[a;0;()] };
.raylib.api._hPlaySound:{[a] id:.raylib.api._soundId .raylib.api._arg[a;0;()]; idx:where .raylib.api._sounds[`id]=id; if[count idx; .raylib.api._sounds[`playing]:@[.raylib.api._sounds[`playing];idx;:;(count idx)#enlist 1b]]; if[0=count idx; :.raylib.api._noop[`PlaySound;"unknown sound handle";0N]]; :0N };
.raylib.api._hStopSound:{[a] id:.raylib.api._soundId .raylib.api._arg[a;0;()]; idx:where .raylib.api._sounds[`id]=id; if[count idx; .raylib.api._sounds[`playing]:@[.raylib.api._sounds[`playing];idx;:;(count idx)#enlist 0b]]; if[0=count idx; :.raylib.api._noop[`StopSound;"unknown sound handle";0N]]; :0N };
.raylib.api._hIsSoundPlaying:{[a] id:.raylib.api._soundId .raylib.api._arg[a;0;()]; idx:where .raylib.api._sounds[`id]=id; :$[count idx; .raylib.api._sounds[`playing] first idx; 0b] };
.raylib.api._hSetSoundVolume:{[a] id:.raylib.api._soundId .raylib.api._arg[a;0;()]; vol:.raylib.api._float[.raylib.api._arg[a;1;1f];1f]; idx:where .raylib.api._sounds[`id]=id; if[count idx; .raylib.api._sounds[`volume]:@[.raylib.api._sounds[`volume];idx;:;(count idx)#enlist vol]]; if[0=count idx; :.raylib.api._noop[`SetSoundVolume;"unknown sound handle";0N]]; :0N };

.raylib.api._handlers:`InitWindow`CloseWindow`SetTargetFPS`GetFrameTime`GetTime`GetFPS`WindowShouldClose`IsWindowReady`SetWindowSize`GetScreenWidth`GetScreenHeight`GetRenderWidth`GetRenderHeight`GetMousePosition`GetMouseDelta`GetMouseWheelMove`GetMouseWheelMoveV`IsMouseButtonPressed`IsMouseButtonDown`IsMouseButtonReleased`IsMouseButtonUp`IsKeyPressed`IsKeyPressedRepeat`IsKeyDown`IsKeyReleased`IsKeyUp`GetKeyPressed`GetCharPressed`DrawPixel`DrawLine`DrawLineEx`DrawCircle`DrawRectangle`DrawText`MeasureText`MeasureTextEx`CheckCollisionRecs`CheckCollisionCircles`CheckCollisionCircleRec`CheckCollisionPointRec`CheckCollisionPointCircle`GetCollisionRec`InitAudioDevice`CloseAudioDevice`IsAudioDeviceReady`SetMasterVolume`GetMasterVolume`LoadSound`LoadSoundFromWave`LoadSoundAlias`IsSoundValid`PlaySound`StopSound`PauseSound`ResumeSound`IsSoundPlaying`SetSoundVolume!(
  .raylib.api._hInitWindow;
  .raylib.api._hCloseWindow;
  .raylib.api._hSetTargetFPS;
  .raylib.api._hGetFrameTime;
  .raylib.api._hGetTime;
  .raylib.api._hGetFPS;
  .raylib.api._hWindowShouldClose;
  .raylib.api._hIsWindowReady;
  .raylib.api._hSetWindowSize;
  .raylib.api._hGetScreenWidth;
  .raylib.api._hGetScreenHeight;
  .raylib.api._hGetScreenWidth;
  .raylib.api._hGetScreenHeight;
  .raylib.api._hGetMousePosition;
  .raylib.api._hGetMouseDelta;
  .raylib.api._hGetMouseWheelMove;
  .raylib.api._hGetMouseWheelMoveV;
  .raylib.api._hIsMouseButtonPressed;
  .raylib.api._hIsMouseButtonDown;
  .raylib.api._hIsMouseButtonReleased;
  .raylib.api._hIsMouseButtonUp;
  .raylib.api._hIsKeyPressed;
  .raylib.api._hIsKeyPressedRepeat;
  .raylib.api._hIsKeyDown;
  .raylib.api._hIsKeyReleased;
  .raylib.api._hIsKeyUp;
  .raylib.api._hGetKeyPressed;
  .raylib.api._hGetCharPressed;
  .raylib.api._hDrawPixel;
  .raylib.api._hDrawLine;
  .raylib.api._hDrawLineEx;
  .raylib.api._hDrawCircle;
  .raylib.api._hDrawRectangle;
  .raylib.api._hDrawText;
  .raylib.api._hMeasureText;
  .raylib.api._hMeasureTextEx;
  .raylib.api._hCollisionRecs;
  .raylib.api._hCollisionCircles;
  .raylib.api._hCollisionCircleRec;
  .raylib.api._hCollisionPointRec;
  .raylib.api._hCollisionPointCircle;
  .raylib.api._hGetCollisionRec;
  .raylib.api._hInitAudio;
  .raylib.api._hCloseAudio;
  .raylib.api._hIsAudioReady;
  .raylib.api._hSetMasterVol;
  .raylib.api._hGetMasterVol;
  .raylib.api._hLoadSound;
  .raylib.api._hLoadSound;
  .raylib.api._hLoadSound;
  .raylib.api._hIsSoundValid;
  .raylib.api._hPlaySound;
  .raylib.api._hStopSound;
  .raylib.api._hStopSound;
  .raylib.api._hPlaySound;
  .raylib.api._hIsSoundPlaying;
  .raylib.api._hSetSoundVolume
 );

.raylib.api.call:{[name;args]
  a:.raylib.api._args args;
  chk:.raylib.api._ensureUsage[name;a];
  if[-11h<>type chk; :chk];
  if[name in key .raylib.api._handlers;
    :.[.raylib.api._handlers name;enlist a;{0N}]];

  / window state family
  if[name=`IsWindowFullscreen; :.raylib.api._state`fullscreen];
  if[name=`IsWindowHidden; :.raylib.api._state`hidden];
  if[name=`IsWindowMinimized; :.raylib.api._state`minimized];
  if[name=`IsWindowMaximized; :.raylib.api._state`maximized];
  if[name=`IsWindowFocused; :.raylib.api._state`focused];
  if[name=`IsWindowResized; :.raylib.api._eventAny[`window_resize;()]];
  if[name=`IsWindowState; f:.raylib.api._int[.raylib.api._arg[a;0;0i];0i]; :0i<>(.raylib.api._state`windowFlags) band f];
  if[name=`SetWindowState; f:.raylib.api._int[.raylib.api._arg[a;0;0i];0i]; .raylib.api._state[`windowFlags]:.raylib.api._state`windowFlags bor f; :0N];
  if[name=`ClearWindowState; f:.raylib.api._int[.raylib.api._arg[a;0;0i];0i]; .raylib.api._state[`windowFlags]:.raylib.api._state`windowFlags band not f; :0N];
  if[name=`SetConfigFlags; .raylib.api._state[`configFlags]:.raylib.api._int[.raylib.api._arg[a;0;0i];0i]; :0N];
  if[name=`ToggleFullscreen; .raylib.api._state[`fullscreen]:not .raylib.api._state`fullscreen; :0N];
  if[name=`GetWindowScaleDPI; :1 1f];
  if[name=`GetCurrentMonitor; :0i];
  if[name=`GetMonitorWidth; :1920i];
  if[name=`GetMonitorHeight; :1080i];
  if[name=`ClearBackground; .raylib.api._state[`clearColor]:.raylib.api._rgba[.raylib.api._arg[a;0;.raylib.Color.WHITE];.raylib.Color.WHITE]; :0N];
  if[name in `BeginDrawing`EndDrawing`BeginModeThreeD`EndModeThreeD`UpdateCamera`UpdateCameraPro`SetMousePosition; :.raylib.api._noop[name;"stubbed legacy call";0N]];
  if[name in `ShowCursor`EnableCursor;
    .raylib.api._state[`cursorHidden]:0b;
    :0N];
  if[name in `HideCursor`DisableCursor;
    .raylib.api._state[`cursorHidden]:1b;
    :0N];
  if[name=`SetTraceLogLevel;
    lvl:.raylib.api._int[.raylib.api._arg[a;0;.raylib.api._state`traceLog];.raylib.api._state`traceLog];
    .raylib.api._state[`traceLog]:lvl;
    :0N];
  if[name=`SetExitKey;
    exitKeyVal:.raylib.api._int[.raylib.api._arg[a;0;.raylib.api._state`exitKey];.raylib.api._state`exitKey];
    .raylib.api._state[`exitKey]:exitKeyVal;
    .raylib.interactive._escKey:exitKeyVal;
    :0N];
  if[name=`IsCursorHidden; :.raylib.api._state`cursorHidden];
  if[name=`IsCursorOnScreen; :1b];

  / drawing extensions not directly mapped yet
  if[name in `DrawLineStrip`DrawLineBezier`DrawCircleLines`DrawCircleSector`DrawCircleSectorLines`DrawEllipse`DrawEllipseLines`DrawRing`DrawRingLines`DrawRectangleLines`DrawTriangle`DrawTriangleLines`DrawPoly`DrawPolyLines`DrawTextEx; :.raylib.api._noop[name;"stubbed draw call";0N]];

  / 3D/model/font/image/texture are emulated handles
  s:string name;
  if[s like "Load*"; : .raylib.api._handle[name;a]];
  if[s like "Gen*"; : .raylib.api._handle[name;a]];
  if[s like "Unload*"; :.raylib.api._noop[name;"stubbed legacy call";0N]];
  if[s like "Update*"; :.raylib.api._noop[name;"stubbed legacy call";0N]];
  if[s like "Draw*"; :.raylib.api._noop[name;"stubbed legacy call";0N]];
  if[s like "CheckCollision*"; :0b];

  / gamepad defaults
  if[s like "IsGamepad*"; :0b];
  if[s like "GetGamepad*"; :0i];
  if[s like "SetGamepad*"; :.raylib.api._noop[name;"stubbed gamepad call";0N]];

  / wave/sound fallbacks
  if[s like "IsWave*"; :99h=type .raylib.api._arg[a;0;()]];
  if[s like "IsSound*"; :99h=type .raylib.api._arg[a;0;()]];

  if["Is"~2#s; :0b];
  if[s like "Get*"; :.raylib.api._noop[name;"default return from unimplemented get";0N]];
  :.raylib.api._noop[name;"unimplemented legacy call";0N]
 };

.raylib.api.help:{[]
  :([] name:.raylib.api._bindings; argc:.raylib.api._argCount .raylib.api._bindings)
 };

/ Deprecated alias kept for transition only.
.raylib.compat:.raylib.api;
