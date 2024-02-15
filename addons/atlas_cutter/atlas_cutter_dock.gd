@tool

extends Control

@onready var preview_texture_rect = $MarginContainer/HSplitContainer/CenterContainer/TextureRect
@onready var grid_cut_button = $MarginContainer/HSplitContainer/VBoxContainer4/TabContainer/Grid/Button
@onready var cut_split_button = $MarginContainer/HSplitContainer/VBoxContainer4/TabContainer/split/Button3
@onready var slider_tolerance_label = $MarginContainer/HSplitContainer/VBoxContainer4/TabContainer/split/Label
@onready var progress_bar = $MarginContainer/HSplitContainer/VBoxContainer4/ProgressBar

@onready var spin_boxSizeWidth:SpinBox = $MarginContainer/HSplitContainer/VBoxContainer4/TabContainer/Grid/hola/VBoxContainer/HBoxContainer/SpinBox
@onready var spin_boxSizeHeight:SpinBox = $MarginContainer/HSplitContainer/VBoxContainer4/TabContainer/Grid/hola/VBoxContainer/HBoxContainer2/SpinBox2
@onready var spin_boxMarginHorizontal:SpinBox = $MarginContainer/HSplitContainer/VBoxContainer4/TabContainer/Grid/hola/VBoxContainer2/HBoxContainer/SpinBox3
@onready var spin_boxMarginVertical:SpinBox = $MarginContainer/HSplitContainer/VBoxContainer4/TabContainer/Grid/hola/VBoxContainer2/HBoxContainer2/SpinBox4

var selector_file:EditorFileDialog
var save_file:EditorFileDialog
var file_name:String
var mode:int = 0
var tolerance = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	selector_file = EditorFileDialog.new()
	selector_file.add_filter("*.png")
	selector_file.title = "Select file"
	selector_file.file_selected.connect(_on_file_dialog_file_selected)
	selector_file.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE 
	add_child(selector_file)
	
	save_file = EditorFileDialog.new()
	save_file.title = "Select folder"
	save_file.dir_selected.connect(_on_folder_dialog_selected)
	save_file.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR 
	add_child(save_file)


func _on_button_2_pressed():
	selector_file.show()

func _on_folder_dialog_selected(path:String):
	if mode == 0:
		cut_in_grid(path)
	else:
		cut_in_spaces(path)

func cut_in_grid(path:String):
	var width:int = spin_boxSizeWidth.value
	var height:int = spin_boxSizeHeight.value
	var marginH:int = spin_boxMarginHorizontal.value
	var marginV:int = spin_boxMarginVertical.value
	var horizontal_slices:int = preview_texture_rect.texture.get_width()/width+(marginH*2)
	var vertical_slices:int = preview_texture_rect.texture.get_height()/height+(marginV*2)
	
	progress_bar.value = 0
	progress_bar.max_value = horizontal_slices*vertical_slices
	progress_bar.visible = true
	for i in range(horizontal_slices):
		for j in range(vertical_slices):
			var at: AtlasTexture = AtlasTexture.new()
			at.atlas = preview_texture_rect.texture
			at.region = Rect2((i*width)+marginH, (j*height)+marginV, width+marginH, height+marginV)
			var new_resource_path:String = path+"/"+str(i)+"_"+str(j)+"_"+file_name+".tres"
			var err = ResourceSaver.save(at, new_resource_path, 0)
			progress_bar.value += 1
			await get_tree().process_frame
	progress_bar.visible = false

func get_rects():
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(preview_texture_rect.texture.get_image())
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(), bitmap.get_size()), 1)
	var rects:Array[Rect2] = []
	for polygon in polygons:
		var xi = INF
		var yi = INF
		var xf = -INF
		var yf = -INF
		for vector in polygon:
			xi = min(xi, vector.x)
			yi = min(yi, vector.y)
			xf = max(xf, vector.x)
			yf = max(yf, vector.y)
	
		rects.append(Rect2(Vector2(xi, yi), Vector2(xf-xi, yf-yi)))
	return rects
	
func cut_in_spaces(path:String):
	var rects = get_rects()
	
	progress_bar.value = 0
	progress_bar.max_value = rects.size()
	progress_bar.visible = true
	
	var width:int = spin_boxSizeWidth.value
	var height:int = spin_boxSizeHeight.value
	var marginH:int = spin_boxMarginHorizontal.value
	var marginV:int = spin_boxMarginVertical.value
	
	var index:int = 0
	for rect:Rect2 in rects:
		var at: AtlasTexture = AtlasTexture.new()
		at.atlas = preview_texture_rect.texture
		at.region = Rect2(rect.position.x-marginH, 
		rect.position.y-marginV, 
		rect.size.x+marginH, 
		rect.size.y+marginV)
		var new_resource_path:String = path+"/"+str(index)+"_"+file_name+".tres"
		var err = ResourceSaver.save(at, new_resource_path, 0)
		index+=1
		progress_bar.value += 1
		await get_tree().process_frame
	progress_bar.visible = false

func _on_file_dialog_file_selected(path:String):
	var resource_loaded = load(path)
	if resource_loaded:
		preview_texture_rect.texture = resource_loaded
		var path_splitted = path.split("/");
		file_name = path_splitted[path_splitted.size()-1]
		file_name = file_name.substr(0,file_name.find("."))
		cut_split_button.disabled = false
		grid_cut_button.disabled = false
	else:
		printerr("Can't load the resource")



func _on_button_pressed():
	mode = 0
	save_file.show()


func _on_spin_box_value_changed(value):
	var width:int = spin_boxSizeWidth.value
	var height:int = spin_boxSizeHeight.value
	preview_texture_rect.clear()
	preview_texture_rect.update_grid(Vector2i(width,height))


func _on_button_3_pressed():
	mode = 1
	save_file.show()



# preview_texture_rect.update_rect(get_rects())
@onready var padding_up = $MarginContainer/HSplitContainer/VBoxContainer4/TabContainer/split/VBoxContainer/PaddingUp
@onready var padding_left = $MarginContainer/HSplitContainer/VBoxContainer4/TabContainer/split/VBoxContainer/HBoxContainer/PaddingLeft
@onready var padding_right = $MarginContainer/HSplitContainer/VBoxContainer4/TabContainer/split/VBoxContainer/HBoxContainer/PaddingRight
@onready var padding_bottom = $MarginContainer/HSplitContainer/VBoxContainer4/TabContainer/split/VBoxContainer/PaddingBottom

func _on_padding_value_changed(value):
	preview_texture_rect.clear()
	var a:Array[Rect2] = []
	for b in get_rects():
		var c := Rect2(b)
		c.position = Vector2(
						c.position.x-padding_left.value if c.position.x-padding_left.value >= 0 else c.position.x,
						c.position.y-padding_up.value if c.position.y-padding_up.value >= 0 else c.position.y)
		c.size = Vector2(
			c.size.x+padding_right.value if c.size.x+padding_right.value < preview_texture_rect.texture.get_width() else c.size.x,
			c.size.y+padding_bottom.value if c.size.y+padding_bottom.value < preview_texture_rect.texture.get_height() else c.size.y)
		a.append(c)
	preview_texture_rect.update_rect(a)
