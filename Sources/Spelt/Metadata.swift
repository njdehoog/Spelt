import SwiftYAML

public enum Metadata {
    case None
    case String(Swift.String)
    case Bool(Swift.Bool)
    case Int(Swift.Int)
    case Double(Swift.Double)
    case Date(NSDate)
    indirect case File(SpeltKit.FileWithMetadata)
    case Array([SpeltKit.Metadata])
    case Dictionary([Swift.String: SpeltKit.Metadata])
}

extension Metadata {
    var stringValue: Swift.String? {
        if case .String(let string) = self {
            return string
        }
        return nil
    }
    
    var arrayValue: [Metadata]? {
        if case .Array(let array) = self {
            return array
        }
        return nil
    }
    
    var dictionaryValue: [Swift.String: Metadata]? {
        if case .Dictionary(let dictionary) = self {
            return dictionary
        }
        return nil
    }
    
    var fileValue: SpeltKit.File? {
        if case .File(let file) = self {
            return file
        }
        return nil
    }
    
    var boolValue: Swift.Bool? {
        if case .Bool(let bool) = self {
            return bool
        }
        
        return false
    }
}

extension Metadata {
    public subscript(key: Swift.String) -> Metadata? {
        get {
            switch self {
            case .Dictionary(let dictionary):
                return dictionary[key]
            default:
                return nil
            }
        }
        set {
            switch self {
            case .Dictionary(var dictionary):
                dictionary[key] = newValue
                self = .Dictionary(dictionary)
            default:
                assert(false, "Can't use subscript on type which is not a dictionary")
            }
        }
    }
}

extension Metadata: Hashable {
    public var hashValue: Swift.Int {
        switch self {
        case .None:
            return 0
        case .String(let string):
            return string.hash
        case .Bool(let bool):
            return bool.hashValue
        case .Int(let int):
            return int.hashValue
        case .Double(let Double):
            return Double.hashValue
        case .Date(let date):
            return date.hash
        case .File(let file):
            return file.path.hash
        case .Array(let array):
            return array.reduce(0, combine: { $0 ^ $1.hashValue })
        case .Dictionary(let dictionary):
            return dictionary.keys.reduce(0) { $0 ^ $1.hashValue }
        }
    }
}

extension Metadata: Equatable {}
public func == (lhs: Metadata, rhs: Metadata) -> Bool {
    var equal = false
    switch lhs {
    case .None:
        if case .None = rhs { equal = true }
    case .String(let lv):
        if case .String(let rv) = rhs { equal = (lv == rv) }
    case .Bool(let lv):
        if case .Bool(let rv) = rhs { equal = (lv == rv) }
    case .Int(let lv):
        if case .Int(let rv) = rhs { equal = (lv == rv) }
    case .Double(let lv):
        if case .Double(let rv) = rhs { equal = (lv == rv) }
    case .Date(let lv):
        if case .Date(let rv) = rhs { equal = lv.isEqualToDate(rv) }
    case .File(_):
        break
//         FIXME: equality comparison does not work for files
//        if case .File(let rv) = rhs { equal = (lv == rv) }
    case .Array(let lv):
        if case .Array(let rv) = rhs { equal = (lv == rv) }
    case .Dictionary(let lv):
        if case .Dictionary(let rv) = rhs { equal = (lv == rv) }
    }
    return equal
}

extension Metadata: Comparable {}
public func < (lhs: Metadata, rhs: Metadata) -> Bool {
    var smallerThan = false
    switch lhs {
    case .None:
        break
    case .String(let lv):
        if case .String(let rv) = rhs { smallerThan = (lv < rv) }
    case .Bool(_):
        break
    case .Int(let lv):
        if case .Int(let rv) = rhs { smallerThan = (lv < rv) }
    case .Double(let lv):
        if case .Double(let rv) = rhs { smallerThan = (lv < rv) }
    case .Date(let lv):
        if case .Date(let rv) = rhs { smallerThan = (lv.compare(rv) == .OrderedAscending) }
    case .File(let lv):
        if case .File(let rv) = rhs { smallerThan = (lv.metadata < rv.metadata) }
    case .Array(_):
        break
    case .Dictionary(_):
        break
    }
    return smallerThan
}

