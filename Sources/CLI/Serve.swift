import SpeltKit
import Commandant
import Result

var server: SiteServer?

struct ServeCommand: CommandType {
    typealias Options = BuildOptions
    
    let verb = "preview"
    let function = "Preview your site locally"
    
    func run(options: Options) -> Result<(), SpeltError> {
        do {
            try BuildCommand().build(options)
            server = SiteServer(directoryPath: options.destinationPath)
            let (_, port) = try server!.start()
            print("Preview your site at: http://0.0.0.0:\(port)")
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
