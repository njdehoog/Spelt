import SpeltKit
import Commandant
import Result

struct ServeCommand: CommandType {
    typealias Options = BuildOptions
    
    let verb = "serve"
    let function = "Preview your site locally"
    
    func run(options: Options) -> Result<(), SpeltError> {
        do {
            try BuildCommand().build(options)
            SiteServer(directoryPath: options.destinationPath).run()
        }
        catch {
            return Result.Failure(SpeltError.defaultError)
        }
        
        if options.watch {
            // keep process alive
            CFRunLoopRun()
        }
        
        return Result.Success()
    }
}