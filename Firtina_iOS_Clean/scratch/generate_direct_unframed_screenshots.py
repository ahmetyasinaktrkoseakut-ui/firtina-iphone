import os
from PIL import Image

upload_dir = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\.user_uploaded"
downloads_dir = r"C:\Users\Elif\Downloads\DOGRU_DIREKT_EKRANLAR"
os.makedirs(downloads_dir, exist_ok=True)

# User's 5 exact HD screenshots:
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

print("Cropping direct inner screen area (without outer phone frames/banners)...")

for filename, slug in items:
    src_path = os.path.join(upload_dir, filename)
    if not os.path.exists(src_path):
        continue
    
    img = Image.open(src_path).convert("RGB")
    w, h = img.size
    
    # Bounding box of inner phone screen inside mockup frame:
    # Top title takes about 20%, phone bezel takes about 2-3% padding
    # Bounding box: left=0.21*w, top=0.20*h, right=0.79*w, bottom=0.88*h
    left = int(w * 0.205)
    top = int(h * 0.200)
    right = int(w * 0.795)
    bottom = int(h * 0.885)
    
    inner_screen = img.crop((left, top, right, bottom))
    
    for size_label, (target_w, target_h) in sizes.items():
        # High quality resize maintaining aspect ratio
        resized_img = inner_screen.resize((target_w, target_h), Image.Resampling.LANCZOS)
        folder = os.path.join(downloads_dir, size_label)
        os.makedirs(folder, exist_ok=True)
        out_filename = f"{size_label}_{slug}_direkt.png"
        out_path = os.path.join(folder, out_filename)
        resized_img.save(out_path, "PNG", quality=100)
        print(f"Saved direct un-framed screenshot: {out_path}")

print("All direct un-framed screenshots generated!")
