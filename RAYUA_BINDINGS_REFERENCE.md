# Rayua -> raylib-q Sympathetic Bindings Reference

This reference now tracks a complete compatibility layer in this project.

- Source inventory: external binding reference (`lib.ua`)
- Exposed compatibility namespace: `.raylib.*`
- Binding count: **159 / 159 exposed**

## Status Model

- `Implemented (native)`: mapped directly to existing raylib-q behavior.
- `Implemented (emulated)`: behavior provided via safe compatibility logic where low-level raylib parity is not fully available in the current renderer core.

## Table-First Design Note

The compatibility layer coexists with the table-first API. For new code, prefer `.raylib.*` table APIs. Use `.raylib.*` when porting Rayua-style callsites.

<!-- BEGIN_RAYUA_CROSSWALK -->
## Full Crosswalk (All Rayua Bindings)

| # | Rayua Binding | raylib-q Compatibility Entry | Status | Notes |
|---:|---|---|---|---|
| 1 | `InitWindow` | `.raylib.InitWindow[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 2 | `SetTraceLogLevel` | `.raylib.SetTraceLogLevel[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 3 | `SetTargetFPS` | `.raylib.SetTargetFPS[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 4 | `GetFrameTime` | `.raylib.GetFrameTime[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 5 | `GetTime` | `.raylib.GetTime[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 6 | `GetFPS` | `.raylib.GetFPS[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 7 | `WindowShouldClose` | `.raylib.WindowShouldClose[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 8 | `IsWindowReady` | `.raylib.IsWindowReady[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 9 | `IsWindowFullscreen` | `.raylib.IsWindowFullscreen[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 10 | `IsWindowHidden` | `.raylib.IsWindowHidden[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 11 | `IsWindowMinimized` | `.raylib.IsWindowMinimized[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 12 | `IsWindowMaximized` | `.raylib.IsWindowMaximized[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 13 | `IsWindowFocused` | `.raylib.IsWindowFocused[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 14 | `IsWindowResized` | `.raylib.IsWindowResized[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 15 | `IsWindowState` | `.raylib.IsWindowState[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 16 | `SetWindowState` | `.raylib.SetWindowState[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 17 | `ClearWindowState` | `.raylib.ClearWindowState[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 18 | `SetConfigFlags` | `.raylib.SetConfigFlags[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 19 | `ToggleFullscreen` | `.raylib.ToggleFullscreen[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 20 | `CloseWindow` | `.raylib.CloseWindow[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 21 | `GetScreenWidth` | `.raylib.GetScreenWidth[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 22 | `GetScreenHeight` | `.raylib.GetScreenHeight[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 23 | `GetRenderWidth` | `.raylib.GetRenderWidth[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 24 | `GetRenderHeight` | `.raylib.GetRenderHeight[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 25 | `GetWindowScaleDPI` | `.raylib.GetWindowScaleDPI[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 26 | `GetCurrentMonitor` | `.raylib.GetCurrentMonitor[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 27 | `GetMonitorWidth` | `.raylib.GetMonitorWidth[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 28 | `GetMonitorHeight` | `.raylib.GetMonitorHeight[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 29 | `SetWindowSize` | `.raylib.SetWindowSize[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 30 | `ClearBackground` | `.raylib.ClearBackground[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 31 | `BeginDrawing` | `.raylib.BeginDrawing[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 32 | `EndDrawing` | `.raylib.EndDrawing[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 33 | `BeginModeThreeD` | `.raylib.BeginModeThreeD[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 34 | `EndModeThreeD` | `.raylib.EndModeThreeD[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 35 | `UpdateCamera` | `.raylib.UpdateCamera[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 36 | `UpdateCameraPro` | `.raylib.UpdateCameraPro[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 37 | `IsMouseButtonPressed` | `.raylib.IsMouseButtonPressed[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 38 | `IsMouseButtonDown` | `.raylib.IsMouseButtonDown[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 39 | `IsMouseButtonReleased` | `.raylib.IsMouseButtonReleased[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 40 | `IsMouseButtonUp` | `.raylib.IsMouseButtonUp[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 41 | `GetMousePosition` | `.raylib.GetMousePosition[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 42 | `GetMouseDelta` | `.raylib.GetMouseDelta[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 43 | `SetMousePosition` | `.raylib.SetMousePosition[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 44 | `GetMouseWheelMove` | `.raylib.GetMouseWheelMove[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 45 | `GetMouseWheelMoveV` | `.raylib.GetMouseWheelMoveV[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 46 | `ShowCursor` | `.raylib.ShowCursor[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 47 | `HideCursor` | `.raylib.HideCursor[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 48 | `IsCursorHidden` | `.raylib.IsCursorHidden[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 49 | `IsCursorOnScreen` | `.raylib.IsCursorOnScreen[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 50 | `EnableCursor` | `.raylib.EnableCursor[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 51 | `DisableCursor` | `.raylib.DisableCursor[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 52 | `IsKeyPressed` | `.raylib.IsKeyPressed[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 53 | `IsKeyPressedRepeat` | `.raylib.IsKeyPressedRepeat[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 54 | `IsKeyDown` | `.raylib.IsKeyDown[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 55 | `IsKeyReleased` | `.raylib.IsKeyReleased[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 56 | `IsKeyUp` | `.raylib.IsKeyUp[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 57 | `GetKeyPressed` | `.raylib.GetKeyPressed[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 58 | `GetCharPressed` | `.raylib.GetCharPressed[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 59 | `SetExitKey` | `.raylib.SetExitKey[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 60 | `IsGamepadAvailable` | `.raylib.IsGamepadAvailable[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 61 | `GetGamepadName` | `.raylib.GetGamepadName[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 62 | `IsGamepadButtonPressed` | `.raylib.IsGamepadButtonPressed[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 63 | `IsGamepadButtonDown` | `.raylib.IsGamepadButtonDown[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 64 | `IsGamepadButtonReleased` | `.raylib.IsGamepadButtonReleased[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 65 | `IsGamepadButtonUp` | `.raylib.IsGamepadButtonUp[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 66 | `GetGamepadButtonPressed` | `.raylib.GetGamepadButtonPressed[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 67 | `GetGamepadAxisCount` | `.raylib.GetGamepadAxisCount[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 68 | `GetGamepadAxisMovement` | `.raylib.GetGamepadAxisMovement[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 69 | `SetGamepadMappings` | `.raylib.SetGamepadMappings[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 70 | `SetGamepadVibration` | `.raylib.SetGamepadVibration[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 71 | `DrawPixel` | `.raylib.DrawPixel[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 72 | `DrawLine` | `.raylib.DrawLine[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 73 | `DrawLineEx` | `.raylib.DrawLineEx[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 74 | `DrawLineStrip` | `.raylib.DrawLineStrip[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 75 | `DrawLineBezier` | `.raylib.DrawLineBezier[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 76 | `DrawCircle` | `.raylib.DrawCircle[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 77 | `DrawCircleLines` | `.raylib.DrawCircleLines[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 78 | `DrawCircleSector` | `.raylib.DrawCircleSector[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 79 | `DrawCircleSectorLines` | `.raylib.DrawCircleSectorLines[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 80 | `DrawEllipse` | `.raylib.DrawEllipse[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 81 | `DrawEllipseLines` | `.raylib.DrawEllipseLines[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 82 | `DrawRing` | `.raylib.DrawRing[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 83 | `DrawRingLines` | `.raylib.DrawRingLines[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 84 | `DrawRectangle` | `.raylib.DrawRectangle[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 85 | `DrawRectangleLines` | `.raylib.DrawRectangleLines[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 86 | `DrawTriangle` | `.raylib.DrawTriangle[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 87 | `DrawTriangleLines` | `.raylib.DrawTriangleLines[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 88 | `DrawPoly` | `.raylib.DrawPoly[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 89 | `DrawPolyLines` | `.raylib.DrawPolyLines[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 90 | `GetFontDefault` | `.raylib.GetFontDefault[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 91 | `LoadFont` | `.raylib.LoadFont[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 92 | `LoadFontEx` | `.raylib.LoadFontEx[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 93 | `IsFontValid` | `.raylib.IsFontValid[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 94 | `UnloadFont` | `.raylib.UnloadFont[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 95 | `DrawText` | `.raylib.DrawText[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 96 | `DrawTextEx` | `.raylib.DrawTextEx[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 97 | `MeasureText` | `.raylib.MeasureText[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 98 | `MeasureTextEx` | `.raylib.MeasureTextEx[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 99 | `DrawCube` | `.raylib.DrawCube[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 100 | `DrawCubeWires` | `.raylib.DrawCubeWires[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 101 | `UploadMesh` | `.raylib.UploadMesh[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 102 | `GenMeshPoly` | `.raylib.GenMeshPoly[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 103 | `GenMeshPlane` | `.raylib.GenMeshPlane[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 104 | `GenMeshCube` | `.raylib.GenMeshCube[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 105 | `GenMeshSphere` | `.raylib.GenMeshSphere[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 106 | `LoadModel` | `.raylib.LoadModel[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 107 | `LoadModelFromMesh` | `.raylib.LoadModelFromMesh[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 108 | `DrawModel` | `.raylib.DrawModel[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 109 | `DrawModelEx` | `.raylib.DrawModelEx[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 110 | `GenImageColor` | `.raylib.GenImageColor[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 111 | `UnloadImage` | `.raylib.UnloadImage[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 112 | `LoadImageFromScreen` | `.raylib.LoadImageFromScreen[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 113 | `LoadImageFromTexture` | `.raylib.LoadImageFromTexture[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 114 | `LoadTextureFromImage` | `.raylib.LoadTextureFromImage[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 115 | `LoadTexture` | `.raylib.LoadTexture[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 116 | `UpdateTexture` | `.raylib.UpdateTexture[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 117 | `UpdateTextureRec` | `.raylib.UpdateTextureRec[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 118 | `UnloadTexture` | `.raylib.UnloadTexture[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 119 | `DrawTexture` | `.raylib.DrawTexture[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 120 | `DrawTextureEx` | `.raylib.DrawTextureEx[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 121 | `DrawTextureRec` | `.raylib.DrawTextureRec[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 122 | `DrawTexturePro` | `.raylib.DrawTexturePro[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 123 | `LoadRenderTexture` | `.raylib.LoadRenderTexture[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 124 | `UnloadRenderTexture` | `.raylib.UnloadRenderTexture[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 125 | `BeginTextureMode` | `.raylib.BeginTextureMode[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 126 | `EndTextureMode` | `.raylib.EndTextureMode[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 127 | `CheckCollisionRecs` | `.raylib.CheckCollisionRecs[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 128 | `CheckCollisionCircles` | `.raylib.CheckCollisionCircles[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 129 | `CheckCollisionCircleRec` | `.raylib.CheckCollisionCircleRec[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 130 | `CheckCollisionCircleLine` | `.raylib.CheckCollisionCircleLine[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 131 | `CheckCollisionPointRec` | `.raylib.CheckCollisionPointRec[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 132 | `CheckCollisionPointCircle` | `.raylib.CheckCollisionPointCircle[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 133 | `CheckCollisionPointTriangle` | `.raylib.CheckCollisionPointTriangle[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 134 | `CheckCollisionPointLine` | `.raylib.CheckCollisionPointLine[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 135 | `CheckCollisionPointPoly` | `.raylib.CheckCollisionPointPoly[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 136 | `CheckCollisionLines` | `.raylib.CheckCollisionLines[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 137 | `GetCollisionRec` | `.raylib.GetCollisionRec[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 138 | `InitAudioDevice` | `.raylib.InitAudioDevice[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 139 | `CloseAudioDevice` | `.raylib.CloseAudioDevice[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 140 | `IsAudioDeviceReady` | `.raylib.IsAudioDeviceReady[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 141 | `SetMasterVolume` | `.raylib.SetMasterVolume[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 142 | `GetMasterVolume` | `.raylib.GetMasterVolume[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 143 | `LoadWave` | `.raylib.LoadWave[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 144 | `LoadWaveFromMemory` | `.raylib.LoadWaveFromMemory[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 145 | `IsWaveValid` | `.raylib.IsWaveValid[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 146 | `LoadSound` | `.raylib.LoadSound[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 147 | `LoadSoundFromWave` | `.raylib.LoadSoundFromWave[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 148 | `LoadSoundAlias` | `.raylib.LoadSoundAlias[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 149 | `IsSoundValid` | `.raylib.IsSoundValid[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 150 | `UpdateSound` | `.raylib.UpdateSound[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 151 | `UnloadWave` | `.raylib.UnloadWave[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 152 | `UnloadSound` | `.raylib.UnloadSound[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 153 | `UnloadSoundAlias` | `.raylib.UnloadSoundAlias[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 154 | `PlaySound` | `.raylib.PlaySound[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 155 | `StopSound` | `.raylib.StopSound[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 156 | `PauseSound` | `.raylib.PauseSound[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 157 | `ResumeSound` | `.raylib.ResumeSound[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 158 | `IsSoundPlaying` | `.raylib.IsSoundPlaying[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
| 159 | `SetSoundVolume` | `.raylib.SetSoundVolume[...]` | Implemented (native/emulated) | Portability facade present in q surface. |
<!-- END_RAYUA_CROSSWALK -->

## Validation

- Coverage is validated in tests by checking marker block presence and exactly 159 rows.
- Runtime validation checks all `.raylib.*` bindings are callable and invocable with declared arity.
