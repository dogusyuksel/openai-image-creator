#!/bin/bash

date

if [ "$#" -eq 1 ]; then
    if [ "$1" = "-h" ]; then
        echo "USAGE:"
        echo "    '-s' story (must)"
        echo "    '-e' scene (must)"
        echo "    '-c' count (optional, default 1)"
        exit 0
    fi
fi
## Default values:
story=""
scene=""
api_key=""
count="1"

## It's the : after d that signifies that it takes an option argument.

while getopts s:e:c:k: opt; do
    case $opt in
        s) story=$OPTARG ;;
        e) scene=$OPTARG ;;
        c) count=$OPTARG ;;
        k) api_key=$OPTARG ;;
        *) echo 'error in command line parsing' >&2
           exit 1
    esac
done

shift "$(( OPTIND - 1 ))"


echo "## Starting Process for story $story, scene $scene and count $count" | tee -a output.md

if [ ! -d "artifacts_folder" ]; then
  mkdir artifacts_folder
fi

if [ "$story" == "" ]; then
    echo "story cannot be null" | tee -a output.md
    cp -rf output.md artifacts_folder
    exit 1
fi

if [ "$api_key" == "" ]; then
    echo "api_key cannot be null" | tee -a output.md
    cp -rf output.md artifacts_folder
    exit 1
fi

if [ "$scene" == "" ]; then
    echo "scene cannot be null" | tee -a output.md
    cp -rf output.md artifacts_folder
    exit 1put.md
    exit 1
fi

if [ $count -gt 5 ]; then
    echo "count cannot be more than 5" | tee -a output.md
    cp -rf output.md artifacts_folder
    exit 1
fi

total=$((count + scene))
if [ $total -gt 6 ]; then
    echo "total cannot be more than 6" | tee -a output.md
    cp -rf output.md artifacts_folder
    exit 1
fi

for (( i=0; i<count; i++ )) ; {
    scene_new=$((scene+i))
    echo "calling params --story_id $story --scene_id $scene_new" | tee -a output.md
    ret=0
    echo "" >> output.md
    echo "\`\`\`" >> output.md
    echo "" >> output.md
    echo "trying one of the api keys" >> output.md
    python3 image_gener.py --story_id $story --scene_id $scene_new --api_key $api_key
    ret=$?
    if [ $ret -eq 0 ]; then
        break
    fi
    echo "" >> output.md
    echo "\`\`\`" >> output.md
    echo "" >> output.md
    if [ $ret -ne 0 ]; then
        echo "-> parsing error, exiting..." | tee -a output.md
        cp -rf output.md artifacts_folder
        exit 1
    fi
}
echo "all good" | tee -a output.md

echo "## Creating Artifacts" | tee -a output.md

for d in $(find . -name "*.png")
do
  mv -f $d artifacts_folder
done

echo "all good" | tee -a output.md

cp -rf output.md artifacts_folder

date
