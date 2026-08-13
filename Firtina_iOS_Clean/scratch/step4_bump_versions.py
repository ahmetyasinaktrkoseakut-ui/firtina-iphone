import os

# 1. Update Android Studio build.gradle.kts
android_gradle_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI Google Play\app\build.gradle.kts"
with open(android_gradle_path, "r", encoding="utf-8") as f:
    gradle_content = f.read()

gradle_content = gradle_content.replace('versionCode = 15', 'versionCode = 17')
gradle_content = gradle_content.replace('versionName = "1.15"', 'versionName = "1.17"')

with open(android_gradle_path, "w", encoding="utf-8") as f:
    f.write(gradle_content)

print("Updated Android build.gradle.kts to versionCode = 17, versionName = 1.17!")

# 2. Update Apple Xcode project.pbxproj
pbxproj_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI.xcodeproj\project.pbxproj"
with open(pbxproj_path, "r", encoding="utf-8") as f:
    pbx_content = f.read()

pbx_content = pbx_content.replace('MARKETING_VERSION = 1.16;', 'MARKETING_VERSION = 1.17;')
pbx_content = pbx_content.replace('CURRENT_PROJECT_VERSION = 27;', 'CURRENT_PROJECT_VERSION = 28;')

with open(pbxproj_path, "w", encoding="utf-8") as f:
    f.write(pbx_content)

print("Updated Apple project.pbxproj to MARKETING_VERSION = 1.17, CURRENT_PROJECT_VERSION = 28!")
