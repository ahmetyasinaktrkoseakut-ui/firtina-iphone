import os
import shutil

source_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html"
target_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI\index.html"

with open(source_html, "r", encoding="utf-8") as f:
    html = f.read()

# 1. Update APP_VERSION string in index.html to 1.17
old_app_ver = "const APP_VERSION = '1.16';"
new_app_ver = "const APP_VERSION = '1.17';"

if old_app_ver in html:
    html = html.replace(old_app_ver, new_app_ver)
    print("Updated APP_VERSION to 1.17!")

# 2. Strengthen updateInternalTools to never accept less than 10 tools
old_update_tools = """function updateInternalTools(newTools) {
            if (Array.isArray(newTools) && newTools.length > 0) {
                tools = newTools;
                saveData();
                renderCategories();
                renderTools();
            }
        }"""

new_update_tools = """function updateInternalTools(newTools) {
            if (Array.isArray(newTools) && newTools.length >= 10) {
                tools = newTools;
                saveData();
                renderCategories();
                renderTools();
            }
        }"""

if old_update_tools in html:
    html = html.replace(old_update_tools, new_update_tools)
    print("Strengthened updateInternalTools minimum tools check!")

# 3. Strengthen loadData to purge empty localStorage cache and guarantee initialTools
old_load_data_logic = """if (storedVersion === APP_VERSION && storedToolsJson) {
                    const parsedTools = JSON.parse(storedToolsJson);
                    if (Array.isArray(parsedTools) && parsedTools.length > 0) {
                        tools = parsedTools;
                    } else {
                        tools = initialTools;
                    }
                } else {
                    // Version mismatch or no stored data → use initialTools
                    tools = initialTools;
                    localStorage.setItem('appVersion', APP_VERSION);
                    localStorage.setItem('aiTools', JSON.stringify(initialTools));
                }"""

new_load_data_logic = """if (storedVersion === APP_VERSION && storedToolsJson) {
                    const parsedTools = JSON.parse(storedToolsJson);
                    if (Array.isArray(parsedTools) && parsedTools.length >= 10) {
                        tools = parsedTools;
                    } else {
                        tools = initialTools;
                        saveData();
                    }
                } else {
                    tools = initialTools;
                    saveData();
                }"""

if old_load_data_logic in html:
    html = html.replace(old_load_data_logic, new_load_data_logic)
    print("Strengthened loadData cache fallback!")

with open(source_html, "w", encoding="utf-8") as f:
    f.write(html)

shutil.copy2(source_html, target_html)

# Sync across all project directories
sync_script = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\scratch\sync_index.py"
if os.path.exists(sync_script):
    os.system(f'python "{sync_script}"')

print("Successfully fixed APP_VERSION and cache fallback across all project files!")
