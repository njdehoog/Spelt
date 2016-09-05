DESTDIR := /usr/local

install:
	install -d "$(DESTDIR)/Frameworks"
	cp -r "./Build/Spelt/Build/Products/Release/spelt.app/Contents/Frameworks/SpeltKit.framework" "$(DESTDIR)/Frameworks/"
	cp "./Build/Spelt/Build/Products/Release/spelt.app/Contents/MacOS/spelt" "$(DESTDIR)/bin/spelt"
	install_name_tool -add_rpath "@executable_path/../Frameworks/SpeltKit.framework/Versions/Current/Frameworks/"  "$(DESTDIR)/bin/spelt"