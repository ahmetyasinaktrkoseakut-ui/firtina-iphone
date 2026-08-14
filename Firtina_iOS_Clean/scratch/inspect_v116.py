import subprocess
import re

res = subprocess.run(['git', 'show', 'fcec0ed:Firtina_iOS_Clean/index.html'], cwd=r'c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store', capture_output=True)
html116 = res.stdout.decode('utf-8', errors='ignore')

print("=== v1.16 (fcec0ed) NAV TEXT & TAB CHECK ===")
for i, line in enumerate(html116.split('\n')):
    if any(k in line for k in ['navTextHome', 'Keşfet', 'Ana Sayfa', 'navItemHome', 'returnToCategories']):
        print(f"{i+1}: {line.strip()}")
