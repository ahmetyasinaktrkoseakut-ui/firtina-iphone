import os
from PIL import Image

upload_dir = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\.user_uploaded"

base_target_dirs = [
    r"C:\Users\Elif\Downloads\firtina_apple_guncel_gorseller",
    r"C:\Users\Elif\Desktop\firtina_apple_guncel_gorseller"
]

screenshots = [
    ("media_1785978352504.png", "1_splash_firtina_ai"),
    ("media_1785977595693.jpg", "2_prompt_skorer"),
    ("media_1785977595687.jpg", "3_butce_planlayici"),
    ("media_1785977595696.jpg", "4_prompt_defteri"),
    ("media_1785977595700.jpg", "5_akilli_asistan"),
    ("media_1785977595739.jpg", "6_prompt_kutuphanesi")
]

sizes = {
    "6.9 Inç iPhone (16-17 Pro Max)": ("6.9", 1320, 2868),
    "6.5 Inç iPhone (11-15 Pro Max)": ("6.5", 1242, 2688),
    "5.5 Inç iPhone (8 Plus)": ("5.5", 1242, 2208),
    "13 Inç iPad": ("ipad_13", 2048, 2732)
}

print("Processing all 6 store screenshots into device-specific subfolders...")

for base_dir in base_target_dirs:
    os.makedirs(base_dir, exist_ok=True)
    
    for folder_name, (prefix, tw, th) in sizes.items():
        folder_path = os.path.join(base_dir, folder_name)
        os.makedirs(folder_path, exist_ok=True)
        
        for filename, slug in screenshots:
            src_path = os.path.join(upload_dir, filename)
            if not os.path.exists(src_path):
                print(f"Warning: {src_path} not found!")
                continue
            
            img = Image.open(src_path).convert("RGB")
            resized_img = img.resize((tw, th), Image.Resampling.LANCZOS)
            
            out_filename = f"{prefix}_{slug}.png"
            dest_path = os.path.join(folder_path, out_filename)
            resized_img.save(dest_path, "PNG", quality=100)
            print(f"Saved: {dest_path}")

print("All 6 screenshots successfully saved into device folders in Downloads and Desktop!")
