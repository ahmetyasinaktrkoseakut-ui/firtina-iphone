import os
import shutil

source_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html"
target_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI\index.html"
pbxproj_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI.xcodeproj\project.pbxproj"

# 1. Update index.html version to 1.15
with open(source_html, "r", encoding="utf-8") as f:
    html = f.read()

html = html.replace("Versiyon 1.16", "Versiyon 1.15")
html = html.replace("' 1.16'", "' 1.15'")
html = html.replace("const APP_VERSION = '1.16';", "const APP_VERSION = '1.15';")

with open(source_html, "w", encoding="utf-8") as f:
    f.write(html)

shutil.copy2(source_html, target_html)

# 2. Update pbxproj to MARKETING_VERSION = 1.15 and CURRENT_PROJECT_VERSION = 22
with open(pbxproj_path, "r", encoding="utf-8") as f:
    pbx = f.read()

pbx = pbx.replace("MARKETING_VERSION = 1.16;", "MARKETING_VERSION = 1.15;")
pbx = pbx.replace("CURRENT_PROJECT_VERSION = 19;", "CURRENT_PROJECT_VERSION = 22;")
pbx = pbx.replace("CURRENT_PROJECT_VERSION = 20;", "CURRENT_PROJECT_VERSION = 22;")
pbx = pbx.replace("CURRENT_PROJECT_VERSION = 21;", "CURRENT_PROJECT_VERSION = 22;")
pbx = pbx.replace("CURRENT_PROJECT_VERSION = 18;", "CURRENT_PROJECT_VERSION = 22;")

with open(pbxproj_path, "w", encoding="utf-8") as f:
    f.write(pbx)

# 3. Sync to all backup target directories
sync_script = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\scratch\sync_index.py"
if os.path.exists(sync_script):
    os.system(f'python "{sync_script}"')

print("Updated project.pbxproj to Version 1.15 Build 22 for clean App Store metadata update.")
