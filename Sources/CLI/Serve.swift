import SpeltKit
import Commandant
import Result

struct ServeCommand: CommandType {
    typealias Options = PathOptions
    
    let verb = "serve"
    let function = "Preview your site locally"
    
    func run(options: Options) -> Result<(), SpeltError> {
        let result = BuildCommand().run(options)
        switch result {
        case .Success(_):
            SiteServer(directoryPath: options.destinationPath).run()
        case .Failure(_):
            return result
        }
        
        return Result.Success()
    }
}