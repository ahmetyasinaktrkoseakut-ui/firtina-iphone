import os
from PIL import Image

src_img_path = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\.user_uploaded\media_1785978352504.png"

# Target 6.9" resolution
target_w, target_h = (1320, 2868)

img = Image.open(src_img_path).convert("RGB")
resized_img = img.resize((target_w, target_h), Image.Resampling.LANCZOS)

target_locations = [
    r"C:\Users\Elif\Downloads\6.9_0_splash_firtina_ai.png",
    r"C:\Users\Elif\Downloads\firtina apple\6.9 Inç iPhone (16-17 Pro Max)\6.9_0_splash_firtina_ai.png",
    r"C:\Users\Elif\Desktop\firtina apple\6.9 Inç iPhone (16-17 Pro Max)\6.9_0_splash_firtina_ai.png"
]

for dest_path in target_locations:
    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    resized_img.save(dest_path, "PNG", quality=100)
    print(f"Saved 6.9 splash image to: {dest_path}")

print("6.9 Splash image successfully saved to all target folders!")
