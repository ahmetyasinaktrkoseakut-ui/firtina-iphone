import os
import shutil

source_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html"
target_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI\index.html"

with open(source_html, "r", encoding="utf-8") as f:
    html = f.read()

old_func = """function updateInternalTools(newTools) {
            if (Array.isArray(newTools) && newTools.length > 0) {
                tools = newTools;
                saveData();
                renderTools();
            }
        }"""

new_func = """function updateInternalTools(newTools) {
            if (Array.isArray(newTools) && newTools.length > 0) {
                tools = newTools;
                saveData();
                renderCategories();
                renderTools();
            }
        }"""

if old_func in html:
    html = html.replace(old_func, new_func)
    print("Updated updateInternalTools to trigger renderCategories() & renderTools()!")

with open(source_html, "w", encoding="utf-8") as f:
    f.write(html)

shutil.copy2(source_html, target_html)

# Sync across all project directories
sync_script = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\scratch\sync_index.py"
if os.path.exists(sync_script):
    os.system(f'python "{sync_script}"')

print("Synced updated updateInternalTools across all project index.html files!")
