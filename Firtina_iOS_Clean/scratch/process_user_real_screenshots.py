import os
from PIL import Image, ImageDraw, ImageFont

# Source real screenshots uploaded by the user:
# 1. Prompt Skorer: media_1785973808864.png
# 2. Bütçe Planlayıcı: media_1785973829006.png
# 3. Prompt Defteri: media_1785973855620.png
# 4. Prompt Kütüphanesi: media_1785973873352.png
# 5. Akıllı Asistan: media_1785973946569.png

upload_dir = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\.user_uploaded"
downloads_dir = r"C:\Users\Elif\Downloads"
os.makedirs(downloads_dir, exist_ok=True)

screenshots = [
    ("media_1785973808864.png", "PROMPTLARINIZI ANALİZ EDİN VE DOĞRU ÇIKTIYI ALIN", "1_prompt_skorer"),
    ("media_1785973829006.png", "ABONELİK BÜTÇENİZİ YÖNETİN VE TASARRUF EDİN", "2_butce_planlayici"),
    ("media_1785973855620.png", "KİŞİSEL PROMPTLARINIZI GÜVENLE KAYDEDİN", "3_prompt_defteri"),
    ("media_1785973873352.png", "HAZIR YAPAY ZEKA ŞABLON KÜTÜPHANESİ", "4_prompt_kutuphanesi"),
    ("media_1785973946569.png", "AKILLI AI ASİSTANINIZ İLE ANINDA SOHBET EDİN", "5_akilli_asistan")
]

# Exact App Store required pixel resolutions (width, height)
sizes = {
    "6.9": (1320, 2868),
    "6.5": (1242, 2688),
    "5.5": (1242, 2208),
    "ipad_13": (2048, 2732)
}

print("Starting generation of 100% REAL screenshots inside sleek mobile frames for all App Store sizes...")

for img_name, title_text, base_slug in screenshots:
    img_path = os.path.join(upload_dir, img_name)
    if not os.path.exists(img_path):
        print(f"Error: {img_path} not found!")
        continue
    
    real_ui_img = Image.open(img_path).convert("RGBA")
    
    # Generate frame composition for each target size
    for size_label, (canvas_w, canvas_h) in sizes.items():
        # Create dark slate studio background canvas (#0b1120 with circuit glow effect)
        canvas = Image.new("RGBA", (canvas_w, canvas_h), (11, 17, 32, 255))
        draw = ImageDraw.Draw(canvas)
        
        # Add subtle top glowing title header text area
        # We place phone frame in middle-lower area, scaled cleanly
        padding_top = int(canvas_h * 0.15)
        phone_w = int(canvas_w * 0.85)
        phone_h = int(canvas_h * 0.78)
        
        # Resize real UI image into phone frame
        resized_ui = real_ui_img.resize((phone_w, phone_h), Image.Resampling.LANCZOS)
        
        # Calculate centering offset
        offset_x = (canvas_w - phone_w) // 2
        offset_y = padding_top + (canvas_h - padding_top - phone_h) // 2
        
        # Paste real screenshot
        canvas.paste(resized_ui, (offset_x, offset_y), resized_ui if resized_ui.mode == 'RGBA' else None)
        
        # Draw elegant outer phone border rounded rectangle
        border_color = (56, 189, 248, 180) # Cyan glowing border
        draw.rounded_rectangle(
            [offset_x - 4, offset_y - 4, offset_x + phone_w + 4, offset_y + phone_h + 4],
            radius=24,
            outline=border_color,
            width=6
        )
        
        # Render Title text at top
        try:
            font = ImageFont.truetype("arial.ttf", int(canvas_w * 0.042))
        except:
            font = ImageFont.load_default()
            
        # Draw title centered
        bbox = draw.textbbox((0, 0), title_text, font=font)
        text_w = bbox[2] - bbox[0]
        text_x = (canvas_w - text_w) // 2
        text_y = int(canvas_h * 0.06)
        
        # Draw text shadow & text
        draw.text((text_x + 2, text_y + 2), title_text, fill=(0, 0, 0, 200), font=font)
        draw.text((text_x, text_y), title_text, fill=(240, 249, 255, 255), font=font)
        
        # Save output PNG file
        out_filename = f"{size_label}_{base_slug}.png"
        out_path = os.path.join(downloads_dir, out_filename)
        canvas.convert("RGB").save(out_path, "PNG", quality=100)
        print(f"Generated: {out_filename} ({canvas_w}x{canvas_h})")

print("All screenshots successfully created and saved to Downloads!")
