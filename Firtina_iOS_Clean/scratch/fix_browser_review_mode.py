import os

html_path = r"c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html"

with open(html_path, "r", encoding="utf-8") as f:
    html = f.read()

# Update applyPlatformReviewMode so that if isIOSReviewMode is true, Keşfet is hidden unconditionally
old_func = """function applyPlatformReviewMode() {
            const homeTab = document.getElementById('navItemHome');
            if (isiOSDevice && isIOSReviewMode) {
                if (homeTab) homeTab.style.display = 'none';
            } else {
                if (homeTab) homeTab.style.display = 'flex';
            }
        }"""

new_func = """function applyPlatformReviewMode() {
            const homeTab = document.getElementById('navItemHome');
            if (isIOSReviewMode) {
                if (homeTab) homeTab.style.display = 'none';
            } else {
                if (homeTab) homeTab.style.display = 'flex';
            }
        }"""

if old_func in html:
    html = html.replace(old_func, new_func)
    print("Updated applyPlatformReviewMode to hide Keşfet unconditionally when isIOSReviewMode is true.")
else:
    # Regex fallback replacement
    import re
    html = re.sub(
        r'if\s*\(\s*isiOSDevice\s*&&\s*isIOSReviewMode\s*\)',
        'if (isIOSReviewMode)',
        html
    )
    print("Replaced isiOSDevice check with direct isIOSReviewMode check.")

with open(html_path, "w", encoding="utf-8") as f:
    f.write(html)

print("Saved updated index.html.")
