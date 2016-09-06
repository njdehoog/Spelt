import SpeltKit
import Commandant
import Result

struct ServeCommand: CommandType {
    let verb = "serve"
    let function = "Preview your site locally"
    
    func run(options: NoOptions<SpeltError>) -> Result<(), SpeltError> {
//        do {
//        
//        }
//        catch {
//            // FIXME: handle error
//            return Result.Failure(SpeltError.defaultError)
//        }
        
        SiteServer(directoryPath: NSFileManager().currentDirectoryPath).run()
        
        return Result.Success()
    }
}