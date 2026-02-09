/ Compatibility facade over the table-first raylib-q surface.
/ Exposes full legacy binding names under `.raylib.<BindingName>` with best-effort behavior.

.raylib.compat._bindings:`InitWindow`SetTraceLogLevel`SetTargetFPS`GetFrameTime`GetTime`GetFPS`WindowShouldClose`IsWindowReady`IsWindowFullscreen`IsWindowHidden`IsWindowMinimized`IsWindowMaximized`IsWindowFocused`IsWindowResized`IsWindowState`SetWindowState`ClearWindowState`SetConfigFlags`ToggleFullscreen`CloseWindow`GetScreenWidth`GetScreenHeight`GetRenderWidth`GetRenderHeight`GetWindowScaleDPI`GetCurrentMonitor`GetMonitorWidth`GetMonitorHeight`SetWindowSize`ClearBackground`BeginDrawing`EndDrawing`BeginModeThreeD`EndModeThreeD`UpdateCamera`UpdateCameraPro`IsMouseButtonPressed`IsMouseButtonDown`IsMouseButtonReleased`IsMouseButtonUp`GetMousePosition`GetMouseDelta`SetMousePosition`GetMouseWheelMove`GetMouseWheelMoveV`ShowCursor`HideCursor`IsCursorHidden`IsCursorOnScreen`EnableCursor`DisableCursor`IsKeyPressed`IsKeyPressedRepeat`IsKeyDown`IsKeyReleased`IsKeyUp`GetKeyPressed`GetCharPressed`SetExitKey`IsGamepadAvailable`GetGamepadName`IsGamepadButtonPressed`IsGamepadButtonDown`IsGamepadButtonReleased`IsGamepadButtonUp`GetGamepadButtonPressed`GetGamepadAxisCount`GetGamepadAxisMovement`SetGamepadMappings`SetGamepadVibration`DrawPixel`DrawLine`DrawLineEx`DrawLineStrip`DrawLineBezier`DrawCircle`DrawCircleLines`DrawCircleSector`DrawCircleSectorLines`DrawEllipse`DrawEllipseLines`DrawRing`DrawRingLines`DrawRectangle`DrawRectangleLines`DrawTriangle`DrawTriangleLines`DrawPoly`DrawPolyLines`GetFontDefault`LoadFont`LoadFontEx`IsFontValid`UnloadFont`DrawText`DrawTextEx`MeasureText`MeasureTextEx`DrawCube`DrawCubeWires`UploadMesh`GenMeshPoly`GenMeshPlane`GenMeshCube`GenMeshSphere`LoadModel`LoadModelFromMesh`DrawModel`DrawModelEx`GenImageColor`UnloadImage`LoadImageFromScreen`LoadImageFromTexture`LoadTextureFromImage`LoadTexture`UpdateTexture`UpdateTextureRec`UnloadTexture`DrawTexture`DrawTextureEx`DrawTextureRec`DrawTexturePro`LoadRenderTexture`UnloadRenderTexture`BeginTextureMode`EndTextureMode`CheckCollisionRecs`CheckCollisionCircles`CheckCollisionCircleRec`CheckCollisionCircleLine`CheckCollisionPointRec`CheckCollisionPointCircle`CheckCollisionPointTriangle`CheckCollisionPointLine`CheckCollisionPointPoly`CheckCollisionLines`GetCollisionRec`InitAudioDevice`CloseAudioDevice`IsAudioDeviceReady`SetMasterVolume`GetMasterVolume`LoadWave`LoadWaveFromMemory`IsWaveValid`LoadSound`LoadSoundFromWave`LoadSoundAlias`IsSoundValid`UpdateSound`UnloadWave`UnloadSound`UnloadSoundAlias`PlaySound`StopSound`PauseSound`ResumeSound`IsSoundPlaying`SetSoundVolume;
.raylib.compat._argCount:.raylib.compat._bindings!"I"$" " vs "3 1 1 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0 1 1 2 1 0 0 1 0 3 5 1 1 1 1 0 0 2 0 0 0 0 0 0 0 0 1 1 1 1 1 0 0 1 1 1 2 2 2 2 0 1 2 1 4 2 3 4 3 4 3 3 6 6 5 5 7 7 3 5 4 4 5 5 0 1 4 1 1 5 6 2 4 3 3 3 2 4 3 3 1 1 4 6 3 1 0 1 1 1 2 3 1 3 5 4 6 2 1 1 0 2 4 3 4 2 3 4 4 3 4 2 0 0 0 1 0 1 3 1 1 1 1 1 3 1 1 1 1 1 1 1 1 2";

.raylib.compat._usageOf:{[name]
  if[not name in .raylib.compat._bindings;
    :"usage: unknown .raylib compatibility binding"];
  n:.raylib.compat._argCount name;
  argNames:{"arg",string x} each 1+til n;
  args:$[n=0;"";";" sv argNames];
  :raze ("Compatibility wrapper for legacy binding ",string name,".\nusage: .raylib.",string name,"[",args,"]")
 };

compatUsageRaw:.raylib.compat._usageOf each .raylib.compat._bindings;
.raylib.compat._usage:.raylib.compat._bindings!{raze string x} each compatUsageRaw;

.raylib.compat._ensureUsage:{[name;a]
  if[not name in .raylib.compat._bindings;
    '"usage: unknown .raylib compatibility binding"];
  usage:.raylib.compat._usage name;
  if[(count a)<>.raylib.compat._argCount name;
    :usage];
  :`ok
 };

