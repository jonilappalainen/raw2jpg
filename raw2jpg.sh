#!/bin/bash

overwrite_jpg=false
remove_raw=false

usage() { echo "Usage: $0 (-d <directory> | -f <rawfile>) [-r <remove_raw>] [-w <ovewrite_jpg>]" 1>&2; exit 1; }

while getopts ":d:f:r:w:" o; do
    case "${o}" in
        d)
            path=${OPTARG}
            ;;
        f)
            rawfile=${OPTARG}
            ;;
        r)
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

if [ -z "${path}" ] && [ -z "${rawfile}" ] ; then
    usage
fi



if [ ! -z "${path}" ] ; then
echo "path          = ${path}"
echo "remove_raw    = ${remove_raw}"
echo "overwrite_jpg = ${overwrite_jpg}"

find $path -regextype posix-egrep -iregex '.*\.(rw2|NEF)' | parallel -j+0 "$0 -f {} -w $overwrite_jpg -r $remove_raw"

elif [ ! -z "${rawfile}" ] ; then
    base=$(basename "$rawfile"); name=${base%.*}; ext=${base##*.}
    jpg="${name}.jpg"
    jpg_pathname=${rawfile//$base/$jpg}
    changed=false

    echo "$base"

    if [ ! -e "$jpg_pathname" ] || ([ -e "$jpg_pathname" ] && [ $overwrite_jpg = true ]); then
            echo "    convert to ${jpg_pathname}"
            dcraw -c -w "$rawfile" | convert - "$jpg_pathname"
            exiftool -overwrite_original -preserve -tagsfromfile $rawfile -all:all $jpg_pathname
            changed=true
    fi
    if [ -e "$jpg_pathname" ] && [ $remove_raw = true ] ; then
        echo "    remove original $rawfile"
        rm $rawfile
        changed=true
    fi
    if [ $changed = false ]; then
        echo "    nothing to do"
    fi
    
fi


