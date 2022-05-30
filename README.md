
![Logo](logo.png)
Search for a citation by specifying either the title of the work or an identifier code (ISBN, OCLC, LCCN, OLID) and a citation type (MLA, APA, BibTex). 

Copy citations to your clipboard and/or add them to a bibliography file.

## Usage

``` 
$ excite -h
Usage: excite [-h] [-o] [-r <rename>] <input> {bibtex,APA,MLA}

Arguments:
   {bibtex,APA,MLA}      Cite style
   input                 ISBN, DOI, or title query

Options:
   -h, --help            Show this help message and exit.
   -o, --output          Output citation to a file.
         -r <rename>,    Rename output file. (default: citation.txt)
   --rename <rename>
```

## Examples

### ISBN

```
$ excite APA 9781400079278
```
```
Murakami, H.(2006). Kafka on the shore. VINTAGE.
```

### DOI

``` 
$ excite bibtex 10.2307/2266170
```
```
@article{church1940,
author = "Alonzo Church"
title = "A formulation of the simple theory of types"
journal = "Journal of Symbolic Logic"
year = "1940"
publisher = "Cambridge University Press (CUP)"
pages = "56-68"
doi = "10.2307/2266170"
}
```

### SEARCH

```
$ excite MLA "The Lord of the Rings"
```
```
[1]
   The Lord of the Rings
   J.R.R. Tolkien
   1954
   ISBN: 9785878600132
-------------------------
[2]
   Novels (Hobbit / Lord of the Rings)
   J.R.R. Tolkien
   1979
   ISBN: 9780261103566
-------------------------
[3]
   Lord of the Rings
   J. R. R. Tolkien
   1976
   ISBN: 9780061917820
-------------------------
[4]
   Realm of the Ring Lords
   Laurence Gardner
   2000
   ISBN: 9781931412148
-------------------------
[5]
   Lord of the Rings
   Cedco Publishing
   2001
   ISBN: 9780768325294
-------------------------
Press any key for more results
```
```
Tolkien, J.R.R., et. al. "The Lord of the Rings." WSOY, 1954.
```

## Dependencies

* Lua 5.4.4+

``` 
sudo luarocks install lua-curl lua-json argparse
```
