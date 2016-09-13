import SpeltKit
import Commandant
import Result

var observer: SiteObserver?

struct BuildOptions: OptionsType {
    let sourcePath: String
    let destinationPath: String
    let watch: Bool
    
    static func create(sourcePath: String) -> String -> Bool -> BuildOptions {
        return { destinationPath in { watch in
            return BuildOptions(sourcePath: sourcePath.absoluteStandardizedPath, destinationPath: destinationPath.absoluteStandardizedPath, watch: watch);
        }}
    }
    
    static func evaluate(m: CommandMode) -> Result<BuildOptions, CommandantError<SpeltError>> {
        return create
            <*> m <| Option(key: "source", defaultValue: BuildCommand.currentDirectoryPath, usage: "Source directory (defaults to ./)")
            <*> m <| Option(key: "destination", defaultValue: BuildCommand.currentDirectoryPath.stringByAppendingPathComponent("_build"), usage: "Destination directory (defaults to ./_build)")
            <*> m <| Option(key: "watch", defaultValue: true, usage: "Disable auto-regeneration")
    }
}

struct BuildCommand: CommandType {
    typealias Options = BuildOptions
    
    static let currentDirectoryPath = NSFileManager().currentDirectoryPath
    
    let verb = "build"
    let function = "Build your site"
    
    func run(options: Options) -> Result<(), SpeltError> {
        do {
            try build(options)
        }
        catch {
            return Result.Failure(SpeltError(underlyingError: error))
        }
        
        if options.watch {
            // keep process alive
            CFRunLoopRun()
        }
        
        return Result.Success()
    }
    
    func build(options: Options) throws {
        print("Source: \(options.sourcePath)")
        print("Destination: \(options.destinationPath)")
        
        print("Generating...")
        let before = NSDate()
        try _build(options)
        print(String(format: "Done in %.3f seconds", NSDate().timeIntervalSinceDate(before)))

        if options.watch {
            print("Auto-regeneration enabled")
            
            observer = SiteObserver(sourcePath: options.sourcePath, changeHandler: { sourcePath in
                do {
                    print("Regenerating...")
                    let before = NSDate()
                    try self._build(options)
                    print(String(format: "Done in %.3f seconds", NSDate().timeIntervalSinceDate(before)))
                }
                catch {
                    // output error to StandardError
                    fputs("\(error)\n", stderr)
                }
            })
        }
    }
    
    private func _build(options: Options) throws {
        let site = try SiteReader(sitePath: options.sourcePath).read()
        try SiteRenderer(site: site).render()
        try SiteBuilder(site: site, buildPath: options.destinationPath).build()
    }
}