.raylib.compat._state:`traceLog`windowFlags`configFlags`fullscreen`hidden`minimized`maximized`focused`cursorHidden`windowW`windowH`clearColor`exitKey!(3i;0i;0i;0b;0b;0b;0b;1b;0b;800i;450i;.raylib.Color.WHITE;256i);
.raylib.compat._nextHandle:0i;
.raylib.compat._audioReady:0b;
.raylib.compat._masterVolume:1f;
.raylib.compat._sounds:([] id:`int$(); playing:0#0b; volume:`float$());

.raylib.compat._args:{[args]
  if[0h=type args; :args];
  :enlist args
 };

.raylib.compat._arg:{[a;i;d]
  if[i<count a; :a i];
  :d
 };

.raylib.compat._int:{[v;d]
  :.[{"i"$x};enlist v;{d}]
 };

.raylib.compat._float:{[v;d]
  :.[{"f"$x};enlist v;{d}]
 };

.raylib.compat._bool:{[v]
  :0<.raylib.compat._int[v;0i]
 };

.raylib.compat._vec2:{[v;d]
  if[0h=type v;
    if[count v>=2; :("f"$v 0;"f"$v 1)]];
  if[(type v)>=0h;
    if[count v>=2; :("f"$v 0;"f"$v 1)]];
  :d
 };

.raylib.compat._rect4:{[v;d]
  if[0h=type v;
    if[count v>=4; :("f"$v 0;"f"$v 1;"f"$v 2;"f"$v 3)]];
  if[(type v)>=0h;
    if[count v>=4; :("f"$v 0;"f"$v 1;"f"$v 2;"f"$v 3)]];
  :d
 };

.raylib.compat._rgba:{[v;d]
  :.[.raylib._rgba4;enlist v;{d}]
 };

.raylib.compat._handle:{[kind;payload]
  id:.raylib.compat._nextHandle;
  .raylib.compat._nextHandle+:1i;
  :`kind`id`payload!(kind;id;payload)
 };

.raylib.compat._eventTable:{[]
  ev:.[value;enlist `.raylib.events.last;{.raylib.events._empty[]}];
  if[98h<>type ev; :flip `seq`time`type`a`b`c`d!(0#0j;0#0j;`symbol$();`int$();`int$();`int$();`int$())];
  :ev
 };

.raylib.compat._eventAny:{[typ;code]
  ev:.raylib.compat._eventTable[];
  if[0=count ev; :0b];
  mask:ev[`type]=typ;
  if[count code;
    mask:mask & ev[`a]=first code];
  :any mask
 };

