#!/bin/bash
shopt -s nullglob
array=(*/*[CRUMST].svg)

fileCount=${#array[@]}

for i in "${!array[@]}"; do 
  filename="${array[$i]}"
  filename="${filename%.*}"
  folder="${filename%/*}"
  outname="${filename#*/}"

  # Some directories simply contain the rarity (C.csv) for example. If this is the case,
  # we will assume the folder name as the set.
  if [ 1 -eq ${#outname} ]
  then
    outname="${folder}${outname}"
  fi

  # Not removing underscore anymore... some set names include underscores.
  # outname=${outname//_/}

  echo "${outname} - ${i} of ${fileCount}"

#  echo "${filename}"
  targetPath="$(pwd)/CardSets/${outname}.png"

  if [ ! -f ${targetPath} ]; then
    /Applications/Inkscape.app/Contents/Resources/bin/inkscape --export-png "$(pwd)/CardSets/${outname}.png" -h 32 "$(pwd)/${filename}.svg" >/dev/null &
    /Applications/Inkscape.app/Contents/Resources/bin/inkscape --export-png "$(pwd)/CardSets/${outname}@2x.png" -h 64 "$(pwd)/${filename}.svg" >/dev/null &
    /Applications/Inkscape.app/Contents/Resources/bin/inkscape --export-png "$(pwd)/CardSets/${outname}@3x.png" -h 96 "$(pwd)/${filename}.svg" >/dev/null &
  fi

  wait
  
  echo 
done
