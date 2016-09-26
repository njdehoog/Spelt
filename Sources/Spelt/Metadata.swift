import SwiftYAML

public enum Metadata {
    case none
    case string(Swift.String)
    case bool(Swift.Bool)
    case int(Swift.Int)
    case double(Swift.Double)
    case date(Foundation.Date)
    indirect case file(SpeltKit.FileWithMetadata)
    case array([SpeltKit.Metadata])
    case dictionary([Swift.String: SpeltKit.Metadata])
}

extension Metadata {
    var stringValue: Swift.String? {
        if case .string(let string) = self {
            return string
        }
        return nil
    }
    
    var arrayValue: [Metadata]? {
        if case .array(let array) = self {
            return array
        }
        return nil
    }
    
    var dictionaryValue: [Swift.String: Metadata]? {
        if case .dictionary(let dictionary) = self {
            return dictionary
        }
        return nil
    }
    
    var fileValue: SpeltKit.File? {
        if case .file(let file) = self {
            return file
        }
        return nil
    }
    
    var boolValue: Swift.Bool? {
        if case .bool(let bool) = self {
            return bool
        }
        
        return nil
    }
    
    var intValue: Swift.Int? {
        if case .int(let int) = self {
            return int
        }
        
        return nil
    }
}

extension Metadata {
    public subscript(key: Swift.String) -> Metadata? {
        get {
            switch self {
            case .dictionary(let dictionary):
                return dictionary[key]
            default:
                return nil
            }
        }
        set {
            switch self {
            case .dictionary(var dictionary):
                dictionary[key] = newValue
                self = .dictionary(dictionary)
            default:
                assert(false, "Can't use subscript on type which is not a dictionary")
            }
        }
    }
}

extension Metadata: Hashable {
    public var hashValue: Swift.Int {
        switch self {
        case .none:
            return 0
        case .string(let string):
            return string.hash
        case .bool(let bool):
            return bool.hashValue
        case .int(let int):
            return int.hashValue
        case .double(let Double):
            return Double.hashValue
        case .date(let date):
            return (date as NSDate).hash
        case .file(let file):
            return file.path.hash
        case .array(let array):
            return array.reduce(0, { $0 ^ $1.hashValue })
        case .dictionary(let dictionary):
            return dictionary.keys.reduce(0) { $0 ^ $1.hashValue }
        }
    }
}

extension Metadata: Equatable {}
public func == (lhs: Metadata, rhs: Metadata) -> Bool {
    var equal = false
    switch lhs {
    case .none:
        if case .none = rhs { equal = true }
    case .string(let lv):
        if case .string(let rv) = rhs { equal = (lv == rv) }
    case .bool(let lv):
        if case .bool(let rv) = rhs { equal = (lv == rv) }
    case .int(let lv):
        if case .int(let rv) = rhs { equal = (lv == rv) }
    case .double(let lv):
        if case .double(let rv) = rhs { equal = (lv == rv) }
    case .date(let lv):
        if case .date(let rv) = rhs { equal = lv == rv }
    case .file(let lv):
        if case .file(let rv) = rhs { equal = (lv.path == rv.path && lv.destinationPath == rv.destinationPath) }
    case .array(let lv):
        if case .array(let rv) = rhs { equal = (lv == rv) }
    case .dictionary(let lv):
        if case .dictionary(let rv) = rhs { equal = (lv == rv) }
    }
    return equal
}

extension Metadata: Comparable {}
public func < (lhs: Metadata, rhs: Metadata) -> Bool {
    var smallerThan = false
    switch lhs {
    case .none:
        break
    case .string(let lv):
        if case .string(let rv) = rhs { smallerThan = (lv < rv) }
    case .bool(_):
        break
    case .int(let lv):
        if case .int(let rv) = rhs { smallerThan = (lv < rv) }
    case .double(let lv):
        if case .double(let rv) = rhs { smallerThan = (lv < rv) }
    case .date(let lv):
        if case .date(let rv) = rhs { smallerThan = (lv.compare(rv) == .orderedAscending) }
    case .file(let lv):
        if case .file(let rv) = rhs { smallerThan = (lv.metadata < rv.metadata) }
    case .array(_):
        break
    case .dictionary(_):
        break
    }
    return smallerThan
}

