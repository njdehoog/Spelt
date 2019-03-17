class SpeltExtension: Extension {
    static func defaultExtension() -> Extension {
        let defaultExtension = SpeltExtension()
        defaultExtension.registerFilter("date", filter:dateFilter)
        defaultExtension.registerFilter("date_to_string", filter: dateToStringFilter)
        defaultExtension.registerFilter("date_to_rfc822", filter: dateToRFC822Filter)
        defaultExtension.registerFilter("date_to_xmlschema", filter: dateToXMLSchemaFilter)
        defaultExtension.registerFilter("markdownify", filter: markdownFilter)
        defaultExtension.registerFilter("xml_escape", filter: xmlEscapeFilter)
        defaultExtension.registerFilter("url_encode", filter: URLEncodeFilter)
        defaultExtension.registerFilter("prepend", filter: prependFilter)
        defaultExtension.registerFilter("append", filter: appendFilter)
        defaultExtension.registerFilter("replace", filter: replaceFilter)
        defaultExtension.registerFilter("remove", filter: removeFilter)
        defaultExtension.registerFilter("strip_html", filter: stripHTMLFilter)
        defaultExtension.registerFilter("strip_newlines", filter: stripNewlinesFilter)
        defaultExtension.registerFilter("truncate", filter: truncateFilter)
        defaultExtension.registerFilter("join", filter: joinFilter)
        defaultExtension.registerFilter("array_to_sentence_string", filter: arrayToSentenceStringFilter)
        defaultExtension.registerFilter("number_of_words", filter: numberOfWordsFilter)
        defaultExtension.registerFilter("divided_by", filter: dividedByFilter)
        defaultExtension.registerFilter("floor", filter: floorFilter)
        defaultExtension.registerFilter("ceil", filter: ceilFilter)
        defaultExtension.registerFilter("default", filter: defaultFilter)
        
        defaultExtension.registerTag("gist", parser: gistTag)
        defaultExtension.registerTag("katex", parser: KaTexNode.parse)
        defaultExtension.registerTag("raw", parser: RawNode.parse)
        return defaultExtension
    }
}

func markdownFilter(_ value: Any?) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'markdown' filter expects string input")
    }
    return MarkdownConverter.htmlFromMarkdown(string)
}

func dateFilter(_ value: Any?, arguments: [Any?]) throws -> Any? {
    guard let date = value as? Date else {
        throw TemplateSyntaxError("'date' filter expects input value to be of type NSDate, not \(type(of: value))")
    }
    
    guard let format = arguments.first as? String else {
        throw TemplateSyntaxError("'date' filter expects format argument as string")
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
}

func dateToStringFilter(_ value: Any?) throws -> Any? {
    guard let date = value as? Date else {
        throw TemplateSyntaxError("'date_to_string' filter expects input value to be of type NSDate")
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    return dateFormatter.string(from: date)
}

func dateToRFC822Filter(_ value: Any?) throws -> Any? {
    guard let date = value as? Date else {
        throw TemplateSyntaxError("'date_to_rfc822' filter expects input value to be of type NSDate")
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
    return dateFormatter.string(from: date)
}

func dateToXMLSchemaFilter(_ value: Any?) throws -> Any? {
    guard let date = value as? Date else {
        throw TemplateSyntaxError("'date_to_xmlschema' filter expects input value to be of type NSDate")
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ" // ISO8601 format
    return dateFormatter.string(from: date)
}

func xmlEscapeFilter(_ value: Any?) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'xml_escape' filter expects string input")
    }
    return string.XMLEscapedString
}

func URLEncodeFilter(_ value: Any?) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'url_encode' filter expects string input")
    }
    return string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
}

func prependFilter(_ value: Any?, arguments: [Any?]) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'prepend' filter expects string input")
    }
    
    guard let stringToPrepend = arguments.first as? String else {
        throw TemplateSyntaxError("'prepend' filter expects string argument")
    }
    
    return stringToPrepend + string
}

func appendFilter(_ value: Any?, arguments: [Any?]) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'prepend' filter expects string input")
    }
    
    guard let stringToAppend = arguments.first as? String else {
        throw TemplateSyntaxError("'prepend' filter expects string argument")
    }
    
    return string + stringToAppend
}

func replaceFilter(_ value: Any?, arguments: [Any?]) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'replace' filter expects string input")
    }
    
    guard arguments.count == 2 else {
        return TemplateSyntaxError("'replace' filter expects 2 arguments")
    }
    
    guard let stringToReplace = arguments.first as? String, let substitute = arguments.last as? String else {
        return TemplateSyntaxError("'replace' filter expects string arguments")
    }
    
    return string.replacingOccurrences(of: stringToReplace, with: substitute)
}


func removeFilter(_ value: Any?, arguments: [Any?]) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'remove' filter expects string input")
    }
    
    guard let stringToRemove = arguments.first as? String else {
        throw TemplateSyntaxError("'remove' filter expects string argument")
    }
    
    return string.replacingOccurrences(of: stringToRemove, with: "")
}

