class_name AcrylicGlass, "icon.svg"
extends TextureRect

# A TextureRect that imitates Microsoft's Acrylic and Mica effects


const blur = preload("blur.gd")

const blur_amount := 50
export var tint_color := Color("661f1f1f") setget set_tint_color
export var opaque_on_lost_focus := true
export(float, 0, 2, 0.05) var fade_in_duration := 0.1
export(float, 0, 2, 0.05) var fade_out_duration := 0.1

var decoration_size := Vector2()
var dir := Directory.new()
var cache := {"wallpaper_checksum": "", "wallpaper_blur": -1}
var config := ConfigFile.new()


func _init() -> void:
	if not material:
		material = preload("acrylic_material.tres").duplicate()
	expand = true
	stretch_mode = STRETCH_TILE


func _ready() -> void:
	setup_config()
	
	if not texture:
		var wallpaper_info := get_wallpaper()
		var cache_blurred_path: String = "user://acrylic_cache/%s.res" % wallpaper_info.checksum
		
		if wallpaper_info.checksum == cache.wallpaper_checksum \
				and blur_amount == cache.wallpaper_blur \
				and dir.file_exists(cache_blurred_path):
			texture = load(cache_blurred_path)
		else:
			dir.remove(cache_blurred_path)
			
			wallpaper_info.texture.set_data(blur.fast_blur(wallpaper_info.texture.get_data(), blur_amount))
			texture = wallpaper_info.texture
			ResourceSaver.save("user://acrylic_cache/%s.res" % wallpaper_info.checksum, texture)
			
			cache.wallpaper_checksum = wallpaper_info.checksum
			cache.wallpaper_blur = blur_amount
			save_config()
	
	material.set_shader_param("screen_size", OS.get_screen_size())
	material.set_shader_param("texture_size", texture.get_size())
	
	# It is pretty inaccurate
	decoration_size = OS.get_real_window_size() - OS.window_size


func _process(_delta: float) -> void:
	material.set_shader_param("pos_on_screen", OS.window_position + decoration_size + rect_global_position)


func get_wallpaper() -> Dictionary:
	var wallpaper_info := {"texture": ImageTexture.new(), "checksum": ""}
	var image := Image.new()
	var file := File.new()
	var err := -1
	
	match OS.get_name():
		"Windows":
			var locations := [
				"%s/Microsoft/Windows/Themes/CachedFiles/CachedImage_%s_%s_POS4.jpg" % \
						[OS.get_environment("AppData"), OS.get_screen_size().x, OS.get_screen_size().y],
				"%s/Microsoft/Windows/Themes/CachedFiles/CachedImage_1128_634_POS4.jpg" % \
						OS.get_environment("AppData"),
				"%s/Web/Wallpaper/Windows/img0.jpg" % OS.get_environment("SystemRoot"),
			]
			for i in locations:
				err = image.load(i)
				if err == OK:
					wallpaper_info.checksum = file.get_md5(i)
					break
		"Linux":
			var output := []
			OS.execute("gsettings", ["get", "org.gnome.desktop.background", "picture-uri"], true, output)
			output[0].replace("file://", "")
			err = image.load(output[0])
			wallpaper_info.checksum = file.get_md5(output[0])
	
	if err == OK:
		wallpaper_info.texture.create_from_image(image)
	else:
		printerr("Couldn't get wallpaper. Error code %s" % err)
	
	return wallpaper_info


func setup_config() -> void:
	dir.make_dir("user://acrylic_cache")
	var err := config.load("user://acrylic_cache/config.cfg")
	
	if err:
		save_config()
		return
	
	cache.wallpaper_checksum = config.get_value("cache", "wallpaper_checksum", "")
	cache.wallpaper_blur = config.get_value("cache", "wallpaper_blur", -1)


func save_config() -> void:
	config.set_value("cache", "wallpaper_checksum", cache.wallpaper_checksum)
	config.set_value("cache", "wallpaper_blur", cache.wallpaper_blur)
	config.save("user://acrylic_cache/config.cfg")


func set_tint_color(value: Color) -> void:
	if value == tint_color:
		return
	
	tint_color = value
	material.set_shader_param("tint", tint_color)


func _notification(what: int) -> void:
	if not opaque_on_lost_focus:
		return
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		var tween := create_tween()
		tween.tween_property(material, "shader_param/tint:a", tint_color.a, fade_in_duration)
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		var tween := create_tween()
		tween.tween_property(material, "shader_param/tint:a", 1.0, fade_out_duration)
