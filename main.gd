extends Control

var decoration_size := Vector2(0, 0)

onready var glass: TextureRect = $Glass
onready var tween: Tween = $Tween
onready var bg: Sprite = $Background


func _ready() -> void:
	bg.region_rect.size = OS.get_screen_size()
	bg.texture = get_wallpaper()
	
	# It is pretty inaccurate
	decoration_size = OS.get_real_window_size() - OS.window_size


func _process(_delta: float) -> void:
	bg.region_rect.position = OS.window_position + decoration_size


func get_wallpaper() -> ImageTexture:
	var image := Image.new()
	var err := -1
	
	match OS.get_name():
		"Windows":
			var locations := [
				"%s/Microsoft/Windows/Themes/CachedFiles/CachedImage_%s_%s_POS4.jpg" % [OS.get_environment("AppData"), OS.get_screen_size().x, OS.get_screen_size().y],
				"%s/Web/Wallpaper/Windows/img0.jpg" % OS.get_environment("SystemRoot"),
			]
			for i in locations:
				err = image.load(i)
				if err == OK:
					break
		"Linux":
			var output := []
			OS.execute("gsettings", ["get", "org.gnome.desktop.background", "picture-uri"], true, output)
			output[0].replace("file://", "")
			err = image.load(output[0])
	
	if err != OK:
		printerr("Couldn't get wallpaper. Error code %s" % err)
		return ImageTexture.new()
	
	var texture := ImageTexture.new()
	texture.create_from_image(image, ImageTexture.FLAGS_DEFAULT)
	
	return texture


func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		# warning-ignore:return_value_discarded
		tween.interpolate_property(
			glass.material,
			"shader_param/opacity",
			glass.material.get_shader_param("opacity"),
			0.5,
			0.1
		)
		# warning-ignore:return_value_discarded
		tween.start()
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		# warning-ignore:return_value_discarded
		tween.interpolate_property(
			glass.material,
			"shader_param/opacity",
			glass.material.get_shader_param("opacity"),
			1.0,
			0.1
		)
		# warning-ignore:return_value_discarded
		tween.start()