func stripHTMLFilter(_ value: Any?) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'strip_html' filter expects string input")
    }
    return string.stripHTML()
}

func stripNewlinesFilter(_ value: Any?) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'strip_newlines' filter expects string input")
    }
    return string.components(separatedBy: CharacterSet.newlines).joined(separator: "")
}

func truncateFilter(_ value: Any?, arguments: [Any?]) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'truncate' filter expects string input")
    }
    
    guard let numberOfCharacters = arguments.first as? Int else {
        throw TemplateSyntaxError("'truncate' filter expects integer argument")
    }
    
    guard let endIndex = string.characters.index(string.startIndex, offsetBy: numberOfCharacters, limitedBy: string.endIndex) else {
        return string
    }
    return string[string.startIndex..<endIndex]
}

func arrayToSentenceStringFilter(_ value: Any?) throws -> Any? {
    guard let array = value as? [Any] else {
        return TemplateSyntaxError("'array_to_sentence' filter expects array input")
    }
    
    let stringArray = array.reduce([String]()) { strings, value in
        if let string = value as? String {
            return strings + [string]
        }
        return strings
    }
    
    switch stringArray.count {
    case 0:
        return ""
    case 1:
        return stringArray.first
    case 2:
        return stringArray.joined(separator: " and ")
    default:
        let slice = stringArray[0..<(array.endIndex - 1)]
        return "\(slice.joined(separator: ", ")) and \(stringArray.last!)"
    }
}

func numberOfWordsFilter(_ value: Any?) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'number_of_words' filter expects string input")
    }
    
    return string.components(separatedBy: CharacterSet.whitespaces).count
}

func gistTag(_ parser: TokenParser, token: Token) throws -> NodeType {
    let components = token.components
    guard components.count >= 2 && components.count < 4 else {
        throw TemplateSyntaxError("'gist' tags should have between 1 and 2 arguments`\(token.contents)`.")
    }
    
    let embedString: String
    if components.count == 3 {
        embedString = "<script src=\"https://gist.github.com/\(components[1]).js?file=\(components[2])\"></script>"
    }
    else {
        embedString = "<script src=\"https://gist.github.com/\(components[1]).js\"></script>"
    }
    
    return TextNode(text: embedString)
}

public class KaTexNode : NodeType {
    public var token: Token?  // Shouldn't this return something? How is this expected to be used?
    
    public let mathNodes:[NodeType]
    public let inline: Bool
    
    public class func parse(parser:TokenParser, token:Token) throws -> NodeType {
        let components = token.components
        guard components.count == 1 || components.count == 2 else {
            throw TemplateSyntaxError("'katex' tags should use the following syntax: 'katex (inline: true)'")
        }
        
        var inline: Bool = false
        if components.count == 2 {
            let inlineComponents = components[1].split(separator: ":").map {
                String($0).trimmingCharacters(in: .whitespaces)    
            }
            guard inlineComponents.count == 2 && inlineComponents.first! == "inline" else {
                throw TemplateSyntaxError("Invalid argument in katex tag '\(components.last!)'")
            }
            switch inlineComponents[1] {
            case "true":
                inline = true
            case "false":
                inline = false
            default:
                throw TemplateSyntaxError("Unexpected value for argument 'inline' in katex tag '\(inlineComponents.first!)'")
            }
        }
        
        let mathNodes = try parser.parse(until(["endkatex"]))
        guard parser.nextToken() != nil else {
            throw TemplateSyntaxError("`endkatex` was not found.")
        }
        
        return KaTexNode(mathNodes: mathNodes, inline: inline)
    }
    
    public init(mathNodes:[NodeType], inline: Bool) {
        self.mathNodes = mathNodes
        self.inline = inline
    }
    
    public func render(_ context: Context) throws -> String {
        return try context.push() {
            let output = try renderNodes(mathNodes, context)
            if inline {
                return "<script type=\"math/tex\">\(output)</script>"
            }
            else {
                return "<script type=\"math/tex; mode=display\">\(output)</script>"
            }
        }
    }
}

public class RawNode : NodeType {
    public var token: Token? // Shouldn't this return something? How is this expected to be used?
    
    public let rawNodes:[NodeType]
    
    public class func parse(parser:TokenParser, token:Token) throws -> NodeType {
        let components = token.components
        guard components.count == 1 else {
            throw TemplateSyntaxError("'raw' tags do not accept arguments")
        }
        
        let rawNodes = try parser.parse(until(["endraw"]))
        guard parser.nextToken() != nil else {
            throw TemplateSyntaxError("`endraw` was not found.")
        }
        
        return RawNode(rawNodes: rawNodes)
    }
    
    public init(rawNodes:[NodeType]) {
        self.rawNodes = rawNodes
    }
    
    public func render(_ context: Context) throws -> String {
        return try context.push() {
            return try renderNodes(rawNodes, context)
        }
    }
}


