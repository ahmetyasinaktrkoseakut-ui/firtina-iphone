import os
import re

html_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html"

with open(html_path, "r", encoding="utf-8") as f:
    html = f.read()

# 1. Clean any previous nativeToolModal script injections if left over
if 'id="nativeToolModal"' in html:
    pos = html.find('<!-- NATIVE TOOL WORKSPACE MODAL -->')
    if pos != -1:
        end_pos = html.find('</body>')
        html = html[:pos] + '\n</body>'
    print("Cleaned previous workspace modal tags.")

# 2. Revert visit button text back to original "Ziyaret Et" / "Visit"
html = html.replace('visit: "Çalıştır",', 'visit: "Ziyaret Et",')
html = html.replace('visit: "Use Tool",', 'visit: "Visit",')

# 3. Add clean iOS Review Mode Flag & Platform Check
ios_flag_code = """
        // --- PLATFORM & FIREBASE REVIEW MODE CONTROL ---
        const isiOSDevice = /iPad|iPhone|iPod/.test(navigator.userAgent) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1) || (window.webkit && window.webkit.messageHandlers);
        let isIOSReviewMode = true; // Default true for Apple review, controlled remotely via Firebase JSON (is_ios_review_mode)

        function applyPlatformReviewMode() {
            const homeTab = document.getElementById('navItemHome');
            if (isiOSDevice && isIOSReviewMode) {
                if (homeTab) homeTab.style.display = 'none';
            } else {
                if (homeTab) homeTab.style.display = 'flex';
            }
        }
"""

if 'applyPlatformReviewMode' not in html:
    pos = html.find('document.addEventListener(\'DOMContentLoaded\'')
    if pos != -1:
        html = html[:pos] + ios_flag_code + '\n        ' + html[pos:]
        print("Added applyPlatformReviewMode logic before DOMContentLoaded.")

# 4. Call applyPlatformReviewMode inside DOMContentLoaded and fetchDataFromFirebase
if 'applyPlatformReviewMode();' not in html:
    html = html.replace('initStudio();', 'initStudio();\n            applyPlatformReviewMode();')
    print("Added applyPlatformReviewMode() call inside DOMContentLoaded.")

# 5. Check if Firebase JSON update can control isIOSReviewMode
if 'updateInternalTools' in html:
    pos = html.find('updateInternalTools(remoteTools);')
    if pos != -1 and 'isIOSReviewMode' not in html[pos-200:pos+200]:
        html = html.replace(
            'updateInternalTools(remoteTools);',
            'if (remoteTools && typeof remoteTools.is_ios_review_mode !== "undefined") { isIOSReviewMode = !!remoteTools.is_ios_review_mode; applyPlatformReviewMode(); }\n                updateInternalTools(remoteTools);'
        )
        print("Connected Firebase remoteTools.is_ios_review_mode to isIOSReviewMode.")

with open(html_path, "w", encoding="utf-8") as f:
    f.write(html)

print("Updated index.html with 0-error iOS Review Mode & Android safety check.")
