all:
	luac -o src/excite src/*.lua
	sed -i '1i #!/bin/lua' excite 

install:
	mkdir -p $(DESTDIR)/usr/share/bin
	install -Dm755 src/excite $(DESTDIR)/usr/local/bin/excite

clean:
	rm -rf src/excite src/excite-cli* src/src
