#!/usr/bin/env bash

if [[ $# -lt 3 ]]; then
	echo "$0: input_file_name output_file_name size"
	exit 255
fi

INPUT_FILE=$1
OUTPUT_FILE=$2
SIZE=$3
MEM_LIMIT_KiB=$(( 300 * 1024 )) # Limit the memory usage to 300 MiB

TEMP="$(mktemp --directory --tmpdir tumbler-stl-XXXXXXX)"
# Use a sub shell to enclose the commands in case it aborts and skip the last cleanup action
# Sub shell BEG
(
	ulimit -v $MEM_LIMIT_KiB
	cp "$INPUT_FILE" "$TEMP/source.stl"

	echo "import(\"source.stl\", convexity=10);" >"$TEMP/thumbnail.scad"
	openscad --imgsize "500,500" -o "$TEMP/thumbnail.png" "$TEMP/thumbnail.scad" 2>/dev/null

	convert -thumbnail "$SIZE" "$TEMP/thumbnail.png" "$OUTPUT_FILE" 1>/dev/null 2>&1
)
# Sub shell END
[ -d $TEMP ] && rm -rf $TEMP
