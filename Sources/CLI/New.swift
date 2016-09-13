import SpeltKit
import Commandant
import Result


struct NewCommand: CommandType {
    struct Options: OptionsType {
        let path: String
        let force: Bool
        
        static func create(path: String) -> Bool -> Options {
            return { force in
                return Options(path: path.absoluteStandardizedPath, force: force);
            }
        }
        
        static func evaluate(m: CommandMode) -> Result<Options, CommandantError<SpeltError>> {
            return create
                <*> m <| Argument(defaultValue: nil, usage: "PATH (where project should be created)")
                <*> m <| Option(key: "force", defaultValue: false, usage: "Force creation even if PATH already exists")
        }
    }
    
    let verb = "new"
    let function = "Create scaffolding for a new site"
    
    func run(options: Options) -> Result<(), SpeltError> {
        do {
            print("Create project at path: \(options.path)")
            try SiteScaffolding(path: options.path).create(options.force)
        }
        catch {
            return Result.Failure(SpeltError(underlyingError: error))
        }
        
        return Result.Success()
    }
}
