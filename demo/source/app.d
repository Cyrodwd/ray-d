import raylib;
import raymath;

void main()
{
	// Creating Window
	immutable int windowWidth = 800;
	immutable int windowHeight = 600;
	InitWindow(windowWidth, windowHeight, "Moving Circle with ray-d");
	scope (exit) { CloseWindow(); }

	// Setting variables
	float circleRadius = 30.0f;
	Vector2 circlePosition = Vector2(0, 0);
	float circleSpeed = 300.0f;

	SetTargetFPS(60);

	// Main Loop
	while (!WindowShouldClose())
	{
		// Update Input
		if (IsKeyDown(KeyboardKey.KEY_A)) circlePosition.x -= circleSpeed * GetFrameTime();
		if (IsKeyDown(KeyboardKey.KEY_D)) circlePosition.x += circleSpeed * GetFrameTime();
		if (IsKeyDown(KeyboardKey.KEY_W)) circlePosition.y -= circleSpeed * GetFrameTime();
		if (IsKeyDown(KeyboardKey.KEY_S)) circlePosition.y += circleSpeed * GetFrameTime();

		// Keep the circle inside the screen
		circlePosition.x = Clamp(circlePosition.x, circleRadius, GetScreenWidth() - circleRadius);
		circlePosition.y = Clamp(circlePosition.y, circleRadius, GetScreenHeight() - circleRadius);

		// Draw
		BeginDrawing();
		ClearBackground(Colors.BEIGE);
		DrawCircleV(circlePosition, circleRadius, Colors.WHITE);
		DrawText(TextFormat("Position X: %.2f\nPosition Y: %.2f", circlePosition.x, circlePosition.y), 0, 0, 20, Colors.WHITE);
		EndDrawing();
	}
}
