import os
import re

print("=== 1. XCODE PROJECT VERSION AUDIT ===")
pbx_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI.xcodeproj\project.pbxproj"
if os.path.exists(pbx_path):
    with open(pbx_path, "r", encoding="utf-8") as f:
        pbx = f.read()
    m_vers = set(re.findall(r"MARKETING_VERSION = ([^;]+);", pbx))
    c_vers = set(re.findall(r"CURRENT_PROJECT_VERSION = ([^;]+);", pbx))
    print("iOS MARKETING_VERSION in Xcode project:", list(m_vers))
    print("iOS CURRENT_PROJECT_VERSION (Build) in Xcode project:", list(c_vers))

print("\n=== 2. ANDROID GRADLE VERSION AUDIT ===")
gradle_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI Google Play\app\build.gradle.kts"
if os.path.exists(gradle_path):
    with open(gradle_path, "r", encoding="utf-8") as f:
        gradle = f.read()
    v_code = re.findall(r"versionCode = (\d+)", gradle)
    v_name = re.findall(r'versionName = "([^"]+)"', gradle)
    print("Android versionCode:", v_code)
    print("Android versionName:", v_name)

print("\n=== 3. INDEX.HTML CODE AUDIT ACROSS ALL FOLDERS ===")
folders = [
    ("iOS Clean", r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html"),
    ("iOS Main", r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI\index.html"),
    ("Android Asset", r"c:\Users\Elif\Desktop\Projelerim\Firtina AI Google Play\app\src\main\assets\index.html"),
]

for label, p in folders:
    if os.path.exists(p):
        with open(p, "r", encoding="utf-8") as f:
            content = f.read()
        has_typo = "showCategoryGrid()" in content
        has_app_ver = re.findall(r"const APP_VERSION = [^\n]+", content)
        print(f"[{label}] Path: {p}")
        print(f"  - showCategoryGrid typo present: {has_typo}")
        print(f"  - APP_VERSION line: {has_app_ver}")
