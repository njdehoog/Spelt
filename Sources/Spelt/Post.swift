// TODO: should Post just be a Document which belongs to posts collection by default?
public final class Post: FileWithMetadata {
    public enum Error: ErrorType {
        case MissingDate
    }
    
    public let path: String
    public var destinationPath: String?
    public var contents: String
    public var metadata: Metadata
    
    public init(path: String, contents: String = "", metadata: Metadata) throws {
        self.path = path
        self.contents = contents
        self.metadata = metadata
        
        guard self.date != nil else {
            throw Error.MissingDate
        }
    }
}

//extension Post {
//    public var categories: [String]? {
//        // FIXME: this should be in a rendering step
//        if let category = metadata["category"]?.stringValue {
//            return [category]
//        }
//        
//        if let categories = metadata["categories"]?.stringValue {
//            return categories.split(",").map() { $0.trim(" ") }
//        }
//        
//        if let categories = metadata["categories"]?.arrayValue {
//            var categoryNames = [String]()
//            for category in categories {
//                guard let stringValue = category.stringValue else  {
//                    return nil
//                }
//                categoryNames.append(stringValue)
//            }
//            return categoryNames
//        }
//        
//        return nil
//    }
//}
