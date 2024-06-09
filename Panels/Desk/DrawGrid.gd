# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

@tool
extends Control
## Draws a grid of a specified size


## The color of the grid
@export var color: Color = Color.DIM_GRAY : set = set_color

## Whether or not to show the grid
@export var show_grid: bool = true : set = set_show_grid

## The grid size in px
@export var grid_size: Vector2 = Vector2(20, 20) : set = set_grid_size

## The line width in px
@export var line_width: float = 1 : set = set_line_width

## Sets the display mode of this grid
@export var grid_mode: display_mode = 0 : set = set_grid_mode


enum display_mode {GRID_MODE_LINE, GRID_MODE_DOT, GRID_MODE_DOT_LINE}


## Whether or not to show the grid
func set_show_grid(p_show_grid) -> void:
	show_grid = p_show_grid
	queue_redraw()


## Sets the grid size in px
func set_grid_size(p_grid_size: Vector2) -> void:
	grid_size = p_grid_size
	queue_redraw()


## Sets the color of the grid
func set_color(p_color: Color) -> void:
	color = p_color
	queue_redraw()


## Sets the line or dot size of the grid
func set_line_width(p_line_width: float) -> void:
	line_width = p_line_width
	queue_redraw()


## Sets whether or not to show dots instead of lines
func set_grid_mode(p_grid_mode) -> void:
	grid_mode = p_grid_mode
	queue_redraw()


func _draw() -> void:
	if not show_grid:
		return
	
	if grid_mode == display_mode.GRID_MODE_DOT or grid_mode == display_mode.GRID_MODE_DOT_LINE:
		for x in range(0, size.x, grid_size.x):
			for y in range(0, size.y, grid_size.y):
				draw_circle(Vector2(x, y), line_width, color)
	
	if grid_mode == display_mode.GRID_MODE_LINE or grid_mode == display_mode.GRID_MODE_DOT_LINE:
		for x in range(0, size.x, grid_size.x):
			draw_line(Vector2(x, 0), Vector2(x, size.y), color, line_width)
		
		for y in range(0, size.y, grid_size.y):
			draw_line(Vector2(0, y), Vector2(size.x, y), color, line_width)
