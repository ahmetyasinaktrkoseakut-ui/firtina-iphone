import os
from PIL import Image, ImageDraw, ImageFont

downloads_dir = r"C:\Users\Elif\Downloads"
os.makedirs(downloads_dir, exist_ok=True)

# Standard resolutions for 6.9", 6.5", 5.5", and 13" iPad
target_sizes = {
    "6.9": (1320, 2868),
    "6.5": (1242, 2688),
    "5.5": (1242, 2208),
    "ipad_13": (2048, 2732)
}

# We will generate 4 clean, real direct screenshots matching the exact live app UI (Image 3)
# 1. Atölye - Prompt Skorer
# 2. Atölye - Bütçe Planlayıcı
# 3. Promptlar - Şablonlar
# 4. ASİSTAN - Canlı Sohbet

# Let's inspect source images available in workspace
ipad_real_img_path = r"C:\Users\Elif\.gemini\antigravity\brain\38674887-721a-4947-af24-6a3e1e25e45f\.user_uploaded\media__1785849898437.png"

print("Generating 4 clean direct screenshots matching the real app navigation bar...")
