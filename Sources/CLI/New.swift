import SpeltKit
import Commandant
import Result

struct NewCommand: CommandProtocol {
    struct Options: OptionsProtocol {
        let path: String
        let force: Bool
        
        static func create(_ path: String) -> (Bool) -> Options {
            return { force in
                return Options(path: path.absoluteStandardizedPath, force: force);
            }
        }
        
        static func evaluate(_ m: CommandMode) -> Result<Options, CommandantError<SpeltError>> {
            return create
                <*> m <| Argument(defaultValue: nil, usage: "PATH (where project should be created)")
                <*> m <| Option(key: "force", defaultValue: false, usage: "Force creation even if PATH already exists")
        }
    }
    
    let verb = "new"
    let function = "Create scaffolding for a new site"
    
    func run(_ options: Options) -> Result<(), SpeltError> {
        guard let templatePath = Bundle(identifier: SpeltKitBundleIdentifier)?.resourcePath?.stringByAppendingPathComponent("default-template") else {
            fatalError("Unable to locate template files")
        }
        
        do {
            print("Create project at path: \(options.path)")
            try SiteScaffolding(destinationPath: options.path, templatePath: templatePath).create(options.force)
        }
        catch {
            return Result.failure(SpeltError(underlyingError: error))
        }
        
        return Result.success(())
    }
}
