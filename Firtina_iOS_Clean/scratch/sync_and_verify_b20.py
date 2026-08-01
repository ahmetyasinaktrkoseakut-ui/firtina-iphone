import os
import shutil

source_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html"
target_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI\index.html"
pbxproj_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI.xcodeproj\project.pbxproj"

# 1. Copy index.html to Firtina_AI
shutil.copy2(source_html, target_html)

# 2. Run sync_index.py
sync_script = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\scratch\sync_index.py"
if os.path.exists(sync_script):
    os.system(f'python "{sync_script}"')

# 3. Verify pbxproj values
with open(pbxproj_path, "r", encoding="utf-8") as f:
    pbx = f.read()

pbx = pbx.replace("MARKETING_VERSION = 1.16;", "MARKETING_VERSION = 1.15;")
pbx = pbx.replace("CURRENT_PROJECT_VERSION = 19;", "CURRENT_PROJECT_VERSION = 20;")

with open(pbxproj_path, "w", encoding="utf-8") as f:
    f.write(pbx)

print("Synchronized index.html and set pbxproj Build 20 (Version 1.15).")
