# raw2jpg

Convert raw images to jpg.

## Getting started

### Pre-requirements

- perl-image-exiftool
- parallel
- convert (image magick)
- dcraw


### Usage

`./raw2jpg.sh -d /mnt/disk/raw-images/ -r true`

### Options

`-d` root directory of raw images
`-r` remove original raw image after succesful conversion (false as default)
`-w` overwrite existing jpg (redo the conversion otherwise will skip) (false as default)


