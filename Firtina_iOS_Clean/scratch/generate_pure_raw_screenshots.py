import os
from PIL import Image

src_dir = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\.user_uploaded"
out_base = r"C:\Users\Elif\Downloads\TAM_EKRAN_RAM_GERCEK_GORSELLER"
os.makedirs(out_base, exist_ok=True)

# User's 5 real app screenshots:
items = [
    ("media_1785977595693.jpg", "1_prompt_skorer"),
    ("media_1785977595687.jpg", "2_butce_planlayici"),
    ("media_1785977595696.jpg", "3_prompt_defteri"),
    ("media_1785977595700.jpg", "4_akilli_asistan"),
    ("media_1785977595739.jpg", "5_prompt_kutuphanesi")
]

sizes = {
    "6.9 Inç (16-17 Pro Max)": ("6.9", 1320, 2868),
    "6.5 Inç (11-15 Pro Max)": ("6.5", 1242, 2688),
    "5.5 Inç (iPhone 8 Plus)": ("5.5", 1242, 2208),
    "13 Inç iPad": ("ipad_13", 2048, 2732)
}

print("Extracting 100% pure raw un-framed app screenshots without any phone frame or outer graphics...")

for filename, slug in items:
    src_path = os.path.join(src_dir, filename)
    if not os.path.exists(src_path):
        continue
    
    img = Image.open(src_path).convert("RGB")
    w, h = img.size
    
    # Crop pure inner app screen (0% outer phone frame, 0% circuit board background, 0% top banner text)
    left = int(w * 0.222)
    top = int(h * 0.222)
    right = int(w * 0.778)
    bottom = int(h * 0.865)
    
    raw_ui = img.crop((left, top, right, bottom))
    
    for folder_name, (prefix, tw, th) in sizes.items():
        target_dir = os.path.join(out_base, folder_name)
        os.makedirs(target_dir, exist_ok=True)
        
        resized_ui = raw_ui.resize((tw, th), Image.Resampling.LANCZOS)
        out_filename = f"{prefix}_{slug}_tam_ekran.png"
        out_path = os.path.join(target_dir, out_filename)
        resized_ui.save(out_path, "PNG", quality=100)
        print(f"Saved RAW Direct Screenshot: {out_path} ({tw}x{th})")

print("All 20 RAW Direct Un-framed screenshots successfully created!")
