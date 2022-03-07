

    ███████╗██╗  ██╗ ██████╗██╗████████╗███████╗
    ██╔════╝╚██╗██╔╝██╔════╝██║╚══██╔══╝██╔════╝
    █████╗   ╚███╔╝ ██║     ██║   ██║   █████╗  
    ██╔══╝   ██╔██╗ ██║     ██║   ██║   ██╔══╝  
    ███████╗██╔╝ ██╗╚██████╗██║   ██║   ███████╗
    ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝   ╚═╝   ╚══════╝


### A terminal-based citation generator

Search for a citation by specifying either the title of the work or an identifier code (ISBN, OCLC, LCCN, OLID) and a citation type (MLA, APA, BibTex). 

Copy citations to your clipboard and/or add them to a bibliography file!

## Usage

```
$ lua excite.lua -h
Usage: excite [-h] [-o] [-r <rename>] <input>

A terminal-based citation generator

Arguments:
   input                 ISBN code

Options:
   -h, --help            Show this help message and exit.
   -o, --output          Output citation to a file
         -r <rename>,    Output citation to a file (default: citation.txt)
   --rename <rename>
```

## Dependencies

* Lua 5.4.4

``` 
sudo luarocks install lua-curl lua-json argparse
```
