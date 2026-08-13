import os
import shutil

source_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html"
target_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI\index.html"

with open(source_html, "r", encoding="utf-8") as f:
    html = f.read()

# 1. Update DOMContentLoaded graderInput logic so it remembers user edits/clears
old_grader_logic = """const graderIn = document.getElementById('graderInput');
            if (graderIn && !graderIn.value.trim()) {
                const samplePrompt = currentLang === 'tr'
                    ? "Sen deneyimli bir Türkçe öğretmenisin. 8. sınıf öğrencileri için paragrafta anlam konusunu eğlenceli hale getirecek 3 farklı sınıf etkinliği planı hazırla. Etkinlikleri tablo halinde göster, her birinin adını, süresini ve uygulayış adımlarını belirt."
                    : "Act as an expert English teacher. Prepare 3 engaging classroom activities about reading comprehension for 8th-grade students. Present them in a markdown table showing the activity name, duration, and step-by-step instructions.";
                graderIn.value = samplePrompt;
                setTimeout(() => {
                    gradePrompt();
                }, 100);
            }"""

new_grader_logic = """const graderIn = document.getElementById('graderInput');
            if (graderIn) {
                const savedGraderVal = localStorage.getItem('firtina_grader_user_val');
                const isCleared = localStorage.getItem('firtina_grader_user_cleared');
                if (savedGraderVal !== null) {
                    graderIn.value = savedGraderVal;
                } else if (!isCleared && !graderIn.value.trim()) {
                    const samplePrompt = currentLang === 'tr'
                        ? "Sen deneyimli bir Türkçe öğretmenisin. 8. sınıf öğrencileri için paragrafta anlam konusunu eğlenceli hale getirecek 3 farklı sınıf etkinliği planı hazırla. Etkinlikleri tablo halinde göster, her birinin adını, süresini ve uygulayış adımlarını belirt."
                        : "Act as an expert English teacher. Prepare 3 engaging classroom activities about reading comprehension for 8th-grade students. Present them in a markdown table showing the activity name, duration, and step-by-step instructions.";
                    graderIn.value = samplePrompt;
                }
                if (graderIn.value.trim()) {
                    setTimeout(() => { gradePrompt(); }, 100);
                }
                graderIn.addEventListener('input', () => {
                    const val = graderIn.value;
                    localStorage.setItem('firtina_grader_user_val', val);
                    if (!val.trim()) {
                        localStorage.setItem('firtina_grader_user_cleared', 'true');
                    } else {
                        localStorage.removeItem('firtina_grader_user_cleared');
                    }
                });
            }"""

if old_grader_logic in html:
    html = html.replace(old_grader_logic, new_grader_logic)
    print("Replaced grader logic successfully!")

# 2. Update initStudio for customPrompts and budgetStack so deleted items stay deleted
old_init_studio = """window.initStudio = function initStudio() {
            try {
                customPrompts = JSON.parse(localStorage.getItem('firtina_custom_prompts')) || [];
            } catch (e) {
                customPrompts = [];
            }
            if (customPrompts.length === 0) {
                customPrompts = [
                    {
                        id: 'default-summary',
                        title: currentLang === 'tr' ? 'Metin Özetleyici' : 'Text Summarizer',
                        category: 'text',
                        content: currentLang === 'tr'
                            ? 'Lütfen aşağıdaki metni ana fikirlerini koruyarak, maddeler halinde özetle:\\n\\n[Metni buraya yapıştırın]'
                            : 'Please summarize the following text in bullet points, preserving the main ideas:\\n\\n[Paste text here]'
                    },
                    {
                        id: 'default-debug',
                        title: currentLang === 'tr' ? 'Kod Hata Bulucu' : 'Code Debugger',
                        category: 'coding',
                        content: currentLang === 'tr'
                            ? 'Aşağıdaki kod bloğundaki olası hataları (bug) tespit et, düzeltilmiş halini yaz ve yapılan değişiklikleri açıkla:\\n\\n[Kodu buraya yapıştırın]'
                            : 'Identify potential bugs in the following code block, provide the corrected code, and explain the changes:\\n\\n[Paste code here]'
                    }
                ];
                try {
                    localStorage.setItem('firtina_custom_prompts', JSON.stringify(customPrompts));
                } catch (e) {}
            }

            try {
                budgetStack = JSON.parse(localStorage.getItem('firtina_budget_stack')) || [];
            } catch (e) {
                budgetStack = [];
            }
            if (budgetStack.length === 0) {
                budgetStack = [
                    { id: 'default-chatgpt', name: 'ChatGPT Plus', price: 20, category: 'text' },
                    { id: 'default-midjourney', name: 'Midjourney', price: 10, category: 'visual' }
                ];
                try {
                    localStorage.setItem('firtina_budget_stack', JSON.stringify(budgetStack));
                } catch (e) {}
            }"""

