@tool

extends TextureRect

var mode:int = 0
var rects_to_draw:Array[Rect2] = [] 
var grid_size:Vector2i = Vector2i.ONE

func clear():
	mode = -1
	draw.emit()
	
func update_grid(size: Vector2i):
	grid_size = size
	mode = 0
	draw.emit()

func update_rect(rects: Array[Rect2]):
	rects_to_draw.append_array(rects)
	mode = 1
	draw.emit()
	
func _draw():
	if mode == -1: return
	if mode == 0:
		pass
	if mode == 1:
		var width_scale:float = size.x / texture.get_width()
		var height_scale:float = size.y / texture.get_height()
		for rect in rects_to_draw:
			var new_rect = Rect2(rect)
			new_rect.size = Vector2(rect.size.x * width_scale, rect.size.y * height_scale)
			new_rect.position = Vector2(rect.position.x * width_scale, rect.position.y * height_scale)
			draw_rect(new_rect, Color.AQUAMARINE, false)

