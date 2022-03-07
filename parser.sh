#!/bin/sh
#
# Json parser script that generates an output file 
# containing the (1) Title (2) Author name(s) (3) Date
#
# Sources:
#   https://openlibrary.org/dev/docs/api/books
#   https://cameronnokes.com/blog/working-with-json-in-bash-using-jq/
#   https://openlibrary.org/dev/docs/api/books

# Write json data to a file based on Works ID (ex. OL45883W)
# Script must be run with one WorksID argument
if [ "$#" -eq 1 ]; then
    curl https://openlibrary.org/works/$1.json > input.json
else
    echo "Script arguments must contain one valid WorksID"
    exit 1
fi

# Clear output file if it exists; otherwise create new output.txt 
> output.txt

# Authors list WorksID call returns the AuthorID, so we use second curl to get the author names
AUTHORS=$(cat input.json | jq -r '.authors[].author[]')
ALIST=""
for AUTHOR in $AUTHORS; do
    NAME=$(curl https://openlibrary.org$AUTHOR.json | jq '.name')
    ALIST="$ALIST,$NAME"    
done

# Echo to file
echo "Title: $(cat input.json | jq '.title')

Author(s): $ALIST 

Date: $(cat input.json | jq '.created.value')
" >> output.txt
