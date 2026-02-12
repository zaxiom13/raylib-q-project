.raylib.InitWindow:{[a;b;c]
  :.raylib.api.call[`InitWindow;(a;b;c)]
 };

.raylib.SetTraceLogLevel:{[a]
  :.raylib.api.call[`SetTraceLogLevel;(a)]
 };

.raylib.SetTargetFPS:{[a]
  :.raylib.api.call[`SetTargetFPS;(a)]
 };

.raylib.GetFrameTime:{[]
  :.raylib.api.call[`GetFrameTime;()]
 };

.raylib.GetTime:{[]
  :.raylib.api.call[`GetTime;()]
 };

.raylib.GetFPS:{[]
  :.raylib.api.call[`GetFPS;()]
 };

.raylib.WindowShouldClose:{[]
  :.raylib.api.call[`WindowShouldClose;()]
 };

.raylib.IsWindowReady:{[]
  :.raylib.api.call[`IsWindowReady;()]
 };

.raylib.IsWindowFullscreen:{[]
  :.raylib.api.call[`IsWindowFullscreen;()]
 };

.raylib.IsWindowHidden:{[]
  :.raylib.api.call[`IsWindowHidden;()]
 };

.raylib.IsWindowMinimized:{[]
  :.raylib.api.call[`IsWindowMinimized;()]
 };

.raylib.IsWindowMaximized:{[]
  :.raylib.api.call[`IsWindowMaximized;()]
 };

.raylib.IsWindowFocused:{[]
  :.raylib.api.call[`IsWindowFocused;()]
 };

.raylib.IsWindowResized:{[]
  :.raylib.api.call[`IsWindowResized;()]
 };

.raylib.IsWindowState:{[a]
  :.raylib.api.call[`IsWindowState;(a)]
 };

.raylib.SetWindowState:{[a]
  :.raylib.api.call[`SetWindowState;(a)]
 };

.raylib.ClearWindowState:{[a]
  :.raylib.api.call[`ClearWindowState;(a)]
 };

.raylib.SetConfigFlags:{[a]
  :.raylib.api.call[`SetConfigFlags;(a)]
 };

.raylib.ToggleFullscreen:{[]
  :.raylib.api.call[`ToggleFullscreen;()]
 };

.raylib.CloseWindow:{[]
  :.raylib.api.call[`CloseWindow;()]
 };

.raylib.GetScreenWidth:{[]
  :.raylib.api.call[`GetScreenWidth;()]
 };

.raylib.GetScreenHeight:{[]
  :.raylib.api.call[`GetScreenHeight;()]
 };

.raylib.GetRenderWidth:{[]
  :.raylib.api.call[`GetRenderWidth;()]
 };

.raylib.GetRenderHeight:{[]
  :.raylib.api.call[`GetRenderHeight;()]
 };

.raylib.GetWindowScaleDPI:{[]
  :.raylib.api.call[`GetWindowScaleDPI;()]
 };

.raylib.GetCurrentMonitor:{[]
  :.raylib.api.call[`GetCurrentMonitor;()]
 };

.raylib.GetMonitorWidth:{[a]
  :.raylib.api.call[`GetMonitorWidth;(a)]
 };

.raylib.GetMonitorHeight:{[a]
  :.raylib.api.call[`GetMonitorHeight;(a)]
 };

.raylib.SetWindowSize:{[a;b]
  :.raylib.api.call[`SetWindowSize;(a;b)]
 };

.raylib.ClearBackground:{[a]
  :.raylib.api.call[`ClearBackground;(a)]
 };

.raylib.BeginDrawing:{[]
  :.raylib.api.call[`BeginDrawing;()]
 };

.raylib.EndDrawing:{[]
  :.raylib.api.call[`EndDrawing;()]
 };

.raylib.BeginModeThreeD:{[a]
  :.raylib.api.call[`BeginModeThreeD;(a)]
 };

.raylib.EndModeThreeD:{[]
  :.raylib.api.call[`EndModeThreeD;()]
 };

.raylib.UpdateCamera:{[a;b;c]
  :.raylib.api.call[`UpdateCamera;(a;b;c)]
 };

.raylib.UpdateCameraPro:{[a;b;c;d;e]
  :.raylib.api.call[`UpdateCameraPro;(a;b;c;d;e)]
 };

