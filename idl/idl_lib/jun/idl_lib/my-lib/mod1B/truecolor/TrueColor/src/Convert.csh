#!/bin/csh

# Script to convert a MODIS true color 250 meter reprojected image
# to JPEG format at 250 meter, 1000 meter, and thumbnail resolution
# using the ImageMagick 'convert' utility

echo "(Converting TIFF to JPEG)"
convert -quality 85 -modulate 105,125 -sharpen 3 true.tif true_250m.jpg
convert -modulate 105,125 -geometry 25% true.tif true_1000m.jpg
convert -geometry 150x150 true_1000m.jpg true_thumb.jpg
