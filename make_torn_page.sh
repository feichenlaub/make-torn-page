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

# Get width and height of incoming image 

WIDTH=`identify -format "%W" $INFILE`
HEIGHT=`identify -format "%H" $INFILE`
BASEWIDTH=1302
BASEHEIGHT=81
RATIOWIDTH=`echo "scale=2;$WIDTH/$BASEWIDTH" | bc`
DELTAHEIGHT=`expr $HEIGHT - $BASEHEIGHT`
echo "Original file's width is $WIDTH"
echo "Original file's height is $HEIGHT"
echo "Width ratio is $RATIOWIDTH"
echo "Delta height is $DELTAHEIGHT"

# Compute border width as a function of the print width
BORDERWIDTH=`echo "scale=0;($WIDTH*0.002859)/1 + 1" | bc`
echo "Border width is $BORDERWIDTH"

# Intermediary file names:
ORIGINAL_IMAGE_WITH_BORDER="/tmp/original-file-with-border.png"
TORN_PAGE="/tmp/torn-page.png"
TORN_PAGE_RESIZE="/tmp/torn_page-resize.png"
SUBTRACT="/tmp/subtract.png"
#
# Draw border around image
# First shave the image by the border width, then
# add the border to the image. Adding the border
# returns the image to its original sizse.
#
echo "Drawing border around initial image..."
convert $INFILE -shave $BORDERWIDTH -bordercolor "#c0c0c0" -border $BORDERWIDTH $ORIGINAL_IMAGE_WITH_BORDER

declare -a pathpoints=(0,80 120,28 255,42 395,25 502,48 685,0 855,35 1000,18 1072,45 1213,19 1263,33 1302,80 0,80)
echo ${pathpoints[@]}
for i in "${pathpoints[@]}"
do
	SCALEDPATH+=`echo $i|awk -F,  '{printf "%d,%d ", '$RATIOWIDTH'*$1,'$DELTAHEIGHT'+$2}'`
  #echo $i
done
echo "SCALEDPATH IS $SCALEDPATH"
# Create torn shape




echo "Creating torn shape..."
#convert -size 1302x81 xc:white -matte -stroke black -fill black -strokewidth 1 -draw "polyline 0,80 120,28 255,42 395,25 502,48 685,0 855,35 1000,18 1072,45 1213,19 1263,33 1302,80 0,80" $TORN_PAGE
convert -size "$WIDTH"x"$HEIGHT" xc:white -matte -stroke black -fill black -strokewidth 1 -draw "polyline $SCALEDPATH" $TORN_PAGE_RESIZE

# Resize torn shape to width of image

#echo "Resizing torn shape..."
#convert $TORN_PAGE -resize ${WIDTH}! $TORN_PAGE_RESIZE

# Subtract torn page from original image

echo "Subtracting torn shape from initial image..."
convert $ORIGINAL_IMAGE_WITH_BORDER $TORN_PAGE_RESIZE -alpha Off -gravity South -compose CopyOpacity -composite $SUBTRACT

# Add drop shadow from subtracted image
echo "Adding drop shadow..."
convert $SUBTRACT \( -clone 0 -background gray -shadow 80x3+10+10 \) -reverse -background none -layers merge +repage $OUTFILE 

echo "File with order is in $OUTFILE"
if [ $BORDERWIDTH -gt 3 ]; then
	let SCALED=$WIDTH/2
   echo "Be sure to add :width: $SCALED"
fi

function xcoord() {
  local newx
  echo "$newx"
  
}
