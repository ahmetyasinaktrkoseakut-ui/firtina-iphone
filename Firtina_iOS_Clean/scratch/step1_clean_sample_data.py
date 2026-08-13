import os
import re
import shutil

source_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html"
target_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI\index.html"

with open(source_html, "r", encoding="utf-8") as f:
    html = f.read()

# 1. Clean graderInput auto-population so it remains 100% empty by default
grader_block_start = html.find("// Pre-populate prompt grader input and trigger grading")
if grader_block_start != -1:
    grader_block_end = html.find("});", grader_block_start)
    if grader_block_end != -1:
        clean_grader_code = """// Prompt grader input - empty by default
            const graderIn = document.getElementById('graderInput');
            if (graderIn) {
                const savedGraderVal = localStorage.getItem('firtina_grader_user_val');
                if (savedGraderVal !== null) { graderIn.value = savedGraderVal; }
                graderIn.addEventListener('input', () => {
                    localStorage.setItem('firtina_grader_user_val', graderIn.value);
                });
            }"""
        # Replace block
        html = html[:grader_block_start] + clean_grader_code + html[grader_block_end+3:]
        print("Cleaned graderInput auto-fill logic!")

# 2. Clean window.initStudio sample prompts and budget items
init_studio_start = html.find("window.initStudio = function initStudio()")
if init_studio_start != -1:
    init_studio_end = html.find("setStudioTab(activeStudioTab);", init_studio_start)
    if init_studio_end != -1:
        clean_init_studio = """window.initStudio = function initStudio() {
            try {
                customPrompts = JSON.parse(localStorage.getItem('firtina_custom_prompts')) || [];
            } catch (e) {
                customPrompts = [];
            }
            try {
                budgetStack = JSON.parse(localStorage.getItem('firtina_budget_stack')) || [];
            } catch (e) {
                budgetStack = [];
            }
            """
        html = html[:init_studio_start] + clean_init_studio + html[init_studio_end:]
        print("Cleaned window.initStudio sample prompts and budget stack!")

with open(source_html, "w", encoding="utf-8") as f:
    f.write(html)

shutil.copy2(source_html, target_html)

# Sync across all project directories
sync_script = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\scratch\sync_index.py"
if os.path.exists(sync_script):
    os.system(f'python "{sync_script}"')

print("Step 1 Complete: Sample prompts, sample budget items, and sample grader text removed completely!")
