from PIL import Image, ImageDraw
import colorsys

def generate_rainbow_gradient(size: int, output_path: str = "color_picker_rounded_aa.png"):
    margin = 5
    inner_size = size - 2 * margin
    radius = 10

    # Supersampling factor for anti-aliasing
    ss = 4
    ss_size = size * ss
    ss_radius = radius * ss
    ss_margin = margin * ss
    ss_inner = ss_size - 2 * ss_margin

    # Create high-res mask for AA rounded corners
    mask_hr = Image.new("L", (ss_size, ss_size), 0)
    draw = ImageDraw.Draw(mask_hr)
    draw.rounded_rectangle(
        [(0, 0), (ss_size - 1, ss_size - 1)],
        radius=ss_radius,
        fill=255
    )
    # Downsample with antialiasing
    mask = mask_hr.resize((size, size), Image.LANCZOS)

    # Create base image (RGBA)
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    pixels = img.load()

    # Fill center gradient (non-ss, normal resolution)
    for x in range(inner_size):
        hue = x / inner_size
        for y in range(inner_size):
            sat = 1.0 - (y / inner_size)
            r, g, b = colorsys.hsv_to_rgb(hue, sat, 1.0)
            pixels[x + margin, y + margin] = (int(r * 255), int(g * 255), int(b * 255), 255)

    # Extend edges into margin
    for x in range(margin, size - margin):
        for y in range(margin):
            pixels[x, y] = pixels[x, margin]                         # Top
            pixels[x, size - 1 - y] = pixels[x, size - 1 - margin]   # Bottom

    for y in range(size):
        for x in range(margin):
            pixels[x, y] = pixels[margin, y]                         # Left
            pixels[size - 1 - x, y] = pixels[size - 1 - margin, y]   # Right

    # Apply anti-aliased mask as alpha channel
    img.putalpha(mask)

    img.save(output_path)
    print(f"Saved with smooth rounded corners: {output_path}")

# Run example
generate_rainbow_gradient(512)

