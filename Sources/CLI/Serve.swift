import SpeltKit
import Commandant
import Result

var server: SiteServer?

struct ServeCommand: CommandProtocol {
    typealias Options = BuildOptions
    
    let verb = "preview"
    let function = "Preview your site locally"
    
    func run(_ options: Options) -> Result<(), SpeltError> {
        do {
            try BuildCommand().build(options)
            server = SiteServer(directoryPath: options.destinationPath)
            let (_, port) = try server!.start()
            print("Preview your site at: http://0.0.0.0:\(port)")
        }
        catch {
            return Result.failure(SpeltError(underlyingError: error))
        }
        
        // keep process alive
        CFRunLoopRun()
        
        return Result.success()
    }
}
