import subprocess
import os

edge_path = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
html_url = r"file:///c:/Users/Elif/Desktop/Projelerim/Firtina AI App Store/Firtina_iOS_Clean/index.html"
out_path = r"C:\Users\Elif\Downloads\gercek_anasayfa_ornek.png"

cmd = [
    edge_path,
    "--headless",
    "--disable-gpu",
    f"--screenshot={out_path}",
    "--window-size=1242,2688",
    html_url
]

print("Executing headless Edge screenshot capture...")
result = subprocess.run(cmd, capture_output=True, text=True)
print("Return code:", result.returncode)
print("Exists:", os.path.exists(out_path))

if os.path.exists(out_path):
    print("File size:", os.path.getsize(out_path), "bytes")
    print(f"Saved real screenshot to: {out_path}")
