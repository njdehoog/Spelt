import SpeltKit
import Commandant
import Result

var observer: SiteObserver?

struct BuildOptions: OptionsProtocol {
    let sourcePath: String
    let destinationPath: String
    let watch: Bool
    
    static func create(_ sourcePath: String) -> (String) -> (Bool) -> BuildOptions {
        return { destinationPath in { watch in
            return BuildOptions(sourcePath: sourcePath.absoluteStandardizedPath, destinationPath: destinationPath.absoluteStandardizedPath, watch: watch);
        }}
    }
    
    static func evaluate(_ m: CommandMode) -> Result<BuildOptions, CommandantError<SpeltError>> {
        return create
            <*> m <| Option(key: "source", defaultValue: BuildCommand.currentDirectoryPath, usage: "Source directory (defaults to ./)")
            <*> m <| Option(key: "destination", defaultValue: BuildCommand.currentDirectoryPath.stringByAppendingPathComponent("_build"), usage: "Destination directory (defaults to ./_build)")
            <*> m <| Option(key: "watch", defaultValue: true, usage: "Disable auto-regeneration")
    }
}

struct BuildCommand: CommandProtocol {
    typealias Options = BuildOptions
    
    static let currentDirectoryPath = FileManager().currentDirectoryPath
    
    let verb = "build"
    let function = "Build your site"
    
    func run(_ options: Options) -> Result<(), SpeltError> {
        do {
            try build(options)
        }
        catch {
            return Result.failure(SpeltError(underlyingError: error))
        }
        
        if options.watch {
            // keep process alive
            CFRunLoopRun()
        }
        
        return Result.success()
    }
    
    func build(_ options: Options) throws {
        print("Source: \(options.sourcePath)")
        print("Destination: \(options.destinationPath)")
        
        print("Generating...")
//        let before = Date()
        try _build(options)
        // FIXME: print time to complete
//        print(String(format: "Done in %.3f seconds", NSDate().timeIntervalSinceDate(before)))

        if options.watch {
            print("Auto-regeneration enabled")
            
            observer = SiteObserver(sourcePath: options.sourcePath, changeHandler: { sourcePath in
                do {
                    print("Regenerating...")
//                    let before = Date()
                    try self._build(options)
                    // FIXME: print time to complete
//                    print(String(format: "Done in %.3f seconds", NSDate().timeIntervalSinceDate(before)))
                }
                catch {
                    // output error to StandardError
                    fputs("\(error)\n", stderr)
                }
            })
        }
    }
    
    fileprivate func _build(_ options: Options) throws {
        let site = try SiteReader(sitePath: options.sourcePath).read()
        try SiteRenderer(site: site).render()
        try SiteBuilder(site: site, buildPath: options.destinationPath).build()
    }
}
