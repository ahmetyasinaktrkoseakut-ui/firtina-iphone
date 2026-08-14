import os
import re

# 1. Update project.pbxproj to explicitly set CODE_SIGN_IDENTITY = "iPhone Distribution"
pbx_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI.xcodeproj\project.pbxproj"
with open(pbx_path, "r", encoding="utf-8") as f:
    pbx = f.read()

# Replace CODE_SIGN_STYLE = Automatic with CODE_SIGN_STYLE = Automatic + CODE_SIGN_IDENTITY = "iPhone Distribution"
pbx = pbx.replace(
    'CODE_SIGN_STYLE = Automatic;',
    'CODE_SIGN_IDENTITY = "iPhone Distribution";\n\t\t\t\tCODE_SIGN_STYLE = Automatic;'
)

with open(pbx_path, "w", encoding="utf-8") as f:
    f.write(pbx)

print("Updated Xcode project.pbxproj with iPhone Distribution signing identity!")

# 2. Update deploy_ios.yml to remove the command line override conflict
wf_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\.github\workflows\deploy_ios.yml"
with open(wf_path, "r", encoding="utf-8") as f:
    wf = f.read()

wf = wf.replace('            CODE_SIGN_IDENTITY="Apple Distribution" \\\n            CODE_SIGN_STYLE="Automatic"', '')

with open(wf_path, "w", encoding="utf-8") as f:
    f.write(wf)

print("Cleaned deploy_ios.yml workflow!")
