extends Node


func _ready():
	Share.init()
	
	Share.connect("on_error", self, "_on_error")
	Share.connect("on_saved_to_gallery", self, "_on_saved_to_gallery")


func _on_error(error_code):
	print("Share failed with error: " + error_code)


func _on_saved_to_gallery():
	OS.alert("Saved image to gallery")


func _on_ShareTextBtn_pressed():
	var title = $Canvas/Center/VBox/Title/TextEdit.text
	var subject = $Canvas/Center/VBox/Subject/TextEdit.text
	var content = $Canvas/Center/VBox/Content/TextEdit.text
	Share.shareText(title, subject, content)


func _on_ShareImageBtn_pressed():
	# Because limit on permission, you better save your image to "User Data Folder" in order to sharing it
	var image_path = OS.get_user_data_dir() + "/temp.png"
	$Canvas/Center/VBox/Image.texture.get_data().save_png(image_path)
	
	var title = $Canvas/Center/VBox/Title/TextEdit.text
	var subject = $Canvas/Center/VBox/Subject/TextEdit.text
	var content = $Canvas/Center/VBox/Content/TextEdit.text
	Share.shareImage(image_path, title, subject, content)


func _on_ShareCapturedScreenBtn_pressed():
	var title = $Canvas/Center/VBox/Title/TextEdit.text
	var subject = $Canvas/Center/VBox/Subject/TextEdit.text
	var content = $Canvas/Center/VBox/Content/TextEdit.text
	Share.shareCapturedScreen(title, subject, content)


func _on_SaveImageToGalleryBtn_pressed():
	var image_path = OS.get_user_data_dir() + "/temp.png"
	$Canvas/Center/VBox/Image.texture.get_data().save_png(image_path)
	Share.saveImageToGallery(image_path)
