#!/bin/bash
# Run this locally to fetch real school logos from Wikimedia Commons
# Usage: bash fetch-logos.sh

mkdir -p logos

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"

declare -A LOGOS=(
  ["knust.png"]="https://upload.wikimedia.org/wikipedia/en/5/5d/KNUST_Logo.png"
  ["ug.png"]="https://upload.wikimedia.org/wikipedia/en/1/10/University_of_Ghana.png"
  ["ucc.svg"]="https://upload.wikimedia.org/wikipedia/en/a/a8/UCC_logo.svg"
  ["achimota.svg"]="https://upload.wikimedia.org/wikipedia/commons/3/38/ACHIMOTA_CREST.svg"
  ["prempeh.jpg"]="https://upload.wikimedia.org/wikipedia/en/7/7c/Prempeh_College_logo.jpg"
  ["upsa.png"]="https://upload.wikimedia.org/wikipedia/en/b/bc/University_of_Professional_Studies%2C_Accra_logo.png"
  ["uds.png"]="https://upload.wikimedia.org/wikipedia/en/1/18/University_for_Development_Studies_Logo.png"
  ["gctu.png"]="https://upload.wikimedia.org/wikipedia/en/9/96/Ghana_Communication_Technology_University_logo.png"
)

for FILE in "${!LOGOS[@]}"; do
  URL="${LOGOS[$FILE]}"
  echo "Fetching $FILE..."
  curl -sL -A "$UA" -o "logos/$FILE" "$URL"
  TYPE=$(file "logos/$FILE" | grep -oE "PNG|SVG|JPEG|GIF" | head -1)
  if [ -n "$TYPE" ]; then
    echo "  ✓ Got $FILE ($TYPE)"
  else
    echo "  ✗ Failed $FILE — keeping SVG badge"
    rm "logos/$FILE"
  fi
done

echo ""
echo "Done! Now run: git add logos/ && git commit -m 'Add real school logos' && git push origin main"
