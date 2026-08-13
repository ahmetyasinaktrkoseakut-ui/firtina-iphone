import os
import shutil

source_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html"
target_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI\index.html"

with open(source_html, "r", encoding="utf-8") as f:
    html = f.read()

# Replace typo showCategoryGrid() with showCategories()
old_typo = "showCategoryGrid();"
new_fixed = "showCategories();"

if old_typo in html:
    html = html.replace(old_typo, new_fixed)
    print("Fixed typo: showCategoryGrid() -> showCategories()!")

with open(source_html, "w", encoding="utf-8") as f:
    f.write(html)

shutil.copy2(source_html, target_html)

# Sync across all project directories
sync_script = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\scratch\sync_index.py"
if os.path.exists(sync_script):
    os.system(f'python "{sync_script}"')

print("Synced fixed index.html across all project files!")
