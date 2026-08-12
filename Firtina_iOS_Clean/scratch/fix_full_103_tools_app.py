import os
import shutil

source_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html"
target_html = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI\index.html"
pbxproj_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_AI.xcodeproj\project.pbxproj"

with open(source_html, "r", encoding="utf-8") as f:
    html = f.read()

# 1. Set isIOSReviewMode = false default
html = html.replace("let isIOSReviewMode = true;", "let isIOSReviewMode = false;")

# 2. Fix bottom nav bar HTML: Place Keşfet (navItemHome) first as active tab #1
old_nav_pattern = """<nav id="bottomNav" class="bottom-nav flex hidden" style="display: none;">
        <!-- Atölye -->
        <div id="navItemStudio" onclick="showStudioScreen()" class="nav-item active">
            <svg class="w-5 h-5 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
            </svg>
            <span id="navTextStudio" class="text-xs font-medium">Atölye</span>
        </div>

        <!-- Promptlar -->
        <div id="navItemPrompts" onclick="showPromptsScreen()" class="nav-item">
            <svg class="w-5 h-5 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
            </svg>
            <span id="navTextPrompts" class="text-xs font-medium">Promptlar</span>
        </div>

        <!-- Asistan Butonu (Orta) -->
        <div class="nav-item assistant-btn-container" onclick="openAssistantModal()">
            <button class="assistant-floating-btn shadow-lg transform active:scale-95 transition-all duration-200" title="Akıllı AI Asistanı">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                </svg>
            </button>
            <span id="navTextAssistant" class="text-[10px] font-bold text-slate-300 tracking-wider uppercase mt-1">ASİSTAN</span>
        </div>

        <!-- Favoriler -->
        <div id="navItemFavorites" onclick="setCategory('favorites')" class="nav-item">
            <svg class="w-5 h-5 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path>
            </svg>
            <span id="navTextFavorites" class="text-xs font-medium">Favoriler</span>
        </div>

        <!-- Keşfet / 103 Araçlar -->
        <div id="navItemHome" onclick="returnToCategories()" class="nav-item">
            <svg class="w-5 h-5 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"></path>
            </svg>
            <span id="navTextHome" class="text-xs font-medium">Keşfet</span>
        </div>
    </nav>"""

new_nav_pattern = """<nav id="bottomNav" class="bottom-nav flex" style="display: flex;">
        <!-- Keşfet / 103 Araçlar (Tab 1) -->
        <div id="navItemHome" onclick="returnToCategories()" class="nav-item active">
            <svg class="w-5 h-5 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"></path>
            </svg>
            <span id="navTextHome" class="text-xs font-medium">Keşfet</span>
        </div>

        <!-- Atölye -->
        <div id="navItemStudio" onclick="showStudioScreen()" class="nav-item">
            <svg class="w-5 h-5 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
            </svg>
            <span id="navTextStudio" class="text-xs font-medium">Atölye</span>
        </div>

        <!-- Promptlar -->
        <div id="navItemPrompts" onclick="showPromptsScreen()" class="nav-item">
            <svg class="w-5 h-5 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
            </svg>
            <span id="navTextPrompts" class="text-xs font-medium">Promptlar</span>
        </div>

        <!-- Asistan Butonu (Orta) -->
        <div class="nav-item assistant-btn-container" onclick="openAssistantModal()">
            <button class="assistant-floating-btn shadow-lg transform active:scale-95 transition-all duration-200" title="Akıllı AI Asistanı">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                </svg>
            </button>
            <span id="navTextAssistant" class="text-[10px] font-bold text-slate-300 tracking-wider uppercase mt-1">ASİSTAN</span>
        </div>

        <!-- Favoriler -->
        <div id="navItemFavorites" onclick="setCategory('favorites')" class="nav-item">
            <svg class="w-5 h-5 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path>
            </svg>
            <span id="navTextFavorites" class="text-xs font-medium">Favoriler</span>
        </div>
    </nav>"""

if old_nav_pattern in html:
    html = html.replace(old_nav_pattern, new_nav_pattern)
    print("Replaced bottom nav pattern successfully!")
else:
    print("Warning: old nav pattern not found exactly, doing regex replacement...")
    # Replace display:none on bottomNav
    html = html.replace('id="bottomNav" class="bottom-nav flex hidden" style="display: none;"', 'id="bottomNav" class="bottom-nav flex" style="display: flex;"')

# 3. Fix landing view: Show 103 tools category grid on launch by default
html = html.replace("showStudioScreen();", "showCategoryGrid();")

with open(source_html, "w", encoding="utf-8") as f:
    f.write(html)

shutil.copy2(source_html, target_html)

# 4. Update pbxproj to MARKETING_VERSION = 1.16 and BUILD = 26
with open(pbxproj_path, "r", encoding="utf-8") as f:
    pbx = f.read()

pbx = pbx.replace("CURRENT_PROJECT_VERSION = 25;", "CURRENT_PROJECT_VERSION = 26;")
pbx = pbx.replace("CURRENT_PROJECT_VERSION = 24;", "CURRENT_PROJECT_VERSION = 26;")

with open(pbxproj_path, "w", encoding="utf-8") as f:
    f.write(pbx)

# Sync backups
sync_script = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\scratch\sync_index.py"
if os.path.exists(sync_script):
    os.system(f'python "{sync_script}"')

print("Updated index.html & pbxproj: Keşfet (103 AI tools) tab is now Tab #1 on bottom navigation, active by default on launch! Build set to 26!")
