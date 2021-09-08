# TKE-Flutter-Core
TKE Flutter Core(TFC) is a set of libraries, that the majority of our Flutter apps rely on. For the most part, TFC simplifies some of the more annoying pieces of the Flutter framework.
## Setup
1. Open a command terminal in your flutter project.
2. `git submodule add https://github.com/TurnKey-Ecosystems/TKE-Flutter-Core.git lib/TKE-Flutter-Core`
3. Add the following to `Flutter_Project_Directory/pubsec.yaml`:
```
name: ...
description: ...
publish_to: ...
version: ...

environment:
  ...

dependencies:
  http: ^0.12.1
  painter: ^0.4.0
  quiver: ^2.1.3
  photo_view: ^0.9.2
  device_info:  ^0.4.2+4
  image_picker: ^0.6.7+4
  flutter_share: ^1.0.2+1
  web_socket_channel: ^1.1.0
  path_provider: ^1.4.0
  flutter_mailer: ^0.5.1
  archive: ^2.0.11
  mime: ^0.9.6+3
  http_parser: ^3.1.4
  #permission: ^0.1.7
  #permission_handler: '^4.4.0+hotfix.2'
  flutter_image_compress: ^0.7.0
  flutter_reorderable_list: ^0.1.3
  image: ^2.1.12
  image_size_getter: ^0.1.0
  ...

dev_dependencies:
  # To apply icons run: $ flutter pub run flutter_launcher_icons:main
  flutter_launcher_icons: "^0.7.3"
  ...

flutter_icons:
  android: true 
  ios: true
  image_path_android: "assets/app_icon_android.png"
  image_path_ios: "assets/app_icon_ios.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/app_icon_android.png"
  
flutter:
  ...
  assets:
    - assets/
```
4. Add `provider_paths.xml` at `Flutter_Project_Directory/android/app/src/main/res/xml/provider_paths.xml`:
```
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-path name="external_files" path="."/>
</paths>
```
5. Add the following to `Flutter_Project_Directory/android/app/src/main/AndroidManifest.xml`:
```
<manifest...>
    <application...>
        ...
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.provider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/provider_paths"/>
        </provider>
    </application>
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>

```
6. Add the following to `Flutter_Project_Directory/ios/Runner/info.plist`:
```
<?xml...>
<!DOCTYPE...>
<plist...>
<dict>
  ...
	<key>NSCameraUsageDescription</key>
	<string>Dataplate needs to access your camer to take crane dataplate pictures.</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>Dataplate needs to access your photoroll to import crane dataplate pictures.</string>
	<key>UILaunchStoryboardName</key>
  ...
</dict>
</plist>
```
7. Make `Flutter_Project_Directory/lib/main.dart` look like:
```
import 'TKE-Flutter-Core/AppManagment/TFC_StartupController.dart';
import 'package:flutter/material.dart';

void main() => TFC_StartupController.runStartup(
  appName: "App Name",
  colorPrimary: Color(0xffaa8800),
  appLoadingLogoAssetPath: "assets/splash_screen_logo.jpg",
  appBarLogoAssetPath: "assets/app_bar_logo.png",
  itemTypesInThisApp: {/* TODO: Add AWS item types. */},
  homePageBuilder: () {
    return HomePage();
  },
  settingsPageBuilder: () {
    return SettingsPage();
  },
);
```
## Updating
`git submodule update`
## Dependencies
- To use this library you must have [flutter installed and setup](https://flutter.dev/docs/get-started/install).
- TKE-Flutter-Core is not a stand-alone system, it must be added to a flutter project.
