import os
import shutil

src_downloads = r"C:\Users\Elif\Downloads"
base_target_dirs = [
    r"C:\Users\Elif\Downloads\firtina apple",
    r"C:\Users\Elif\Desktop\firtina apple"
]

folders = {
    "6.9": "6.9 Inç iPhone (16-17 Pro Max)",
    "6.5": "6.5 Inç iPhone (11-15 Pro Max)",
    "5.5": "5.5 Inç iPhone (8 Plus)",
    "ipad_13": "13 Inç iPad"
}

for base_dir in base_target_dirs:
    os.makedirs(base_dir, exist_ok=True)
    for prefix, folder_name in folders.items():
        folder_path = os.path.join(base_dir, folder_name)
        os.makedirs(folder_path, exist_ok=True)
        
        # Copy corresponding files
        for filename in os.listdir(src_downloads):
            if filename.startswith(prefix + "_") and filename.endswith(".png"):
                src_file = os.path.join(src_downloads, filename)
                dest_file = os.path.join(folder_path, filename)
                shutil.copy2(src_file, dest_file)
                print(f"Copied {filename} -> {folder_path}")

print("Successfully organized all screenshot files into device folders under 'firtina apple'!")
