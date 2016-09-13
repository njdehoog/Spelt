DESTDIR := /usr/local
RESOURCEDIR := "$(DESTDIR)/share/spelt"

install:
	# Create directories if they don't exist
	install -d "$(DESTDIR)/Frameworks"
	install -d "$(RESOURCEDIR)"

	# Copy framework
	cp -r "./Build/Spelt/Build/Products/Release/spelt.app/Contents/Frameworks/SpeltKit.framework" "$(DESTDIR)/Frameworks/"
	
	# Copy binary
	cp "./Build/Spelt/Build/Products/Release/spelt.app/Contents/MacOS/spelt" "$(DESTDIR)/bin/spelt"

	# Copy site template
	cp -r "./Resources/default-template" "$(RESOURCEDIR)"

	# Add runpath search path
	install_name_tool -add_rpath "@executable_path/../Frameworks/SpeltKit.framework/Versions/Current/Frameworks/"  "$(DESTDIR)/bin/spelt"