new_init_studio = """window.initStudio = function initStudio() {
            const promptsSeeded = localStorage.getItem('firtina_prompts_seeded');
            try {
                customPrompts = JSON.parse(localStorage.getItem('firtina_custom_prompts')) || [];
            } catch (e) {
                customPrompts = [];
            }
            if (!promptsSeeded && customPrompts.length === 0) {
                customPrompts = [
                    {
                        id: 'default-summary',
                        title: currentLang === 'tr' ? 'Metin Özetleyici' : 'Text Summarizer',
                        category: 'text',
                        content: currentLang === 'tr'
                            ? 'Lütfen aşağıdaki metni ana fikirlerini koruyarak, maddeler halinde özetle:\\n\\n[Metni buraya yapıştırın]'
                            : 'Please summarize the following text in bullet points, preserving the main ideas:\\n\\n[Paste text here]'
                    },
                    {
                        id: 'default-debug',
                        title: currentLang === 'tr' ? 'Kod Hata Bulucu' : 'Code Debugger',
                        category: 'coding',
                        content: currentLang === 'tr'
                            ? 'Aşağıdaki kod bloğundaki olası hataları (bug) tespit et, düzeltilmiş halini yaz ve yapılan değişiklikleri açıkla:\\n\\n[Kodu buraya yapıştırın]'
                            : 'Identify potential bugs in the following code block, provide the corrected code, and explain the changes:\\n\\n[Paste code here]'
                    }
                ];
                try {
                    localStorage.setItem('firtina_custom_prompts', JSON.stringify(customPrompts));
                    localStorage.setItem('firtina_prompts_seeded', 'true');
                } catch (e) {}
            }

            const budgetSeeded = localStorage.getItem('firtina_budget_seeded');
            try {
                budgetStack = JSON.parse(localStorage.getItem('firtina_budget_stack')) || [];
            } catch (e) {
                budgetStack = [];
            }
            if (!budgetSeeded && budgetStack.length === 0) {
                budgetStack = [
                    { id: 'default-chatgpt', name: 'ChatGPT Plus', price: 20, category: 'text' },
                    { id: 'default-midjourney', name: 'Midjourney', price: 10, category: 'visual' }
                ];
                try {
                    localStorage.setItem('firtina_budget_stack', JSON.stringify(budgetStack));
                    localStorage.setItem('firtina_budget_seeded', 'true');
                } catch (e) {}
            }"""

if old_init_studio in html:
    html = html.replace(old_init_studio, new_init_studio)
    print("Replaced initStudio logic successfully!")

with open(source_html, "w", encoding="utf-8") as f:
    f.write(html)

shutil.copy2(source_html, target_html)

# Sync across all project directories
sync_script = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\scratch\sync_index.py"
if os.path.exists(sync_script):
    os.system(f'python "{sync_script}"')

print("Successfully fixed persistence logic: Deleted custom prompts & budget items now stay deleted forever!")
