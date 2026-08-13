import os
import re

# 1. Remove READ_MEDIA permissions from AndroidManifest.xml
manifest_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI Google Play\app\src\main\AndroidManifest.xml"
with open(manifest_path, "r", encoding="utf-8") as f:
    manifest = f.read()

# Lines to remove
manifest = re.sub(r'\s*<uses-permission android:name="android\.permission\.READ_MEDIA_IMAGES" />', '', manifest)
manifest = re.sub(r'\s*<uses-permission android:name="android\.permission\.READ_MEDIA_VIDEO" />', '', manifest)
manifest = re.sub(r'\s*<uses-permission android:name="android\.permission\.READ_MEDIA_VISUAL_USER_SELECTED" />', '', manifest)

with open(manifest_path, "w", encoding="utf-8") as f:
    f.write(manifest)

print("Removed READ_MEDIA permissions from AndroidManifest.xml!")

# 2. Bump Android versionCode to 18 and versionName to 1.18 in build.gradle.kts
gradle_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI Google Play\app\build.gradle.kts"
with open(gradle_path, "r", encoding="utf-8") as f:
    gradle = f.read()

gradle = gradle.replace('versionCode = 17', 'versionCode = 18')
gradle = gradle.replace('versionName = "1.17"', 'versionName = "1.18"')

with open(gradle_path, "w", encoding="utf-8") as f:
    f.write(gradle)

print("Updated build.gradle.kts to versionCode = 18 and versionName = 1.18!")
