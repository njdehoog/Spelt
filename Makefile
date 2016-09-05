DESTDIR := /usr/local

install:
	install -d "$(DESTDIR)/lib/spelt"
	cp -r "./Build/Spelt/Build/Products/Release/CLI.bundle" "$(DESTDIR)/lib/spelt"
	ln -sf "$(DESTDIR)/lib/spelt/CLI.bundle/Contents/MacOS/CLI" "$(DESTDIR)/bin/spelt"