package game

import rl "vendor:raylib"
import "core:fmt"
import "core:math"

// CONSTANTS
WINDOW_WIDTH   :: 640 * 2
WINDOW_HEIGHT  :: 480 * 2
MAP_SIZE       :: 24
GRID_CELL_SIZE :: 32

// Type Alias
Vec2 :: rl.Vector2

Game_State :: struct {
    game_over: bool,
    editor_mode: bool, // Togggle the level editor
    world_map: [MAP_SIZE][MAP_SIZE]int,
}

Editor_State :: struct {
    brush_value: int, // Wall types 
    e_map: [MAP_SIZE][MAP_SIZE]int // Editable copy of our map
}

Player :: struct {
    pos: Vec2,
    dir: Vec2,
}

world_map := [MAP_SIZE][MAP_SIZE]int{
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,2,2,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,3,0,0,0,3,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,2,0,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,0,0,0,5,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
};

gs := Game_State{ game_over = false, editor_mode = false, world_map = world_map }
es := Editor_State{ brush_value = 0, e_map = gs.world_map }
player := Player { pos = {22, 12}, dir = {-1, 0} }

main :: proc() {
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Forerunner Prototype")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    

    // Camera Plane
    px: f32 = 0
    py: f32 = 0.66

      for !rl.WindowShouldClose() {
	frame_time := rl.GetFrameTime() 

	if rl.IsKeyPressed(.SPACE) {
	    gs.editor_mode = !gs.editor_mode
	}
	if gs.editor_mode {
	    update_editor(&es)
	} else {
	    // Input
	    move_speed := frame_time * 5.0 // constant value in squares/second
	    rot_speed := frame_time * 3.0 // constant value in radians/second

	    if rl.IsKeyDown(.W) {
		if gs.world_map[int(player.pos.x + player.dir.x * move_speed)][int(player.pos.y)] == 0 {
		    player.pos.x += player.dir.x * move_speed
		}
		
		if gs.world_map[int(player.pos.x)][int(player.pos.y + player.dir.y * move_speed)] == 0 {
		    player.pos.y += player.dir.y * move_speed
		}

	    }

	    if rl.IsKeyDown(.S) {
		if gs.world_map[int(player.pos.x - player.dir.x * move_speed)][int(player.pos.y)] == 0 {
		    player.pos.x -= player.dir.x * move_speed
		}
		
		if gs.world_map[int(player.pos.x)][int(player.pos.y - player.dir.y * move_speed)] == 0 {
		    player.pos.y -= player.dir.y * move_speed
		}
	    }

	    if rl.IsKeyDown(.D) {
		// Both camera direciotn and camera plane must be rotated
		old_dir_x := player.dir.x 
		player.dir.x = player.dir.x * math.cos(-rot_speed) - player.dir.y * math.sin(-rot_speed)
		player.dir.y = old_dir_x * math.sin(-rot_speed) + player.dir.y * math.cos(-rot_speed)

		old_plane_x := px
		px = px * math.cos(-rot_speed) - py * math.sin(-rot_speed)
		py = old_plane_x * math.sin(-rot_speed) + py * math.cos(-rot_speed)

	    }

	    if rl.IsKeyDown(.A) {
		// Both camera direciotn and camera plane must be rotated
		old_dir_x := player.dir.x 
		player.dir.x = player.dir.x * math.cos(rot_speed) - player.dir.y * math.sin(rot_speed)
		player.dir.y = old_dir_x * math.sin(rot_speed) + player.dir.y * math.cos(rot_speed)

		old_plane_x := px
		px = px * math.cos(rot_speed) - py * math.sin(rot_speed)
		py = old_plane_x * math.sin(rot_speed) + py * math.cos(rot_speed)

	    }

	    // Update
	    for x in 0..<WINDOW_WIDTH {

		// Calculate ray position and direction
		cam_x := f32(2 * x) / f32(WINDOW_WIDTH) - 1
		ray_dir_x := player.dir.x + px * cam_x
		ray_dir_y := player.dir.y + py * cam_x

		// Which box of map we're in
		map_x := int(player.pos.x)
		map_y := int(player.pos.y)

		// Length of ray from current positon to next x or y side
		side_dist_x: f32
		side_dist_y: f32

		// Lenth of ray from one x or y-side to next x or y side
		delta_dist_x := abs(1 / ray_dir_x) < 0.0001 ? 1e10 : abs(1 / ray_dir_x)
		delta_dist_y := abs(1 / ray_dir_y) < 0.0001 ? 1e10 : abs(1 / ray_dir_y)
		perp_wall_dist: f32

		// What direction to step in x or y direction (either +1 or -1)
		step_x: int
		step_y: int

		hit: bool = false 
		side: int // (was it a North/South hit or a East/West hit?)

		// Calculate the step and initial side distance
		if ray_dir_x < 0 {
		    step_x = -1
		    side_dist_x = (player.pos.x - f32(map_x)) * delta_dist_x
		}
		else {
		    step_x = 1
		    side_dist_x = (f32(map_x) + 1 - player.pos.x) * delta_dist_x
		}

		if ray_dir_y < 0 {
		    step_y = -1
		    side_dist_y = (player.pos.y - f32(map_y)) * delta_dist_y
		}
		else {
		    step_y = 1
		    side_dist_y = (f32(map_y) + 1.0 - player.pos.y) * delta_dist_y
		}

		// Perform DDA 
		for hit == false {
		    // Jump to the next map square, in either x or y direction 
		    if side_dist_x < side_dist_y {
			side_dist_x += delta_dist_x
			map_x += step_x
			side = 0 
		    } 
		    else {
			side_dist_y += delta_dist_y
			map_y += step_y
			side = 1
		    }

		    if gs.world_map[map_x][map_y] > 0 do hit = true
		}

		// Calculate distance projected on camera direction. This is the shortest distance from hit point on wall to camera plane
		if side == 0  { perp_wall_dist = (side_dist_x - delta_dist_x) }
		else { perp_wall_dist = (side_dist_y - delta_dist_y) }

		// Calcualte height of the line to draw on screen
		line_height := int(WINDOW_HEIGHT / perp_wall_dist)

		// Calculate the lowest and highest pixel to fill in current strip 
		draw_start := -line_height / 2 + WINDOW_HEIGHT / 2
		if draw_start < 0 do draw_start = 0

		draw_end := line_height / 2 + WINDOW_HEIGHT / 2
		if draw_end >= WINDOW_HEIGHT do draw_end = WINDOW_HEIGHT - 1

		// Choose the wall color
		color: rl.Color

		switch gs.world_map[map_x][map_y] {
		case 1: color = rl.RED
		case 2: color = rl.GREEN
		case 3: color = rl.BLUE
		case 4: color = rl.WHITE
		case 5: color = rl.YELLOW
		}

		draw_vertical_line(x, draw_start, draw_end, color)
	    }

	}

	// Render
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.BLACK)

	if gs.editor_mode do render_editor(&es)

	if !gs.editor_mode do rl.DrawFPS(10,10)

    }
}

