#!/bin/bash
find lib test -name "*.dart" -type f | while read file; do
  sed -i 's/package:travis/package:travis/g' "$file"
done
echo "All imports updated"
