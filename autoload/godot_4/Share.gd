extends Node

signal on_error(error_code)
signal on_saved_to_gallery()

var share = null

var is_capturing = false
var is_bellow_android_11 = false
var gallery_image_dir

# Change this to _ready() if you want automatically init
func init():
	if Engine.has_singleton("Share"):
		share = Engine.get_singleton("Share")
		init_signals()
		init_android_gallery_image_dir()


func init_signals():
	share.connect("error", Callable(self, "_on_error"))


func init_android_gallery_image_dir():
	var os_version = get_os_version()
	
	if os_version > 0 and os_version < 11:
		is_bellow_android_11 = true
		gallery_image_dir = OS.get_system_dir(OS.SYSTEM_DIR_DCIM) + "/Screenshots/"
	else:
		gallery_image_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS) + "/"


func _on_error(error_code):
	emit_signal("on_error", error_code)


func shareText(title, subject, content):
	if not share:
		not_found_plugin()
		return
	
	share.shareText(title, subject, content)


func shareImage(image_path, title, subject, content):
	if not share:
		not_found_plugin()
		return
	
	share.shareImage(image_path, title, subject, content)


func shareCapturedScreen(title, subject, content):
	if is_capturing:
		return
	
	is_capturing = true
	
	#get_viewport().set_clear_mode(SubViewport.CLEAR_MODE_ONCE)
	
	# Let two frames pass to make sure the screen was captured
	await get_tree().process_frame
	await get_tree().process_frame

	# Retrieve the captured image
	var img = get_viewport().get_texture().get_image()
	
	# Flip it on the y-axis (because it's flipped).
	#img.flip_y()
	
	# Save to storage
	var save_path = OS.get_user_data_dir() + "/captured.png"
	var task = img.save_png(save_path)
	
	if task == OK:
		shareImage(save_path, title, subject, content)
	else:
		emit_signal("error", "ERROR_SHARE_CAPTURE_SCREEN");
	
	is_capturing = false


func saveImageToGallery(image_path):
	if OS.get_name() == "iOS":
		share.saveImageToGallery(image_path)
		emit_signal("on_saved_to_gallery")
	else:
		saveImageToGalleryAndroid(image_path)

func saveImageToGalleryAndroid(image_path):
	if is_bellow_android_11:
		if not (OS.get_granted_permissions() as Array).has("android.permission.WRITE_EXTERNAL_STORAGE"):
			var _o = OS.request_permissions()
			return
	
	# Check if Picture dir exist
	if not DirAccess.dir_exists_absolute(gallery_image_dir):
		DirAccess.make_dir_recursive_absolute(gallery_image_dir)
	
	# Save to storage
	var image = Image.new()
	var error = image.load(image_path)
	
	if error != OK:
		emit_signal("on_error", "ERROR_SAVE_TO_GALLERY")
		return

	var texture = ImageTexture.create_from_image(image)

	var task = texture.get_image().save_png(gallery_image_dir + \
		remove_invalid_characters(ProjectSettings.get_setting("application/config/name")) + \
		str(Time.get_unix_time_from_system()) + ".png")
	
	# Done
	if task == OK:
		emit_signal("on_saved_to_gallery")
	else:
		emit_signal("on_error", "ERROR_SAVE_TO_GALLERY");


# UTILS ========================================================================

func get_os_version():
	var out = []
	var _o = OS.execute("getprop", ["ro.build.version.release"], out)
	var version = float(str(out[0]))
	
	if typeof(version) != TYPE_FLOAT:
		return 0
		
	return version


func remove_invalid_characters(_string):
	var string = _string
	var invalid_chars = "=:/\\?*\"|%<>"
	
	for c in invalid_chars:
		string = string.replace(c, "")

	string = string.replace(" ", "")
	string = string.replace(".", "_")
	return string


func not_found_plugin():
	print('[Share] Not found plugin. Please ensure that you checked Rating plugin in the export template')