public func +(lhs: Metadata, rhs: Metadata) -> Metadata {
    switch lhs {
    case .None:
        return rhs
    case .String(let lv):
        if case .String(let rv) = rhs {
            return .String(lv + rv)
        }
    case .Bool(_):
        break
    case .Int(let lv):
        if case .Int(let rv) = rhs {
            return .Int(lv + rv)
        }
    case .Double(let lv):
        if case .Double(let rv) = rhs {
            return .Double(lv + rv)
        }
    case .Date(_):
        assert(false, "Can't add two metadata parameters of type .Date")
    case .File(_):
        assert(false, "Can't add two metadata parameters of type .File")
    case .Array(let lv):
        if case .Array(let rv) = rhs {
            return .Array(lv + rv)
        }
    case .Dictionary(let lv):
        if case .Dictionary(let rv) = rhs {
            return .Dictionary(lv + rv)
        }
    }
    
    if case .None = rhs {
        return lhs
    }
    
    return .None
}

public protocol MetadataConvertible {
    var metadata: Metadata { get }
}

extension Metadata: NilLiteralConvertible {
    public init(nilLiteral: ()) {
        self = .None
    }
}


extension Metadata: BooleanLiteralConvertible {
    public init(booleanLiteral: BooleanLiteralType) {
        self = .Bool(booleanLiteral)
    }
}

extension Metadata: IntegerLiteralConvertible {
    public init(integerLiteral: IntegerLiteralType) {
        self = .Int(integerLiteral)
    }
}

//extension Metadata: FloatLiteralConvertible {
//    public init(floatLiteral value: Self.FloatLiteralType) {
//        self = .Double(floatLiteral)
//    }
//}

extension Metadata: StringLiteralConvertible {
    public init(stringLiteral: StringLiteralType) {
        self = .String(stringLiteral)
    }
    
    public init(extendedGraphemeClusterLiteral: StringLiteralType) {
        self = .String(extendedGraphemeClusterLiteral)
    }
    
    public init(unicodeScalarLiteral: StringLiteralType) {
        self = .String(unicodeScalarLiteral)
    }
}

extension Metadata: ArrayLiteralConvertible {
    public init(arrayLiteral elements: Metadata...) {
        var array = [Metadata]()
        array.reserveCapacity(elements.count)
        for element in elements {
            array.append(element)
        }
        self = .Array(array)
    }
}

extension Metadata: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (Swift.String, Metadata)...) {
        var dictionary: [Swift.String: Metadata] = [:]
        for (k, v) in elements {
            dictionary[k] = v
        }
        self = .Dictionary(dictionary)
    }
}

extension YAMLValue: MetadataConvertible {
    public var metadata: Metadata {
        switch self {
        case .None:
            return .None
        case .String(let string):
            return .String(string)
        case .Bool(let bool):
            return .Bool(bool)
        case .Int(let int):
            return .Int(int)
        case .Double(let double):
            return .Double(double)
        case .Array(let array):
            var metadata = [Metadata]()
            for item in array {
                metadata.append(item.metadata)
            }
            return Metadata.Array(metadata)
        case .Dictionary(let dictionary):
            var metadata: [Swift.String: Metadata] = [:]
            for (k, v) in dictionary {
                if case .String(let string) = k {
                    metadata[string] = v.metadata
                }
            }
            return Metadata.Dictionary(metadata)
        }
    }
}

extension Metadata {
    public var rawValue: Any {
        switch self {
        case .None:
            return ""
        case .String(let string):
            return string
        case .Bool(let bool):
            return bool
        case .Int(let int):
            return int
        case .Double(let double):
            return double
        case .Date(let date):
            return date
        case .File(let file):
            return file.metadata.rawValue
        case .Array(let array):
            var raw: [Any] = []
            for element in array {
                raw.append(element.rawValue)
            }
            return raw
        case .Dictionary(let dictionary):
            var boxed: [Swift.String: Any] = [:]
            for (k, v) in dictionary {
                boxed[k] = v.rawValue
            }
            return boxed
        }
    }
}

extension Metadata {
    // FIXME: this should be an array of FileWithMetadata
     init(posts: [Post]) {
        let fileArray: [Metadata] = posts.map({ Metadata.File($0) })
        self = Metadata.Array(fileArray)
    }
}

