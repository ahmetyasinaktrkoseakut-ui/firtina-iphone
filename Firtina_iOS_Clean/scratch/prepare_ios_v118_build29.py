import os
import re
import shutil

# 1. Update Xcode project.pbxproj to MARKETING_VERSION = 1.18 and CURRENT_PROJECT_VERSION = 29
pbx_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI.xcodeproj\project.pbxproj"
with open(pbx_path, "r", encoding="utf-8") as f:
    pbx = f.read()

pbx = re.sub(r'MARKETING_VERSION = [^;]+;', 'MARKETING_VERSION = 1.18;', pbx)
pbx = re.sub(r'CURRENT_PROJECT_VERSION = [^;]+;', 'CURRENT_PROJECT_VERSION = 29;', pbx)

with open(pbx_path, "w", encoding="utf-8") as f:
    f.write(pbx)

print("Updated Xcode project.pbxproj to MARKETING_VERSION = 1.18 and CURRENT_PROJECT_VERSION = 29!")

# 2. Update index.html for iOS Clean
source_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html"
target_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI\index.html"

with open(source_html, "r", encoding="utf-8") as f:
    html = f.read()

# Update APP_VERSION string to 1.18
html = re.sub(r"const APP_VERSION = [^\n]+", "const APP_VERSION = '1.18';", html)

# Ensure navTextHome is static 'Keşfet'
html = html.replace('<span id="navTextHome" class="text-xs font-medium">Ana Sayfa</span>', '<span id="navTextHome" class="text-xs font-medium">Keşfet</span>')

# Ensure translations.tr.nav.home is 'Keşfet'
html = html.replace('nav: { home: "Ana Sayfa"', 'nav: { home: "Keşfet"')

# Ensure showCategoryGrid is replaced by showCategories
html = html.replace("showCategoryGrid();", "showCategories();")

with open(source_html, "w", encoding="utf-8") as f:
    f.write(html)

shutil.copy2(source_html, target_html)

print("Updated iOS index.html with navTextHome = Keşfet and APP_VERSION = 1.18!")
