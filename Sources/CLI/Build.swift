import SpeltKit
import Commandant
import Result

struct BuildCommand: CommandType {
    static let currentDirectoryPath = NSFileManager().currentDirectoryPath

    struct Options: OptionsType {
        let sourcePath: String
        let destinationPath: String
        
        static func create(sourcePath: String) -> String -> Options {
            return { destinationPath in
                return Options(sourcePath: sourcePath.stringByStandardizingPath.absolutePath, destinationPath: destinationPath.stringByStandardizingPath.absolutePath);
            }
        }
        
        static func evaluate(m: CommandMode) -> Result<Options, CommandantError<SpeltError>> {
            return create
                <*> m <| Option(key: "source", defaultValue: BuildCommand.currentDirectoryPath, usage: "Source directory (defaults to ./)")
                <*> m <| Option(key: "destination", defaultValue: BuildCommand.currentDirectoryPath.stringByAppendingPathComponent("_build"), usage: "Destination directory (defaults to ./_build)")
        }
    }
    
    let verb = "build"
    let function = "Build your site"
    
    func run(options: Options) -> Result<(), SpeltError> {
        do {
            let site = try SiteReader(sitePath: options.sourcePath).read()
            let siteBuilder = SiteBuilder(site: site, buildPath: options.destinationPath)
            try siteBuilder.build()
        }
        catch {
            // FIXME: fix error handling
            return Result.Failure(SpeltError.defaultError)
        }
        
        return Result.Success()
    }
}