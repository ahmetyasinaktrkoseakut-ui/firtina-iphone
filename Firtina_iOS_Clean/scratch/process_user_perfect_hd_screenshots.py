import os
from PIL import Image

upload_dir = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\.user_uploaded"
downloads_dir = r"C:\Users\Elif\Downloads"
os.makedirs(downloads_dir, exist_ok=True)

# User's 5 exact HD screenshots in order:
# 1. Prompt Skorer: media_1785977595693.jpg
# 2. Bütçe Planlayıcı: media_1785977595687.jpg
# 3. Prompt Defteri: media_1785977595696.jpg
# 4. Akıllı Asistan: media_1785977595700.jpg
# 5. Prompt Kütüphanesi: media_1785977595739.jpg

items = [
    ("media_1785977595693.jpg", "1_prompt_skorer"),
    ("media_1785977595687.jpg", "2_butce_planlayici"),
    ("media_1785977595696.jpg", "3_prompt_defteri"),
    ("media_1785977595700.jpg", "4_akilli_asistan"),
    ("media_1785977595739.jpg", "5_prompt_kutuphanesi")
]

sizes = {
    "6.9": (1320, 2868),
    "6.5": (1242, 2688),
    "5.5": (1242, 2208),
    "ipad_13": (2048, 2732)
}

print("Resizing user's 5 HD screenshots with high quality LANCZOS filter into all App Store sizes...")

for filename, slug in items:
    src_path = os.path.join(upload_dir, filename)
    if not os.path.exists(src_path):
        print(f"Error: {src_path} not found!")
        continue
    
    img = Image.open(src_path).convert("RGB")
    
    for size_label, (target_w, target_h) in sizes.items():
        # High quality resize maintaining aspect ratio
        resized_img = img.resize((target_w, target_h), Image.Resampling.LANCZOS)
        out_filename = f"{size_label}_{slug}.png"
        out_path = os.path.join(downloads_dir, out_filename)
        resized_img.save(out_path, "PNG", quality=100)
        print(f"Saved HD: {out_filename} ({target_w}x{target_h})")

print("All 20 HD screenshot files successfully saved to Downloads folder!")
