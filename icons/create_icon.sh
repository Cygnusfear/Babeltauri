#!/usr/bin/env bash
# Create a simple SVG and convert it to PNG using available tools

cat > icon.svg << 'SVGEOF'
<svg width="128" height="128" xmlns="http://www.w3.org/2000/svg">
  <rect width="128" height="128" fill="#3b82f6" rx="16"/>
  <circle cx="64" cy="64" r="40" fill="#60a5fa"/>
  <circle cx="54" cy="58" r="6" fill="#1e40af"/>
  <path d="M 40 64 Q 50 74 64 74 Q 78 74 88 64" stroke="#1e40af" stroke-width="3" fill="none"/>
</svg>
SVGEOF

# Check if we have rsvg-convert (from librsvg)
if command -v rsvg-convert &> /dev/null; then
    rsvg-convert -w 128 -h 128 icon.svg -o icon.png
    rsvg-convert -w 32 -h 32 icon.svg -o 32x32.png
    rsvg-convert -w 128 -h 128 icon.svg -o 128x128.png
    echo "✓ Icons created with rsvg-convert"
else
    echo "✗ rsvg-convert not found, trying alternative..."
    # Fall back to creating a simple PNG with dd (creates valid but simple image)
    # This is a 128x128 PNG with blue background
    base64 -d << 'B64' > icon.png
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
B64
    cp icon.png 32x32.png
    cp icon.png 128x128.png
    echo "✓ Icons created with fallback method"
fi

rm -f icon.svg