public func +(lhs: Metadata, rhs: Metadata) -> Metadata {
    switch lhs {
    case .none:
        return rhs
    case .string(let lv):
        if case .string(let rv) = rhs {
            return .string(lv + rv)
        }
    case .bool(_):
        break
    case .int(let lv):
        if case .int(let rv) = rhs {
            return .int(lv + rv)
        }
    case .double(let lv):
        if case .double(let rv) = rhs {
            return .double(lv + rv)
        }
    case .date(_):
        assert(false, "Can't add two metadata parameters of type .Date")
    case .file(_):
        assert(false, "Can't add two metadata parameters of type .File")
    case .array(let lv):
        if case .array(let rv) = rhs {
            return .array(lv + rv)
        }
    case .dictionary(let lv):
        if case .dictionary(let rv) = rhs {
            return .dictionary(lv + rv)
        }
    }
    
    if case .none = rhs {
        return lhs
    }
    
    return .none
}

public protocol MetadataConvertible {
    var metadata: Metadata { get }
}

extension Metadata: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .none
    }
}


extension Metadata: ExpressibleByBooleanLiteral {
    public init(booleanLiteral: BooleanLiteralType) {
        self = .bool(booleanLiteral)
    }
}

extension Metadata: ExpressibleByIntegerLiteral {
    public init(integerLiteral: IntegerLiteralType) {
        self = .int(integerLiteral)
    }
}

//extension Metadata: FloatLiteralConvertible {
//    public init(floatLiteral value: Self.FloatLiteralType) {
//        self = .Double(floatLiteral)
//    }
//}

extension Metadata: ExpressibleByStringLiteral {
    public init(stringLiteral: StringLiteralType) {
        self = .string(stringLiteral)
    }
    
    public init(extendedGraphemeClusterLiteral: StringLiteralType) {
        self = .string(extendedGraphemeClusterLiteral)
    }
    
    public init(unicodeScalarLiteral: StringLiteralType) {
        self = .string(unicodeScalarLiteral)
    }
}

extension Metadata: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Metadata...) {
        var array = [Metadata]()
        array.reserveCapacity(elements.count)
        for element in elements {
            array.append(element)
        }
        self = .array(array)
    }
}

extension Metadata: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Swift.String, Metadata)...) {
        var dictionary: [Swift.String: Metadata] = [:]
        for (k, v) in elements {
            dictionary[k] = v
        }
        self = .dictionary(dictionary)
    }
}

extension YAMLValue: MetadataConvertible {
    public var metadata: Metadata {
        switch self {
        case .none:
            return .none
        case .string(let string):
            return .string(string)
        case .bool(let bool):
            return .bool(bool)
        case .int(let int):
            return .int(int)
        case .double(let double):
            return .double(double)
        case .array(let array):
            var metadata = [Metadata]()
            for item in array {
                metadata.append(item.metadata)
            }
            return Metadata.array(metadata)
        case .dictionary(let dictionary):
            var metadata: [Swift.String: Metadata] = [:]
            for (k, v) in dictionary {
                if case .string(let string) = k {
                    metadata[string] = v.metadata
                }
            }
            return Metadata.dictionary(metadata)
        }
    }
}

extension Metadata {
    public var rawValue: Any {
        switch self {
        case .none:
            return ""
        case .string(let string):
            return string
        case .bool(let bool):
            return bool
        case .int(let int):
            return int
        case .double(let double):
            return double
        case .date(let date):
            return date
        case .file(let file):
            return file.payload
        case .array(let array):
            var raw: [Any] = []
            for element in array {
                raw.append(element.rawValue)
            }
            return raw
        case .dictionary(let dictionary):
            var boxed: [Swift.String: Any] = [:]
            for (k, v) in dictionary {
                boxed[k] = v.rawValue
            }
            return boxed
        }
    }
}

extension Metadata {    
    init(files: [FileWithMetadata]) {
        let fileArray: [Metadata] = files.map({ Metadata.file($0) })
        self = Metadata.array(fileArray)
    }
}

