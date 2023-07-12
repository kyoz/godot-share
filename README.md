<h1 align="center">
  <br>
  <img src="./icon.png" alt="Godot Share" width=512>
  <br>
  Godot Share Plugin
  <br>
</h1>

<h4 align="center">Godot plugin to share text, image or both of em. Support Godot 3 & 4</a>.</h4>

<p align="center">
  <a href="https://github.com/kyoz/godot-share/releases">
    <img src="https://img.shields.io/github/v/tag/kyoz/godot-share?label=Version&style=flat-square">
  </a>
  <span>&nbsp</span>
  <a href="https://github.com/kyoz/godot-share/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/kyoz/godot-share/release.yml?label=Build&style=flat-square&color=00ad06">
  </a>
  <span>&nbsp</span>
  <a href="https://github.com/kyoz/godot-share/releases">
    <img src="https://img.shields.io/github/downloads/kyoz/godot-share/total?style=flat-square&label=Downloads&color=de3f00">
  </a>
  <span>&nbsp</span>
  <img src="https://img.shields.io/github/stars/kyoz/godot-share?style=flat-square&color=c99e00">
  <span>&nbsp</span>
  <img src="https://img.shields.io/github/license/kyoz/godot-share?style=flat-square&color=fc7b03">
</p>

<p align="center">
  <a href="#about">About</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#api">API</a> •
  <a href="#contribute">Contribute</a> •
  <a href="https://github.com/kyoz/godot-share/releases">Downloads</a> 
</p>

<p align="center">
  <img src="./demo.jpg" style="max-width: 580px; border-radius: 24px">
</p>

# About

This plugin allow you to share text, image or both of em (Android/iOS). There is also an advanced method allow you to save image to user phone.

Was build using automation scripts combine with CI/CD to help faster the release progress and well as release hotfix which save some of our times.

Support Godot 3 & 4.

# Installation

## Android

Download the [android plugin](https://github.com/kyoz/godot-share/releases) (match your Godot version), extract them to `your_project/android/plugins`

Enable `Share` plugin in your android export preset

*Note*: You must [use custom build](https://docs.godotengine.org/en/stable/tutorials/export/android_custom_build.html) for Android to use plugins.

## iOS

Download the [ios plugin](https://github.com/kyoz/godot-share/releases) (match your Godot version), extract them to `ios/plugins`

Enable `Share` plugin in your ios export preset

# Usage

You will need to add an `autoload` script to use this plugin more easily.

Download [autoload file](./autoload) to your game (Choose correct Godot version). Add it to your project `autoload` list.

Then you can easily use it anywhere with:

```gdscript
Share.init()

Share.shareText(title, subject, content)
Share.shareImage(image_path, title, subject, content)

# Godot 3
Share.connect("on_error", self, "_on_error")

# Godot 4
LocalNotification.on_error.connect(_on_error)
```

Why have to call `init()`. Well, if you don't want to call init, you can change `init()` to `_ready()` on the `autoload` file. But for my experience when using a lots of plugin, init all plugins on `_ready()` is not a good idea. So i let you choose whenever you init the plugin. When showing a loading scene...etc...

For more detail, see [examples](./example/)

# API

## Methods

```gdscript
shareText(title, subject, content)
shareImage(image_path, title, subject, content)
shareCapturedScreen(title, subject, content)

# Advanced function, read Caution part below
saveImageToGallery(image_path)
```

**Notes**:

- Title and Subject are base on app support, like Gmail...etc. Not all app suport em. You should focus on the content

- All share image must be inside your `User Data Folder`. You can easily get that folder path with `OS.get_user_data_dir()`. Make sure to save your image to that folder before share, or else it will not work. See [examples](./example/) for more detail.

**Caution**:

`saveImageToGallery()` is an advanced feature which i add to this plugin in order if someone need. It's great if player can save there ingame images to their phone. But it have something you must do in order to use it, or else the app will crash or have unwanted behavior.

To use `saveImageToGallery()`:

- Android: Make sure you checked "Allow Write Permission" on android's export preset.
- iOS: Add these to your `GameInfo.plist`, feel free to change the message.

```
<key>NSPhotoLibraryAddUsageDescription</key>
<string>To save screen capture image to your gallery</string>
```

And that's all, i've handle the permission request and process...etc...just call `saveImageToGallery(image_path)` and done.

Last note, i've tried to make the process simple and require just neccessary permission. This is not an plugin to work with file, so it will have some week point. Take an example, on some Android phone, there will no need to ask permission, you can save the image directly to Download folder. But when you open the gallery, the image will not show immediately, it will take some second, try to jump between albums and you image will appear. (The time the gallery app refresh is different from Android phone models, some is instantly but some will take longer)

## Signals

```gdscript
signal on_error(error_code)  # when something when wrong, return error_code
signal on_saved_to_gallery() # emit when `saveImageToGallery()` done
```

## Error Codes

> `ERROR_SHARE_CAPTURE_SCREEN`

This is rarely happen, but if it happen it's maybe you share captured image when the game is on heavy task so it break the process. 

> `ERROR_SAVE_TO_GALLERY`

Could happen if the image was damaged or device doesn't have any free storage left.

> `ERROR_IMAGE_FILE`

The share image was damaged. Rarely happen.

> `ERROR_UNKNOWN`

Unknown error. View Logcat (Android) or XCode debug (iOS) for more information

# Contribute

I want to help contribute to Godot community so i create these plugins. I'v prepared almost everything to help the development and release progress faster and easier.

Only one command and you'll build, release this plugin. Read [DEVELOP.md](./DEVELOP.md) for more information.

If you found bug of the plugin, please open issues.

If you have time to fix bugs or improve the plugins. Please open PR, it's always welcome.

# License

MIT © [Kyoz](mailto:banminkyoz@gmail.com)