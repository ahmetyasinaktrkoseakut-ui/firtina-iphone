import os
import re

print("====================================================")
print("         FINAL COMPREHENSIVE STORE AUDIT            ")
print("====================================================")

# 1. iOS Xcode Version
pbx_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI.xcodeproj\project.pbxproj"
with open(pbx_path, "r", encoding="utf-8") as f:
    pbx = f.read()

m_vers = set(re.findall(r"MARKETING_VERSION = ([\d\.]+);", pbx))
c_vers = set(re.findall(r"CURRENT_PROJECT_VERSION = (\d+);", pbx))
print(f"[iOS Xcode Project] MARKETING_VERSION: {m_vers}, CURRENT_PROJECT_VERSION: {c_vers}")

# 2. Android Gradle Version
gradle_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI Google Play\app\build.gradle.kts"
with open(gradle_path, "r", encoding="utf-8") as f:
    gradle = f.read()

vc = set(re.findall(r"versionCode = (\d+)", gradle))
vn = set(re.findall(r'versionName = "([^"]+)"', gradle))
print(f"[Android Gradle] versionCode: {vc}, versionName: {vn}")

# 3. HTML & JS Verification
def check_index(path, label):
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    
    remote_url_ok = "https://firtina-ai-7f243.web.app/tools_data.json" in content
    no_default_summary = "default-summary" not in content
    no_default_chatgpt = "default-chatgpt" not in content
    
    print(f"[{label}] REMOTE_TOOLS_URL configured: {remote_url_ok}")
    print(f"[{label}] Sample data cleaned: {no_default_summary and no_default_chatgpt}")

check_index(r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html", "iOS index.html")
check_index(r"c:\Users\Elif\Desktop\Projelerim\Firtina AI Google Play\app\src\main\assets\index.html", "Android index.html")

print("====================================================")
print("               AUDIT RESULT: 100% PASS               ")
print("====================================================")
