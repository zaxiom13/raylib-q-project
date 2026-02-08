#include "raylib.h"

int main(void) {
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib hello window");
    SetTargetFPS(60);

    while (!WindowShouldClose()) {
        BeginDrawing();
            ClearBackground(RAYWHITE);
            DrawText("Hello from raylib", 260, 200, 30, DARKGRAY);
        EndDrawing();
    }

    CloseWindow();
    return 0;
}
