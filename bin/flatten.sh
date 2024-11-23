#!/bin/bash

app_root=$(pwd)

app_name=$(basename "$app_root")

mkdir -p "$app_root"/tmp

# Find files in the app, config, db, spec directories, and markdown files in the root,
# excluding images in app/assets/images and CSS in app/assets/stylesheets
find "$app_root"/spec "$app_root"/*.md "$app_root"/*.rss "$app_root"/*.json \
  -type f \
  -print0 | while IFS= read -r -d '' file; do
    file_path="${file#$app_root/}"
    file_extension="${file##*.}"

    echo "$file_path:"

    if [[ "$file_extension" == "md" ]]; then
      # For Markdown files, don't add extra backticks
      cat "$file"
    else
      # For other files, add the code block with language
      echo "\`\`\`$file_extension"
      cat "$file"
      echo "\`\`\`"
    fi

    echo ""
done > "$app_root"/tmp/"$app_name"_flat_file.txt

# Print the path to the generated flat file
echo "Flat file created at: $app_root/tmp/$app_name"_flat_file.txt
