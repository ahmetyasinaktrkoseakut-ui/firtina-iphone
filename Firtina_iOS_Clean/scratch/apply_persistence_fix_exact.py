import os
import re
import shutil

source_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html"
target_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI\index.html"

with open(source_html, "r", encoding="utf-8") as f:
    html = f.read()

# 1. Update window.initStudio logic for customPrompts
old_custom_check = "if (customPrompts.length === 0) {"
new_custom_check = "const promptsSeeded = localStorage.getItem('firtina_prompts_seeded');\n            if (!promptsSeeded && customPrompts.length === 0) {"

if old_custom_check in html:
    html = html.replace(old_custom_check, new_custom_check, 1)
    # Add localStorage.setItem('firtina_prompts_seeded', 'true'); after JSON.stringify(customPrompts)
    html = html.replace("localStorage.setItem('firtina_custom_prompts', JSON.stringify(customPrompts));", "localStorage.setItem('firtina_custom_prompts', JSON.stringify(customPrompts)); localStorage.setItem('firtina_prompts_seeded', 'true');", 1)

# 2. Update window.initStudio logic for budgetStack
old_budget_check = "if (budgetStack.length === 0) {"
new_budget_check = "const budgetSeeded = localStorage.getItem('firtina_budget_seeded');\n            if (!budgetSeeded && budgetStack.length === 0) {"

if old_budget_check in html:
    html = html.replace(old_budget_check, new_budget_check, 1)
    html = html.replace("localStorage.setItem('firtina_budget_stack', JSON.stringify(budgetStack));", "localStorage.setItem('firtina_budget_stack', JSON.stringify(budgetStack)); localStorage.setItem('firtina_budget_seeded', 'true');", 1)

# 3. Update DOMContentLoaded graderInput logic so cleared text stays cleared
old_grader_check = "if (graderIn && !graderIn.value.trim()) {"
new_grader_check = """if (graderIn) {
                const savedGraderVal = localStorage.getItem('firtina_grader_user_val');
                const isCleared = localStorage.getItem('firtina_grader_user_cleared');
                if (savedGraderVal !== null) { graderIn.value = savedGraderVal; }
                else if (!isCleared && !graderIn.value.trim()) {"""

if old_grader_check in html:
    html = html.replace(old_grader_check, new_grader_check, 1)
    # Add input event listener to remember clears
    grader_event_listener = """graderIn.addEventListener('input', () => {
                    const val = graderIn.value;
                    localStorage.setItem('firtina_grader_user_val', val);
                    if (!val.trim()) { localStorage.setItem('firtina_grader_user_cleared', 'true'); }
                    else { localStorage.removeItem('firtina_grader_user_cleared'); }
                });"""
    html = html.replace("gradePrompt();\n                }, 100);", "gradePrompt();\n                }, 100);\n            }\n            " + grader_event_listener, 1)

with open(source_html, "w", encoding="utf-8") as f:
    f.write(html)

shutil.copy2(source_html, target_html)

# Sync across all projects (including Android!)
sync_script = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\scratch\sync_index.py"
if os.path.exists(sync_script):
    os.system(f'python "{sync_script}"')

print("Applied exact persistence fix to iOS & Android index.html!")
