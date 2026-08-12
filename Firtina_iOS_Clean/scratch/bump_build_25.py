import os
import shutil

source_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html"
target_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI\index.html"
pbxproj_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI.xcodeproj\project.pbxproj"

# Update index.html
with open(source_html, "r", encoding="utf-8") as f:
    html = f.read()

html = html.replace("Versiyon 1.15", "Versiyon 1.16")
html = html.replace("Versiyon 1.2", "Versiyon 1.16")
html = html.replace("Versiyon 1.1", "Versiyon 1.16")
html = html.replace("' 1.15'", "' 1.16'")
html = html.replace("' 1.2'", "' 1.16'")
html = html.replace("' 1.1'", "' 1.16'")
html = html.replace("const APP_VERSION = '1.15';", "const APP_VERSION = '1.16';")
html = html.replace("const APP_VERSION = '1.2';", "const APP_VERSION = '1.16';")
html = html.replace("const APP_VERSION = '1.1';", "const APP_VERSION = '1.16';")

with open(source_html, "w", encoding="utf-8") as f:
    f.write(html)

shutil.copy2(source_html, target_html)

# Update pbxproj to MARKETING_VERSION = 1.16 and CURRENT_PROJECT_VERSION = 25
with open(pbxproj_path, "r", encoding="utf-8") as f:
    pbx = f.read()

pbx = pbx.replace("MARKETING_VERSION = 1.2;", "MARKETING_VERSION = 1.16;")
pbx = pbx.replace("MARKETING_VERSION = 1.15;", "MARKETING_VERSION = 1.16;")
pbx = pbx.replace("MARKETING_VERSION = 1.1;", "MARKETING_VERSION = 1.16;")
pbx = pbx.replace("CURRENT_PROJECT_VERSION = 24;", "CURRENT_PROJECT_VERSION = 25;")
pbx = pbx.replace("CURRENT_PROJECT_VERSION = 23;", "CURRENT_PROJECT_VERSION = 25;")

with open(pbxproj_path, "w", encoding="utf-8") as f:
    f.write(pbx)

print("Successfully updated project.pbxproj to MARKETING_VERSION = 1.16 and BUILD = 25!")
