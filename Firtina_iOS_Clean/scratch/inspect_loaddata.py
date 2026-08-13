path = r'c:\Users\Elif\Desktop\Projelerim\Firtina AI App Store\Firtina_iOS_Clean\index.html'
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i in range(6475, 6545):
    if i < len(lines):
        print(f"{i+1}: {lines[i].rstrip()}")
