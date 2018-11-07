#!/bin/bash
if [ $# -ne 1 ]; 
    then echo "Syntax: makeborder.sh inputfile.png"
    exit
fi

if [ ! -e $1 ]; 
    then echo "File does not exist, try again."
    exit
fi


INFILE=$1
filename=$(basename "$INFILE")
fname="${filename%.*}"
ext="${filename##*.}"
OUTFILE=/tmp/"$fname"_border."$ext"

#echo "Input File: $INFILE"
#echo "Filename without Path: $filename"
#echo "Filename without Extension: $fname"
#echo "File Extension without Name: $ext"

# Get width of image 

WIDTH=`identify -format "%W" $INFILE`
echo "Original file's width is $WIDTH"

# Get resolution of image in x direction, and convert it to an integer
RESOLUTION=`identify -units PixelsPerInch -format "%x" $INFILE`
RESOLUTIONINT=${RESOLUTION%.*}

if [ "$RESOLUTIONINT" -gt 77 ]; then
  echo "Resoluthion is high"
	BORDERWIDTH=6
else
  echo "Resolution is low"
	BORDERWIDTH=3
fi
echo "Resolution is $RESOLUTIONINT, so border width is $BORDERWIDTH"

# Intermediary file names:
ORIGINAL_IMAGE_WITH_BORDER="/tmp/barf.png"
TORN_PAGE="/tmp/torn.png"
TORN_PAGE_RESIZE="/tmp/torn_width.png"
SUBTRACT="/tmp/subtract.png"
# Draw border around image.
echo "Drawing border around initial image..."
convert $INFILE -bordercolor "#c0c0c0" -border $BORDERWIDTH $ORIGINAL_IMAGE_WITH_BORDER

# Create torn shape

echo "Creating torn shape..."
convert -size 1302x81 xc:none -matte -stroke black -fill "#ff0000" -strokewidth 1 -draw "polyline 0,80 120,28 255,42 395,25 502,48 685,0 855,35 1000,18 1072,45 1213,19 1263,33 1302,80 0,80" $TORN_PAGE

# Resize torn shape to width of image

echo "Resizing torn shape..."
convert $TORN_PAGE -resize ${WIDTH}! $TORN_PAGE_RESIZE

# Subtract torn page from original image

echo "Subtracting torn shape from initial image..."
convert  $ORIGINAL_IMAGE_WITH_BORDER $TORN_PAGE_RESIZE -gravity South -compose Xor -composite $SUBTRACT

# Add drop shadow from subtracted image
echo "Adding drop shadow..."
convert $SUBTRACT \( -clone 0 -background gray -shadow 80x3+10+10 \) -reverse -background none -layers merge +repage $OUTFILE 

echo "File with order is in $OUTFILE"
if [ "$RESOLUTIONINT" -gt 77 ]; then
	let SCALED=$WIDTH/2
   echo "Be sure to add :width: $SCALED"
fi