.raylib.IsMouseButtonPressed:{[a]
  :.raylib.api.call[`IsMouseButtonPressed;(a)]
 };

.raylib.IsMouseButtonDown:{[a]
  :.raylib.api.call[`IsMouseButtonDown;(a)]
 };

.raylib.IsMouseButtonReleased:{[a]
  :.raylib.api.call[`IsMouseButtonReleased;(a)]
 };

.raylib.IsMouseButtonUp:{[a]
  :.raylib.api.call[`IsMouseButtonUp;(a)]
 };

.raylib.GetMousePosition:{[]
  :.raylib.api.call[`GetMousePosition;()]
 };

.raylib.GetMouseDelta:{[]
  :.raylib.api.call[`GetMouseDelta;()]
 };

.raylib.SetMousePosition:{[a;b]
  :.raylib.api.call[`SetMousePosition;(a;b)]
 };

.raylib.GetMouseWheelMove:{[]
  :.raylib.api.call[`GetMouseWheelMove;()]
 };

.raylib.GetMouseWheelMoveV:{[]
  :.raylib.api.call[`GetMouseWheelMoveV;()]
 };

.raylib.ShowCursor:{[]
  :.raylib.api.call[`ShowCursor;()]
 };

.raylib.HideCursor:{[]
  :.raylib.api.call[`HideCursor;()]
 };

.raylib.IsCursorHidden:{[]
  :.raylib.api.call[`IsCursorHidden;()]
 };

.raylib.IsCursorOnScreen:{[]
  :.raylib.api.call[`IsCursorOnScreen;()]
 };

.raylib.EnableCursor:{[]
  :.raylib.api.call[`EnableCursor;()]
 };

.raylib.DisableCursor:{[]
  :.raylib.api.call[`DisableCursor;()]
 };

.raylib.IsKeyPressed:{[a]
  :.raylib.api.call[`IsKeyPressed;(a)]
 };

.raylib.IsKeyPressedRepeat:{[a]
  :.raylib.api.call[`IsKeyPressedRepeat;(a)]
 };

.raylib.IsKeyDown:{[a]
  :.raylib.api.call[`IsKeyDown;(a)]
 };

.raylib.IsKeyReleased:{[a]
  :.raylib.api.call[`IsKeyReleased;(a)]
 };

.raylib.IsKeyUp:{[a]
  :.raylib.api.call[`IsKeyUp;(a)]
 };

.raylib.GetKeyPressed:{[]
  :.raylib.api.call[`GetKeyPressed;()]
 };

.raylib.GetCharPressed:{[]
  :.raylib.api.call[`GetCharPressed;()]
 };

.raylib.SetExitKey:{[a]
  :.raylib.api.call[`SetExitKey;(a)]
 };

.raylib.IsGamepadAvailable:{[a]
  :.raylib.api.call[`IsGamepadAvailable;(a)]
 };

.raylib.GetGamepadName:{[a]
  :.raylib.api.call[`GetGamepadName;(a)]
 };

.raylib.IsGamepadButtonPressed:{[a;b]
  :.raylib.api.call[`IsGamepadButtonPressed;(a;b)]
 };

.raylib.IsGamepadButtonDown:{[a;b]
  :.raylib.api.call[`IsGamepadButtonDown;(a;b)]
 };

.raylib.IsGamepadButtonReleased:{[a;b]
  :.raylib.api.call[`IsGamepadButtonReleased;(a;b)]
 };

.raylib.IsGamepadButtonUp:{[a;b]
  :.raylib.api.call[`IsGamepadButtonUp;(a;b)]
 };

.raylib.GetGamepadButtonPressed:{[]
  :.raylib.api.call[`GetGamepadButtonPressed;()]
 };

.raylib.GetGamepadAxisCount:{[a]
  :.raylib.api.call[`GetGamepadAxisCount;(a)]
 };

.raylib.GetGamepadAxisMovement:{[a;b]
  :.raylib.api.call[`GetGamepadAxisMovement;(a;b)]
 };

.raylib.SetGamepadMappings:{[a]
  :.raylib.api.call[`SetGamepadMappings;(a)]
 };

.raylib.SetGamepadVibration:{[a;b;c;d]
  :.raylib.api.call[`SetGamepadVibration;(a;b;c;d)]
 };

