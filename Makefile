TEMPORARY_FOLDER :=/tmp/Spelt.dst
PREFIX :=/usr/local

OUTPUT_PACKAGE=Spelt.pkg
OUTPUT_FRAMEWORK=SpeltKit.framework

BINARIES_FOLDER=/usr/local/bin
FRAMEWORKS_FOLDER=/Library/Frameworks

BUILT_BUNDLE=$(TEMPORARY_FOLDER)/Applications/spelt.app
SPELT_BUNDLE=$(BUILT_BUNDLE)/Contents/Frameworks/$(OUTPUT_FRAMEWORK)
SPELT_EXECUTABLE=$(BUILT_BUNDLE)/Contents/MacOS/spelt

VERSION_STRING = 0.1

DESTDIR := /usr/local
RESOURCEDIR := "$(DESTDIR)/share/spelt"
BUILD_DIR := Build/

XCODEFLAGS=-workspace Spelt.xcworkspace -scheme spelt -configuration Release DSTROOT=$(TEMPORARY_FOLDER)

all:
	xcodebuild $(XCODEFLAGS) build

provision:
	carthage bootstrap --use-submodules --platform Mac

clean:
	rm -rf "$(TEMPORARY_FOLDER)"

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

installables: clean
	xcodebuild $(XCODEFLAGS) install

	mkdir -p "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"
	mv -f "$(SPELT_BUNDLE)" "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)/$(OUTPUT_FRAMEWORK)"
	mv -f "$(SPELT_EXECUTABLE)" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/spelt"
	rm -rf "$(BUILT_BUNDLE)"

prefix_install: installables
	mkdir -p "$(PREFIX)/Frameworks" "$(PREFIX)/bin"
	cp -Rf "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)/$(OUTPUT_FRAMEWORK)" "$(PREFIX)/Frameworks/"
	cp -f "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/spelt" "$(PREFIX)/bin/"
	install_name_tool -add_rpath "@executable_path/../Frameworks/$(OUTPUT_FRAMEWORK)/Versions/Current/Frameworks/"  "$(PREFIX)/bin/spelt"

