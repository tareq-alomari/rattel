import base64

# Minimal valid 1x1 Transparent PNG
transparent_png = base64.b64decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=")

# Minimal valid 1x1 Paper Color PNG (Cream/White)
paper_png = base64.b64decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==")

with open('assets/images/surah_header_pattern.png', 'wb') as f:
    f.write(transparent_png)

with open('assets/images/paper_texture.png', 'wb') as f:
    f.write(paper_png)

print("Created placeholder images")
