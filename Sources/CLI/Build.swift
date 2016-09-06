import Commandant
import Result
import PathKit


struct BuildCommand: CommandType {
    struct Options: OptionsType {
        let sourcePath: String
        let destinationPath: String
        
        static func create(sourcePath: String) -> String -> Options {
            return { destinationPath in
                return Options(sourcePath: sourcePath, destinationPath: destinationPath);
            }
        }
        
        static func evaluate(m: CommandMode) -> Result<Options, CommandantError<SpeltError>> {
            return create
                <*> m <| Option(key: "source", defaultValue: "./", usage: "Source directory (defaults to ./)")
                <*> m <| Option(key: "destination", defaultValue: "./_build", usage: "Destination directory (defaults to ./_build)")
        }
    }
    
    let verb = "build"
    let function = "Build your site"
    
    func run(options: Options) -> Result<(), SpeltError> {
        
        print("Build command was run: \(options.sourcePath), \(options.destinationPath)")
        
        print("current path: \(Path.current)")
        
        return Result.Success()
    }
}