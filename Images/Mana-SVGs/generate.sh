shopt -s nullglob
array=(*.svg)

for i in "${!array[@]}"; do 
  filename="${array[$i]}"
  filename="${filename%.*}"
  /Applications/Inkscape.app/Contents/Resources/bin/inkscape --export-png "$(pwd)/cost_14/cost_14_${filename}.png" -h 14 "$(pwd)/${filename}.svg"
  /Applications/Inkscape.app/Contents/Resources/bin/inkscape --export-png "$(pwd)/cost_14/cost_14_${filename}@2x.png" -h 28 "$(pwd)/${filename}.svg"
  /Applications/Inkscape.app/Contents/Resources/bin/inkscape --export-png "$(pwd)/cost_14/cost_14_${filename}@3x.png" -h 42 "$(pwd)/${filename}.svg"

  /Applications/Inkscape.app/Contents/Resources/bin/inkscape --export-png "$(pwd)/cost_10/cost_10_${filename}.png" -h 10 "$(pwd)/${filename}.svg"
  /Applications/Inkscape.app/Contents/Resources/bin/inkscape --export-png "$(pwd)/cost_10/cost_10_${filename}@2x.png" -h 20 "$(pwd)/${filename}.svg"
  /Applications/Inkscape.app/Contents/Resources/bin/inkscape --export-png "$(pwd)/cost_10/cost_10_${filename}@3x.png" -h 30 "$(pwd)/${filename}.svg"
done
