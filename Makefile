TEMPORARY_FOLDER :=/tmp/Spelt.dst
PREFIX :=/usr/local

OUTPUT_PACKAGE=Spelt.pkg
OUTPUT_FRAMEWORK=SpeltKit.framework

BINARIES_FOLDER=/usr/local/bin
FRAMEWORKS_FOLDER=/Library/Frameworks

BUILT_BUNDLE=$(TEMPORARY_FOLDER)/Applications/spelt.app
SPELT_BUNDLE=$(BUILT_BUNDLE)/Contents/Frameworks/$(OUTPUT_FRAMEWORK)
SPELT_EXECUTABLE=$(BUILT_BUNDLE)/Contents/MacOS/spelt

COMPONENTS_PLIST=SpeltComponents.plist
VERSION_STRING=$(shell agvtool what-marketing-version -terse1)

XCODEFLAGS=-workspace Spelt.xcworkspace -scheme spelt -configuration Release DSTROOT=$(TEMPORARY_FOLDER)

.PHONY: all bootstrap clean install uninstall installables prefix_install package

all:
	xcodebuild $(XCODEFLAGS) build

bootstrap:
	carthage bootstrap --use-submodules --platform Mac

clean:
	rm -rf "$(TEMPORARY_FOLDER)"
	rm -f "$(OUTPUT_PACKAGE)"
	xcodebuild $(XCODEFLAGS) clean

install: package
	sudo installer -pkg "$(OUTPUT_PACKAGE)" -target /

uninstall:
	rm -f "$(PREFIX)/bin/spelt"
	rm -rf "$(PREFIX)/Frameworks/SpeltKit.framework"
	rm -rf "$(FRAMEWORKS_FOLDER)/$(OUTPUT_FRAMEWORK)"

installables: clean
	xcodebuild $(XCODEFLAGS) install

	mkdir -p "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"
	mv -f "$(SPELT_BUNDLE)" "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)/$(OUTPUT_FRAMEWORK)"
	mv -f "$(SPELT_EXECUTABLE)" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/spelt"
	rm -rf "$(BUILT_BUNDLE)"

prefix_install: installables
	mkdir -p "$(PREFIX)/Frameworks" "$(PREFIX)/bin"

	# Copy Frameworks
	cp -Rf "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)/$(OUTPUT_FRAMEWORK)" "$(PREFIX)/Frameworks/"
	
	# Copy binary
	cp -f "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/spelt" "$(PREFIX)/bin/"
	
	# Add runpath search path
	install_name_tool -add_rpath "@executable_path/../Frameworks/$(OUTPUT_FRAMEWORK)/Versions/Current/Frameworks/"  "$(PREFIX)/bin/spelt"

package: installables
	pkgbuild \
		--component-plist "$(COMPONENTS_PLIST)" \
		--identifier "org.spelt.spelt" \
		--install-location "/" \
		--root "$(TEMPORARY_FOLDER)" \
		--version "$(VERSION_STRING)" \
		"$(OUTPUT_PACKAGE)"
