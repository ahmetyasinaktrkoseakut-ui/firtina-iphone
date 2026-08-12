import os
import shutil

source_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html"
target_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI\index.html"

with open(source_html, "r", encoding="utf-8") as f:
    html = f.read()

# Update REMOTE_TOOLS_URL to the live Firebase Hosting URL
old_line = "const REMOTE_TOOLS_URL = '';"
new_line = "const REMOTE_TOOLS_URL = 'https://firtina-ai-7f243.web.app/tools_data.json';"

if old_line in html:
    html = html.replace(old_line, new_line)
    print("Replaced REMOTE_TOOLS_URL with live Firebase Hosting URL!")
else:
    print("Searching for REMOTE_TOOLS_URL pattern via regex...")
    import re
    html = re.sub(r"const\s+REMOTE_TOOLS_URL\s*=\s*['\"].*?['\"];", new_line, html)

with open(source_html, "w", encoding="utf-8") as f:
    f.write(html)

shutil.copy2(source_html, target_html)

# Sync across all backups
sync_script = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\scratch\sync_index.py"
if os.path.exists(sync_script):
    os.system(f'python "{sync_script}"')

print("Successfully updated REMOTE_TOOLS_URL to https://firtina-ai-7f243.web.app/tools_data.json across all project files!")