// ------------ Level Editor ----------------

update_editor :: proc(editor: ^Editor_State) {
    // Select brush value with number keys
    for i in 0..=5 {
	if rl.IsKeyPressed(rl.KeyboardKey(i + int(rl.KeyboardKey.ZERO))) do editor.brush_value = i
    }


    // Get mouse position and convert to grid coordinates
    mouse_pos := rl.GetMousePosition()
    grid_x := int(mouse_pos.x) / GRID_CELL_SIZE
    grid_y := int(mouse_pos.y) / GRID_CELL_SIZE

    // Place tile if click is within map bounds
    if rl.IsMouseButtonDown(.LEFT) && grid_x >= 0 && grid_x < MAP_SIZE && grid_y >= 0 && grid_y < MAP_SIZE {
	editor.e_map[grid_x][grid_y] = editor.brush_value
    }

    // Turn a tile into a blank space
    if rl.IsMouseButtonDown(.RIGHT) && grid_x >= 0 && grid_x < MAP_SIZE && grid_y >= 0 && grid_y < MAP_SIZE {
	editor.e_map[grid_x][grid_y] = 0
    }

    // Export to console  TODO: Export to a different format like JSON perhaps later for multiple levels?
    if rl.IsKeyPressed(.E) {
	export_map(editor.e_map)
	gs.world_map = editor.e_map
    }
}

render_editor :: proc(editor: ^Editor_State) {
// Draw grid
    for x in 0..<MAP_SIZE {
        for y in 0..<MAP_SIZE {
            color: rl.Color
            switch editor.e_map[x][y] {
            case 0: color = rl.BLACK
            case 1: color = rl.RED
            case 2: color = rl.GREEN
            case 3: color = rl.BLUE
            case 4: color = rl.WHITE
            case 5: color = rl.YELLOW
            }
            rl.DrawRectangle(i32(x * GRID_CELL_SIZE), i32(y * GRID_CELL_SIZE), GRID_CELL_SIZE - 1, GRID_CELL_SIZE - 1, color)
        }
    }

    // Highlight cell under mouse
    mouse_pos := rl.GetMousePosition()
    grid_x := int(mouse_pos.x) / GRID_CELL_SIZE
    grid_y := int(mouse_pos.y) / GRID_CELL_SIZE
    if grid_x >= 0 && grid_x < MAP_SIZE && grid_y >= 0 && grid_y < MAP_SIZE {
        rl.DrawRectangleLines(i32(grid_x * GRID_CELL_SIZE), i32(grid_y * GRID_CELL_SIZE), GRID_CELL_SIZE, GRID_CELL_SIZE, rl.WHITE)
    }

    // Show current brush value
    brush_string := fmt.ctprintf("Brush: %d (0-5)", editor.brush_value)
    rl.DrawText(brush_string, 10, WINDOW_HEIGHT - 30, 20, rl.WHITE)
    rl.DrawText("SPACE: Toggle Editor, E: Export, 0-5: Set Brush", 10, WINDOW_HEIGHT - 50, 20, rl.WHITE)
}

export_map :: proc(world: [MAP_SIZE][MAP_SIZE]int) {
    fmt.println("world_map := [MAP_SIZE][MAP_SIZE]int{")
    for y in 0..<MAP_SIZE {
	row := "{"
	for x in 0..<MAP_SIZE {
	    row = fmt.aprintf("%s%d,", row, world[x][y])
	}
	row = row[:len(row)-1] 
	fmt.println(row)
    }
    fmt.println("};")
}

// ------------ Drawing -----------------------
draw_vertical_line :: proc(x,y1,y2: int, color: rl.Color) {
    // Ensure y1 is the smaller y-coordinate
    y_1, y_2 := y1, y2
    if y_1 > y_2 {
	temp := y1
        y_1 = y2
        y_2 = temp
    }
    
    // Draw a filled rectangle
    rl.DrawRectangle(i32(x), i32(y_1), 1, i32(y_2 - y_1 + 1), color)
}
