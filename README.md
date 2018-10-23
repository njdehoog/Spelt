# Spelt [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/njdehoog/Spelt/master/LICENSE.md)

Spelt is a blog-aware static site generator written in Swift.

## Installation

### Using the installer

Download and run the `Spelt.pkg` file for the latest [release](https://github.com/njdehoog/Spelt/releases).

### Building from source

In order to build Spelt you need to have [Carthage](https://github.com/Carthage/Carthage) and a recent version of [Xcode](https://developer.apple.com/xcode/) installed. Keep in mind that the master branch contains the latest development version and may not always be stable.

1. Clone the project: `git clone --recursive https://github.com/njdehoog/Spelt.git`
2. Install dependencies: `make bootstrap`
3. Build and install CLI: `make install`

## Usage

Create a new site to get started using Spelt. Replace `PATH` with the name of your blog.

```
spelt new PATH
```

### Local preview

Spelt can run a local webserver which displays a preview of your site. When auto-regeneration is enabled, your site will be regenerated whenever a file on your project directory is changed.

```
spelt preview
```

### Building

When building your site, the generated files are placed in the `_build` folder in your project directory.

```
spelt build
```

## Documentation

Documentation for Spelt can be found [here](http://docs.spelt.io.s3-website-us-east-1.amazonaws.com). This documentation was originally written for the Spelt Mac app (which is no longer available), but most of it applies to the CLI as well.

If you spot any errors in the documentation, please submit a pull request in the [documentation repository](https://github.com/njdehoog/docs.spelt.io).

## Contributing

This project is still in the early stages of development, so any help would be appreciated. Please feel free to fork the project and submit a pull request.

## License

Spelt is released under the [MIT License](https://github.com/njdehoog/Spelt/blob/master/LICENSE.md).