.raylib.compat._rectIntersect:{[a;b]
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

.raylib.compat._dist2:{[a;b]
  dx:(a 0)-(b 0);
  dy:(a 1)-(b 1);
  :dx*dx+dy*dy
 };

.raylib.compat._soundId:{[snd]
  :$[99h=type snd; .raylib.compat._int[snd`id;-1i]; -1i]
 };

.raylib.compat._noop:{[name;detail;ret]
  msg:raze ("compat ",string name,": ",string detail);
  :.[.raylib._noop;(msg;ret);{ret}]
 };

/ --- Specific handlers ---
.raylib.compat._hInitWindow:{[a] :.[.raylib.open;();{0b}] };
.raylib.compat._hCloseWindow:{[a] :.[.raylib.close;();{0N}] };
.raylib.compat._hSetTargetFPS:{[a] fps:.raylib.compat._float[.raylib.compat._arg[a;0;60f];60f]; if[fps<=0f; :.raylib.compat._noop[`SetTargetFPS;"fps<=0 ignored";0N]]; :.[.raylib.frame.setDt;enlist 1f%fps;{0N}] };
.raylib.compat._hGetFrameTime:{[a] :"f"$.raylib.frame._state`dt };
.raylib.compat._hGetTime:{[a] :"f"$.raylib.frame._state`time };
.raylib.compat._hGetFPS:{[a] dt:"f"$.raylib.frame._state`dt; :$[dt>0f;"i"$1f%dt;0i] };
.raylib.compat._hWindowShouldClose:{[a] :.raylib.compat._eventAny[`window_close;()] };
.raylib.compat._hIsWindowReady:{[a] :.[{.raylib._runtimeOpen};();{0b}] };
.raylib.compat._hSetWindowSize:{[a] w:.raylib.compat._int[.raylib.compat._arg[a;0;800i];800i]; h:.raylib.compat._int[.raylib.compat._arg[a;1;450i];450i]; .raylib.compat._state[`windowW]:w; .raylib.compat._state[`windowH]:h; `windowW set w; `windowH set h; :0N };
.raylib.compat._hGetScreenWidth:{[a] :.[{"i"$value `windowW};();{.raylib.compat._state`windowW}] };
.raylib.compat._hGetScreenHeight:{[a] :.[{"i"$value `windowH};();{.raylib.compat._state`windowH}] };
.raylib.compat._hGetMousePosition:{[a] :(. [value;enlist `mx;{0f}]; . [value;enlist `my;{0f}]) };
.raylib.compat._hGetMouseDelta:{[a] :(. [value;enlist `mdx;{0f}]; . [value;enlist `mdy;{0f}]) };
.raylib.compat._hGetMouseWheelMove:{[a] :.[{"f"$value `mwheel};();{0f}] };
.raylib.compat._hGetMouseWheelMoveV:{[a] :0f,.raylib.compat._hGetMouseWheelMove[()] };
.raylib.compat._hIsMouseButtonPressed:{[a] btn:.raylib.compat._int[.raylib.compat._arg[a;0;0i];0i]; :.raylib.compat._eventAny[`mouse_down;enlist btn] };
.raylib.compat._hIsMouseButtonReleased:{[a] btn:.raylib.compat._int[.raylib.compat._arg[a;0;0i];0i]; :.raylib.compat._eventAny[`mouse_up;enlist btn] };
.raylib.compat._hIsMouseButtonDown:{[a] btn:.raylib.compat._int[.raylib.compat._arg[a;0;0i];0i]; mp:. [value;enlist `mpressed;{0b}]; mb:. [value;enlist `mbutton;{-1i}]; :("i"$mb=btn)&.raylib.compat._bool mp };
.raylib.compat._hIsMouseButtonUp:{[a] :not .raylib.compat._hIsMouseButtonDown[a] };
.raylib.compat._hIsKeyPressed:{[a] k:.raylib.compat._int[.raylib.compat._arg[a;0;0i];0i]; :.raylib.compat._eventAny[`key_down;enlist k] };
.raylib.compat._hIsKeyPressedRepeat:{[a] :.raylib.compat._hIsKeyPressed[a] };
.raylib.compat._hIsKeyDown:{[a] k:.raylib.compat._int[.raylib.compat._arg[a;0;0i];0i]; mk:. [value;enlist `mkey;{0i}]; :("i"$mk)=k };
.raylib.compat._hIsKeyReleased:{[a] k:.raylib.compat._int[.raylib.compat._arg[a;0;0i];0i]; :.raylib.compat._eventAny[`key_up;enlist k] };
.raylib.compat._hIsKeyUp:{[a] :not .raylib.compat._hIsKeyDown[a] };
.raylib.compat._hGetKeyPressed:{[a] ev:.raylib.compat._eventTable[]; idx:where ev[`type]=`key_down; :$[count idx; ev[`a] first idx; 0i] };
.raylib.compat._hGetCharPressed:{[a] ev:.raylib.compat._eventTable[]; idx:where ev[`type]=`char_input; :$[count idx; ev[`a] first idx; 0i] };

.raylib.compat._hDrawPixel:{[a]
  t0:.raylib.compat._arg[a;0;()];
  if[any 98 99h=type t0; :.[.raylib.point;enlist t0;{0N}]];
  p:.raylib.compat._vec2[t0;0 0f]; clr:.raylib.compat._rgba[.raylib.compat._arg[a;1;.raylib.Color.BLACK];.raylib.Color.BLACK];
  t:([] x:enlist p 0; y:enlist p 1; color:enlist clr);
  :.[.raylib.point;enlist t;{0N}]
 };

.raylib.compat._hDrawLine:{[a]
  t0:.raylib.compat._arg[a;0;()];
  if[any 98 99h=type t0; :.[.raylib.line;enlist t0;{0N}]];
  p1:.raylib.compat._vec2[t0;0 0f]; p2:.raylib.compat._vec2[.raylib.compat._arg[a;1;0 0f];0 0f]; clr:.raylib.compat._rgba[.raylib.compat._arg[a;2;.raylib.Color.BLACK];.raylib.Color.BLACK];
  t:([] x1:enlist p1 0; y1:enlist p1 1; x2:enlist p2 0; y2:enlist p2 1; color:enlist clr);
  :.[.raylib.line;enlist t;{0N}]
 };

.raylib.compat._hDrawLineEx:{[a]
  p1:.raylib.compat._vec2[.raylib.compat._arg[a;0;0 0f];0 0f]; p2:.raylib.compat._vec2[.raylib.compat._arg[a;1;0 0f];0 0f]; th:.raylib.compat._float[.raylib.compat._arg[a;2;1f];1f]; clr:.raylib.compat._rgba[.raylib.compat._arg[a;3;.raylib.Color.BLACK];.raylib.Color.BLACK];
  t:([] x1:enlist p1 0; y1:enlist p1 1; x2:enlist p2 0; y2:enlist p2 1; thickness:enlist th; color:enlist clr);
  :.[.raylib.line;enlist t;{0N}]
 };

.raylib.compat._hDrawCircle:{[a]
  t0:.raylib.compat._arg[a;0;()];
  if[any 98 99h=type t0; :.[.raylib.circle;enlist t0;{0N}]];
  c:.raylib.compat._vec2[t0;0 0f]; r:.raylib.compat._float[.raylib.compat._arg[a;1;1f];1f]; clr:.raylib.compat._rgba[.raylib.compat._arg[a;2;.raylib.Color.BLUE];.raylib.Color.BLUE];
  t:([] x:enlist c 0; y:enlist c 1; r:enlist r; color:enlist clr);
  :.[.raylib.circle;enlist t;{0N}]
 };

.raylib.compat._hDrawRectangle:{[a]
  t0:.raylib.compat._arg[a;0;()];
  if[any 98 99h=type t0; :.[.raylib.rect;enlist t0;{0N}]];
  p:.raylib.compat._vec2[t0;0 0f]; sz:.raylib.compat._vec2[.raylib.compat._arg[a;1;1 1f];1 1f]; clr:.raylib.compat._rgba[.raylib.compat._arg[a;2;.raylib.Color.ORANGE];.raylib.Color.ORANGE];
  t:([] x:enlist p 0; y:enlist p 1; w:enlist sz 0; h:enlist sz 1; color:enlist clr);
  :.[.raylib.rect;enlist t;{0N}]
 };

.raylib.compat._hDrawText:{[a]
  txt:string .raylib.compat._arg[a;0;""]; p:.raylib.compat._vec2[.raylib.compat._arg[a;1;0 0f];0 0f]; sz:.raylib.compat._int[.raylib.compat._arg[a;2;20i];20i]; clr:.raylib.compat._rgba[.raylib.compat._arg[a;3;.raylib.Color.BLACK];.raylib.Color.BLACK];
  t:([] x:enlist p 0; y:enlist p 1; text:enlist txt; size:enlist sz; color:enlist clr);
  :.[.raylib.text;enlist t;{0N}]
 };

.raylib.compat._hMeasureText:{[a] txt:string .raylib.compat._arg[a;0;""]; sz:.raylib.compat._int[.raylib.compat._arg[a;1;20i];20i]; :"i"$.raylib.ui._textWidth[txt;sz] };
.raylib.compat._hMeasureTextEx:{[a] txt:string .raylib.compat._arg[a;1;""]; sz:.raylib.compat._float[.raylib.compat._arg[a;2;20f];20f]; :(.raylib.ui._textWidth[txt;sz];sz) };

.raylib.compat._hCollisionRecs:{[a] r1:.raylib.compat._rect4[.raylib.compat._arg[a;0;0 0 0 0f];0 0 0 0f]; r2:.raylib.compat._rect4[.raylib.compat._arg[a;1;0 0 0 0f];0 0 0 0f]; rr:.raylib.compat._rectIntersect[r1;r2]; :(rr 2)>0f & (rr 3)>0f };
.raylib.compat._hCollisionCircles:{[a] c1:.raylib.compat._vec2[.raylib.compat._arg[a;0;0 0f];0 0f]; r1:.raylib.compat._float[.raylib.compat._arg[a;1;0f];0f]; c2:.raylib.compat._vec2[.raylib.compat._arg[a;2;0 0f];0 0f]; r2:.raylib.compat._float[.raylib.compat._arg[a;3;0f];0f]; :.raylib.compat._dist2[c1;c2] <= (r1+r2)*(r1+r2) };
.raylib.compat._hCollisionCircleRec:{[a] c:.raylib.compat._vec2[.raylib.compat._arg[a;0;0 0f];0 0f]; r:.raylib.compat._float[.raylib.compat._arg[a;1;0f];0f]; rec:.raylib.compat._rect4[.raylib.compat._arg[a;2;0 0 0 0f];0 0 0 0f]; cx:$[(c 0)<rec 0;rec 0;$[(c 0)>(rec 0+rec 2);rec 0+rec 2;c 0]]; cy:$[(c 1)<rec 1;rec 1;$[(c 1)>(rec 1+rec 3);rec 1+rec 3;c 1]]; :.raylib.compat._dist2[c;(cx;cy)]<=r*r };
.raylib.compat._hCollisionPointRec:{[a] p:.raylib.compat._vec2[.raylib.compat._arg[a;0;0 0f];0 0f]; r:.raylib.compat._rect4[.raylib.compat._arg[a;1;0 0 0 0f];0 0 0 0f]; :((p 0)>=r 0)&((p 0)<=r 0+r 2)&((p 1)>=r 1)&((p 1)<=r 1+r 3) };
.raylib.compat._hCollisionPointCircle:{[a] p:.raylib.compat._vec2[.raylib.compat._arg[a;0;0 0f];0 0f]; c:.raylib.compat._vec2[.raylib.compat._arg[a;1;0 0f];0 0f]; r:.raylib.compat._float[.raylib.compat._arg[a;2;0f];0f]; :.raylib.compat._dist2[p;c]<=r*r };
.raylib.compat._hGetCollisionRec:{[a] r1:.raylib.compat._rect4[.raylib.compat._arg[a;0;0 0 0 0f];0 0 0 0f]; r2:.raylib.compat._rect4[.raylib.compat._arg[a;1;0 0 0 0f];0 0 0 0f]; :.raylib.compat._rectIntersect[r1;r2] };

.raylib.compat._hInitAudio:{[a] .raylib.compat._audioReady:1b; :0N };
.raylib.compat._hCloseAudio:{[a] .raylib.compat._audioReady:0b; :0N };
.raylib.compat._hIsAudioReady:{[a] :.raylib.compat._audioReady };
.raylib.compat._hSetMasterVol:{[a] .raylib.compat._masterVolume:.raylib.compat._float[.raylib.compat._arg[a;0;1f];1f]; :0N };
.raylib.compat._hGetMasterVol:{[a] :.raylib.compat._masterVolume };
.raylib.compat._hLoadSound:{[a] h:.raylib.compat._handle[`sound;a]; .raylib.compat._sounds,: ([] id:enlist h`id; playing:enlist 0b; volume:enlist 1f); :h };
.raylib.compat._hIsSoundValid:{[a] :99h=type .raylib.compat._arg[a;0;()] };
.raylib.compat._hPlaySound:{[a] id:.raylib.compat._soundId .raylib.compat._arg[a;0;()]; idx:where .raylib.compat._sounds[`id]=id; if[count idx; .raylib.compat._sounds[`playing]:@[.raylib.compat._sounds[`playing];idx;:;(count idx)#enlist 1b]]; if[0=count idx; :.raylib.compat._noop[`PlaySound;"unknown sound handle";0N]]; :0N };
.raylib.compat._hStopSound:{[a] id:.raylib.compat._soundId .raylib.compat._arg[a;0;()]; idx:where .raylib.compat._sounds[`id]=id; if[count idx; .raylib.compat._sounds[`playing]:@[.raylib.compat._sounds[`playing];idx;:;(count idx)#enlist 0b]]; if[0=count idx; :.raylib.compat._noop[`StopSound;"unknown sound handle";0N]]; :0N };
.raylib.compat._hIsSoundPlaying:{[a] id:.raylib.compat._soundId .raylib.compat._arg[a;0;()]; idx:where .raylib.compat._sounds[`id]=id; :$[count idx; .raylib.compat._sounds[`playing] first idx; 0b] };
.raylib.compat._hSetSoundVolume:{[a] id:.raylib.compat._soundId .raylib.compat._arg[a;0;()]; vol:.raylib.compat._float[.raylib.compat._arg[a;1;1f];1f]; idx:where .raylib.compat._sounds[`id]=id; if[count idx; .raylib.compat._sounds[`volume]:@[.raylib.compat._sounds[`volume];idx;:;(count idx)#enlist vol]]; if[0=count idx; :.raylib.compat._noop[`SetSoundVolume;"unknown sound handle";0N]]; :0N };

