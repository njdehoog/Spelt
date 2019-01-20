import SpeltKit
import Commandant
import Result

var server: SiteServer?

struct ServeOptions: BuildOptionsProtocol, OptionsProtocol {
    let sourcePath: String
    let destinationPath: String
    let watch: Bool
    let port: Int
    
    static func create(_ sourcePath: String) -> (String) -> (Bool) -> (Int) -> ServeOptions {
        return { destinationPath in { watch in { port in
            return ServeOptions(sourcePath: sourcePath.absoluteStandardizedPath, destinationPath: destinationPath.absoluteStandardizedPath, watch: watch, port : port);
        }}}
    }
    
    static func evaluate(_ m: CommandMode) -> Result<ServeOptions, CommandantError<SpeltError>> {
        return create
            <*> m <| Option(key: "source", defaultValue: BuildCommand.currentDirectoryPath, usage: "Source directory (defaults to ./)")
            <*> m <| Option(key: "destination", defaultValue: BuildCommand.currentDirectoryPath.stringByAppendingPathComponent("_build"), usage: "Destination directory (defaults to ./_build)")
            <*> m <| Option(key: "watch", defaultValue: true, usage: "Disable auto-regeneration")
            <*> m <| Option(key: "port", defaultValue: 0, usage: "Running port (defaults to random)")
    }
}

struct ServeCommand: CommandProtocol {
    typealias Options = ServeOptions
    
    let verb = "preview"
    let function = "Preview your site locally"
    
    func run(_ options: Options) -> Result<(), SpeltError> {
        do {
            try BuildCommand().build(options)
            server = SiteServer(directoryPath: options.destinationPath)
            let (_, port) = try server!.start(port: options.port)
            print("Preview your site at: http://0.0.0.0:\(port)")
        }
        catch {
            return Result.failure(SpeltError(underlyingError: error))
        }
        
        // keep process alive
        CFRunLoopRun()
        
        return Result.success(())
    }
}
