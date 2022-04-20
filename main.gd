extends Control

var decoration_size := Vector2(0, 0)

onready var glass := $Glass
onready var tween := $Tween
onready var bg := $Background


func _ready() -> void:
	bg.region_rect.size = OS.get_screen_size()
	bg.texture = get_wallpaper()
	
	# Doesn't really work
	decoration_size = OS.get_real_window_size() - OS.window_size


func _process(delta) -> void:
	bg.region_rect.position = OS.window_position + decoration_size


func get_wallpaper() -> ImageTexture:
	var image := Image.new()
	var err = image.load("C:/Users/%s/AppData/Roaming/Microsoft/Windows/Themes/CachedFiles/CachedImage_1920_1080_POS4.jpg" % OS.get_environment("USERNAME"))
	if err != OK:
		print("Error: %s" % err)
	
	var texture := ImageTexture.new()
	texture.create_from_image(image, 0)
	
	return texture


func _notification(what) -> void:
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		tween.interpolate_property(
			glass.material,
			"shader_param/opacity",
			glass.material.get_shader_param("opacity"),
			0.5,
			0.1
		)
		tween.start()
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		tween.interpolate_property(
			glass.material,
			"shader_param/opacity",
			glass.material.get_shader_param("opacity"),
			1.0,
			0.1
		)
		tween.start()
