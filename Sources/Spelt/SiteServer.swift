import GCDWebServers

public class SiteServer {
    private lazy var server = GCDWebServer()
    let directoryPath: String
    let indexFilename: String
    
    public init(directoryPath: String, indexFilename: String = "index.html") {
        self.directoryPath = directoryPath
        self.indexFilename = indexFilename
        
        // log only warnings, errors and exceptions
//        GCDWebServer.setLogLevel(3)
    }
    
    deinit {
        server.stop()
    }
    
    public func run() -> Bool {
        server.addGETHandlerForBasePath("/", directoryPath: directoryPath, indexFilename: indexFilename , cacheAge: 0, allowRangeRequests: true)
        return server.runWithPort(8080, bonjourName: nil)
    }
}