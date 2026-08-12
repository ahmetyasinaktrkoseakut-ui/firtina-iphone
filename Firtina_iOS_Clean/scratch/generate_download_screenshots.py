import os
from PIL import Image

src_image_path = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\asistan_exact_with_prompt_skorer_bg_1785849980295.jpg"
downloads_dir = r"C:\Users\Elif\Downloads"

os.makedirs(downloads_dir, exist_ok=True)

img = Image.open(src_image_path)

# Standard App Store screenshot resolutions (width, height)
sizes = {
    "6.9_asistan_ekran_goruntusu.png": (1320, 2868),
    "6.5_asistan_ekran_goruntusu.png": (1242, 2688),
    "5.5_asistan_ekran_goruntusu.png": (1242, 2208),
    "ipad_13_asistan_ekran_goruntusu.png": (2048, 2732)
}

for filename, (target_w, target_h) in sizes.items():
    # Maintain aspect ratio and center-fit / scale
    resized_img = img.resize((target_w, target_h), Image.Resampling.LANCZOS)
    output_path = os.path.join(downloads_dir, filename)
    resized_img.save(output_path, "PNG", quality=100)
    print(f"Saved: {output_path} ({target_w}x{target_h})")

print("All 4 App Store screenshot sizes generated and saved to Downloads folder.")
