TARGET = excite-cli
SRC := *.lua

all: excite-cli

excite-cli: $(SRC)
	luac -o excite *.lua
	sed -i '1i #!/bin/lua' excite 

install:
	mkdir -p $(DESTDIR)/usr/share/bin
	install -Dm755 excite $(DESTDIR)/usr/local/bin/excite

clean:
	rm -rf excite excite-cli* pkg src
