from PIL import Image, ImageDraw

img = Image.new('RGBA', (128, 128), (59, 130, 246, 255))
draw = ImageDraw.Draw(img)
draw.ellipse([16, 16, 112, 112], fill=(255, 255, 255, 255))
img.save('icons/icon.png')

for size in [32, 128]:
    resized = img.resize((size, size), Image.LANCZOS)
    resized.save(f'icons/{size}x{size}.png')

print("Icons generated!")
