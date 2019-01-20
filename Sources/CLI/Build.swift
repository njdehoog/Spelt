import SpeltKit
import Commandant
import Result

var observer: SiteObserver?

protocol BuildOptionsProtocol {
    var sourcePath: String { get }
    var destinationPath: String { get }
    var watch: Bool { get }
}

struct BuildOptions: BuildOptionsProtocol, OptionsProtocol {
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
            <*> m <| Option(key: "watch", defaultValue: false, usage: "Enable auto-regeneration")
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
        
        return Result.success(())
    }
    
    func build(_ options: BuildOptionsProtocol) throws {
        print("Source: \(options.sourcePath)")
        print("Destination: \(options.destinationPath)")
        
        print("Generating...", terminator: "")
        let before = Date()
        try _build(options)
        print(String(format: "done in %.3f seconds", Date().timeIntervalSince(before)))

        if options.watch {
            print("Auto-regeneration enabled")
            
            observer = SiteObserver(sourcePath: options.sourcePath, changeHandler: { sourcePath in
                do {
                    print("Regenerating...", terminator: "")
                    let before = Date()
                    try self._build(options)
                    print(String(format: "done in %.3f seconds", Date().timeIntervalSince(before)))
                }
                catch {
                    // output error to StandardError
                    fputs("\(error)\n", stderr)
                }
            })
        }
    }
    
    fileprivate func _build(_ options: BuildOptionsProtocol) throws {
        let site = try SiteReader(sitePath: options.sourcePath).read()
        try SiteRenderer(site: site).render()
        try SiteBuilder(site: site, buildPath: options.destinationPath).build()
    }
}
