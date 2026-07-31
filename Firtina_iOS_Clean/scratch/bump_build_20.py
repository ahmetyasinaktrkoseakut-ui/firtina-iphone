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

# 2. Update pbxproj to MARKETING_VERSION = 1.15 and CURRENT_PROJECT_VERSION = 20
with open(pbxproj_path, "r", encoding="utf-8") as f:
    pbx = f.read()

pbx = pbx.replace("MARKETING_VERSION = 1.16;", "MARKETING_VERSION = 1.15;")
pbx = pbx.replace("CURRENT_PROJECT_VERSION = 19;", "CURRENT_PROJECT_VERSION = 20;")

with open(pbxproj_path, "w", encoding="utf-8") as f:
    f.write(pbx)

print("Bumped build to Version 1.15 (Build 20) with 100% original webapp code.")
