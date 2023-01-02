TARGET = excite-cli
MAIN = src/main/

all:
	# Compile to lua bytecode
	@-./compile.sh
	# Add shebang to allow execution by stand-alone interpreter
	sed -i '1i #!/bin/lua' $(MAIN)excite 

install:
	mkdir -p $(DESTDIR)/usr/local/bin
	install -Dm755 $(MAIN)excite $(DESTDIR)/usr/local/bin/excite

clean:
	rm -rf $(MAIN)excite build/pkg build/src build/excite* 
