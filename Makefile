TARGET = excite-cli
SRC := src/

all: 
	luac -o $(SRC)excite $(SRC)*.lua
	sed -i '1i #!/bin/lua' $(SRC)excite 

install:
	mkdir -p $(DESTDIR)/usr/share/bin
	install -Dm755 $(SRC)excite $(DESTDIR)/usr/local/bin/excite

clean:
	#rm -rf $(SRC)excite $(SRC)excite-cli* $(SRC)pkg 