.raylib.compat._handlers:`InitWindow`CloseWindow`SetTargetFPS`GetFrameTime`GetTime`GetFPS`WindowShouldClose`IsWindowReady`SetWindowSize`GetScreenWidth`GetScreenHeight`GetRenderWidth`GetRenderHeight`GetMousePosition`GetMouseDelta`GetMouseWheelMove`GetMouseWheelMoveV`IsMouseButtonPressed`IsMouseButtonDown`IsMouseButtonReleased`IsMouseButtonUp`IsKeyPressed`IsKeyPressedRepeat`IsKeyDown`IsKeyReleased`IsKeyUp`GetKeyPressed`GetCharPressed`DrawPixel`DrawLine`DrawLineEx`DrawCircle`DrawRectangle`DrawText`MeasureText`MeasureTextEx`CheckCollisionRecs`CheckCollisionCircles`CheckCollisionCircleRec`CheckCollisionPointRec`CheckCollisionPointCircle`GetCollisionRec`InitAudioDevice`CloseAudioDevice`IsAudioDeviceReady`SetMasterVolume`GetMasterVolume`LoadSound`LoadSoundFromWave`LoadSoundAlias`IsSoundValid`PlaySound`StopSound`PauseSound`ResumeSound`IsSoundPlaying`SetSoundVolume!(
  .raylib.compat._hInitWindow;
  .raylib.compat._hCloseWindow;
  .raylib.compat._hSetTargetFPS;
  .raylib.compat._hGetFrameTime;
  .raylib.compat._hGetTime;
  .raylib.compat._hGetFPS;
  .raylib.compat._hWindowShouldClose;
  .raylib.compat._hIsWindowReady;
  .raylib.compat._hSetWindowSize;
  .raylib.compat._hGetScreenWidth;
  .raylib.compat._hGetScreenHeight;
  .raylib.compat._hGetScreenWidth;
  .raylib.compat._hGetScreenHeight;
  .raylib.compat._hGetMousePosition;
  .raylib.compat._hGetMouseDelta;
  .raylib.compat._hGetMouseWheelMove;
  .raylib.compat._hGetMouseWheelMoveV;
  .raylib.compat._hIsMouseButtonPressed;
  .raylib.compat._hIsMouseButtonDown;
  .raylib.compat._hIsMouseButtonReleased;
  .raylib.compat._hIsMouseButtonUp;
  .raylib.compat._hIsKeyPressed;
  .raylib.compat._hIsKeyPressedRepeat;
  .raylib.compat._hIsKeyDown;
  .raylib.compat._hIsKeyReleased;
  .raylib.compat._hIsKeyUp;
  .raylib.compat._hGetKeyPressed;
  .raylib.compat._hGetCharPressed;
  .raylib.compat._hDrawPixel;
  .raylib.compat._hDrawLine;
  .raylib.compat._hDrawLineEx;
  .raylib.compat._hDrawCircle;
  .raylib.compat._hDrawRectangle;
  .raylib.compat._hDrawText;
  .raylib.compat._hMeasureText;
  .raylib.compat._hMeasureTextEx;
  .raylib.compat._hCollisionRecs;
  .raylib.compat._hCollisionCircles;
  .raylib.compat._hCollisionCircleRec;
  .raylib.compat._hCollisionPointRec;
  .raylib.compat._hCollisionPointCircle;
  .raylib.compat._hGetCollisionRec;
  .raylib.compat._hInitAudio;
  .raylib.compat._hCloseAudio;
  .raylib.compat._hIsAudioReady;
  .raylib.compat._hSetMasterVol;
  .raylib.compat._hGetMasterVol;
  .raylib.compat._hLoadSound;
  .raylib.compat._hLoadSound;
  .raylib.compat._hLoadSound;
  .raylib.compat._hIsSoundValid;
  .raylib.compat._hPlaySound;
  .raylib.compat._hStopSound;
  .raylib.compat._hStopSound;
  .raylib.compat._hPlaySound;
  .raylib.compat._hIsSoundPlaying;
  .raylib.compat._hSetSoundVolume
 );

.raylib.compat.call:{[name;args]
  a:.raylib.compat._args args;
  chk:.raylib.compat._ensureUsage[name;a];
  if[-11h<>type chk; :chk];
  if[name in key .raylib.compat._handlers;
    :.[.raylib.compat._handlers name;enlist a;{0N}]];

  / window state family
  if[name=`IsWindowFullscreen; :.raylib.compat._state`fullscreen];
  if[name=`IsWindowHidden; :.raylib.compat._state`hidden];
  if[name=`IsWindowMinimized; :.raylib.compat._state`minimized];
  if[name=`IsWindowMaximized; :.raylib.compat._state`maximized];
  if[name=`IsWindowFocused; :.raylib.compat._state`focused];
  if[name=`IsWindowResized; :.raylib.compat._eventAny[`window_resize;()]];
  if[name=`IsWindowState; f:.raylib.compat._int[.raylib.compat._arg[a;0;0i];0i]; :0i<>(.raylib.compat._state`windowFlags) band f];
  if[name=`SetWindowState; f:.raylib.compat._int[.raylib.compat._arg[a;0;0i];0i]; .raylib.compat._state[`windowFlags]:.raylib.compat._state`windowFlags bor f; :0N];
  if[name=`ClearWindowState; f:.raylib.compat._int[.raylib.compat._arg[a;0;0i];0i]; .raylib.compat._state[`windowFlags]:.raylib.compat._state`windowFlags band not f; :0N];
  if[name=`SetConfigFlags; .raylib.compat._state[`configFlags]:.raylib.compat._int[.raylib.compat._arg[a;0;0i];0i]; :0N];
  if[name=`ToggleFullscreen; .raylib.compat._state[`fullscreen]:not .raylib.compat._state`fullscreen; :0N];
  if[name=`GetWindowScaleDPI; :1 1f];
  if[name=`GetCurrentMonitor; :0i];
  if[name=`GetMonitorWidth; :1920i];
  if[name=`GetMonitorHeight; :1080i];
  if[name=`ClearBackground; .raylib.compat._state[`clearColor]:.raylib.compat._rgba[.raylib.compat._arg[a;0;.raylib.Color.WHITE];.raylib.Color.WHITE]; :0N];
  if[name in `BeginDrawing`EndDrawing`BeginModeThreeD`EndModeThreeD`UpdateCamera`UpdateCameraPro`SetMousePosition; :.raylib.compat._noop[name;"stubbed compatibility call";0N]];
  if[name in `ShowCursor`EnableCursor;
    .raylib.compat._state[`cursorHidden]:0b;
    :0N];
  if[name in `HideCursor`DisableCursor;
    .raylib.compat._state[`cursorHidden]:1b;
    :0N];
  if[name=`SetTraceLogLevel;
    lvl:.raylib.compat._int[.raylib.compat._arg[a;0;.raylib.compat._state`traceLog];.raylib.compat._state`traceLog];
    .raylib.compat._state[`traceLog]:lvl;
    :0N];
  if[name=`SetExitKey;
    exitKeyVal:.raylib.compat._int[.raylib.compat._arg[a;0;.raylib.compat._state`exitKey];.raylib.compat._state`exitKey];
    .raylib.compat._state[`exitKey]:exitKeyVal;
    .raylib.interactive._escKey:exitKeyVal;
    :0N];
  if[name=`IsCursorHidden; :.raylib.compat._state`cursorHidden];
  if[name=`IsCursorOnScreen; :1b];

  / drawing extensions not directly mapped yet
  if[name in `DrawLineStrip`DrawLineBezier`DrawCircleLines`DrawCircleSector`DrawCircleSectorLines`DrawEllipse`DrawEllipseLines`DrawRing`DrawRingLines`DrawRectangleLines`DrawTriangle`DrawTriangleLines`DrawPoly`DrawPolyLines`DrawTextEx; :.raylib.compat._noop[name;"stubbed draw call";0N]];

  / 3D/model/font/image/texture are emulated handles
  s:string name;
  if[s like "Load*"; : .raylib.compat._handle[name;a]];
  if[s like "Gen*"; : .raylib.compat._handle[name;a]];
  if[s like "Unload*"; :.raylib.compat._noop[name;"stubbed compatibility call";0N]];
  if[s like "Update*"; :.raylib.compat._noop[name;"stubbed compatibility call";0N]];
  if[s like "Draw*"; :.raylib.compat._noop[name;"stubbed compatibility call";0N]];
  if[s like "CheckCollision*"; :0b];

  / gamepad defaults
  if[s like "IsGamepad*"; :0b];
  if[s like "GetGamepad*"; :0i];
  if[s like "SetGamepad*"; :.raylib.compat._noop[name;"stubbed gamepad call";0N]];

  / wave/sound fallbacks
  if[s like "IsWave*"; :99h=type .raylib.compat._arg[a;0;()]];
  if[s like "IsSound*"; :99h=type .raylib.compat._arg[a;0;()]];

  if["Is"~2#s; :0b];
  if[s like "Get*"; :.raylib.compat._noop[name;"default return from unimplemented get";0N]];
  :.raylib.compat._noop[name;"unimplemented compatibility call";0N]
 };

.raylib.compat.help:{[]
  :([] name:.raylib.compat._bindings; argc:.raylib.compat._argCount .raylib.compat._bindings)
 };
