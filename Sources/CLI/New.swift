import SpeltKit
import Commandant
import Result


struct NewCommand: CommandType {
    struct Options: OptionsType {
        let path: String
        
        static func create(path: String) -> Options {
            return Options(path: path.absoluteStandardizedPath);
        }
        
        static func evaluate(m: CommandMode) -> Result<Options, CommandantError<SpeltError>> {
            return create
                <*> m <| Argument(defaultValue: nil, usage: "PATH (where project should be created)")
        }
    }
    
    let verb = "new"
    let function = "Create scaffolding for a new site"
    
    func run(options: Options) -> Result<(), SpeltError> {
        
        print("create project at path: \(options.path)")
        
        return Result.Success()
    }
}
