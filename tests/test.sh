#!/bin/bash
# RUN from root

# delete old
rm -f y.tab.c
rm -f y.tab.h
rm -f a.out
rm -f lex.yy.c
# compile
make build

# http://stackoverflow.com/questions/20796200/how-to-iterate-over-files-in-a-directory-with-bash
# flag variable
flag=0

# test good source
for filename in tests/*.shach; do
	echo 'Testing: '$filename
	output=$(./a.out bash < $filename)
	# http://stackoverflow.com/questions/229551/string-contains-in-bash
	if [[ $output != *"VALID_CODE"* ]]; then
		echo "Failed (Bash): "$filename
		echo "Error: "$output
		flag=1
	fi
	# batch
	output=$(./a.out batch < $filename)
	if [[ $output != *"VALID_CODE"* ]]; then
		echo "Failed (Batch): "$filename
		echo "Error: "$output
		flag=1
	fi
done

# test bad source
for filename in anti-tests/*.shach; do
	echo 'Anti-testing: '$filename
	output=$(./a.out bash < $filename)
	# http://stackoverflow.com/questions/229551/string-contains-in-bash
	if [[ $output != *"UNRECOGNIZED_CODE"* ]]; then
		echo "Failed (Bash): "$filename
		echo "Error: "$output
		flag=1
	fi
	# batch
	output=$(./a.out batch < $filename)
	if [[ $output != *"UNRECOGNIZED_CODE"* ]]; then
		echo "Failed (Batch): "$filename
		echo "Error: "$output
		flag=1
	fi
done

# exit
if (( $flag == 1 )); then
	exit 1
else
	echo '** No issues **'
	exit 0
fi
