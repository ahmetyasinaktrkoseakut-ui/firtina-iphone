import os
import shutil

pbxproj_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI.xcodeproj\project.pbxproj"

with open(pbxproj_path, "r", encoding="utf-8") as f:
    pbx = f.read()

pbx = pbx.replace("CURRENT_PROJECT_VERSION = 26;", "CURRENT_PROJECT_VERSION = 27;")
pbx = pbx.replace("CURRENT_PROJECT_VERSION = 25;", "CURRENT_PROJECT_VERSION = 27;")

with open(pbxproj_path, "w", encoding="utf-8") as f:
    f.write(pbx)

print("Updated project.pbxproj to CURRENT_PROJECT_VERSION = 27!")
