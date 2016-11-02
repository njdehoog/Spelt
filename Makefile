DESTDIR := /usr/local
RESOURCEDIR := "$(DESTDIR)/share/spelt"
BUILD_DIR := Build/

XCODEFLAGS=-workspace Spelt.xcworkspace -scheme spelt -configuration Release -derivedDataPath $(BUILD_DIR)

all:
	xcodebuild $(XCODEFLAGS) build

provision:
	carthage bootstrap --use-submodules --platform Mac

clean:
	rm -rf "$(BUILD_DIR)"

install: clean all
	# Create directories if they don't exist
	install -d "$(DESTDIR)/Frameworks"
	install -d "$(RESOURCEDIR)"

	# Copy framework
	cp -r "$(BUILD_DIR)Build/Products/Release/spelt.app/Contents/Frameworks/SpeltKit.framework" "$(DESTDIR)/Frameworks/"
	
	# Copy Swift libraries
	cp -r "$(BUILD_DIR)Build/Products/Release/spelt.app/Contents/Frameworks/SpeltKit.framework" "$(DESTDIR)/Frameworks/"

	# Copy binary
	cp "$(BUILD_DIR)Build/Products/Release/spelt.app/Contents/MacOS/spelt" "$(DESTDIR)/bin/spelt"

	# Copy site template
	cp -r "./Resources/default-template" "$(RESOURCEDIR)"

	# Add runpath search path
	install_name_tool -add_rpath "@executable_path/../Frameworks/SpeltKit.framework/Versions/Current/Frameworks/"  "$(DESTDIR)/bin/spelt"

uninstall:
	rm -f "$(DESTDIR)/bin/spelt"
	rm -rf "$(DESTDIR)/Frameworks/SpeltKit.framework"
