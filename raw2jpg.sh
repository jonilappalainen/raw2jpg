#!/bin/bash

overwrite_jpg=false
remove_raw=false

usage() { echo "Usage: $0 -d <directory> [-f <remove_raw>] [-w <ovewrite_jpg>]" 1>&2; exit 1; }

while getopts ":d:f:w:" o; do
    case "${o}" in
        d)
            path=${OPTARG}
            ;;
        f)
            remove_raw=${OPTARG}
            ;;
        w)
            overwrite_jpg=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${path}" ]; then
    usage
fi

echo "path          = ${path}"
echo "remove_raw    = ${remove_raw}"
echo "overwrite_jpg = ${overwrite_jpg}"

find $path -regextype posix-egrep -iregex '.*\.(rw2|NEF)' | while IFS= read -r raw_pathname; do
    base=$(basename "$raw_pathname"); name=${base%.*}; ext=${base##*.}
    jpg="${name}.jpg"
    jpg_pathname=${raw_pathname//$base/$jpg}
    changed=false

    echo "$base"

    if [ ! -e "$jpg_pathname" ] || ([ -e "$jpg_pathname" ] && [ $overwrite_jpg = true ]); then
            echo "    convert to ${jpg_pathname}"
            dcraw -c -w "$raw_pathname" | convert - "$jpg_pathname"
            exiftool -overwrite_original -tagsfromfile $raw_pathname -all:all $jpg_pathname
            changed=true
    fi
    if [ -e "$jpg_pathname" ] && [ $remove_raw = true ] ; then
        echo "    remove original $raw_pathname"
        rm $raw_pathname
        changed=true
    fi
    if [ $changed = false ]; then
        echo "    nothing to do"
    fi
done

