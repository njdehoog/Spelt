public final class StaticFile: File {
    public let path: String
    public var destinationPath: String?
    
    init(path: String) {
        self.path = path
    }
}