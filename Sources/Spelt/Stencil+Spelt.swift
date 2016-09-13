extension Namespace {
    static func defaultNamespace() -> Namespace {
        let namespace = Namespace()
        namespace.registerFilter("date", filter: Filter(dateFilter))
        namespace.registerFilter("date_to_string", filter: Filter(dateToStringFilter))
        namespace.registerFilter("date_to_rfc822", filter: Filter(dateToRFC822Filter))
        namespace.registerFilter("date_to_xmlschema", filter: Filter(dateToXMLSchemaFilter))
        namespace.registerFilter("markdownify", filter: Filter(markdownFilter))
        namespace.registerFilter("xml_escape", filter: Filter(xmlEscapeFilter))
        namespace.registerFilter("url_encode", filter: Filter(URLEncodeFilter))
        namespace.registerFilter("prepend", filter: Filter(prependFilter))
        namespace.registerFilter("append", filter: Filter(appendFilter))
        namespace.registerFilter("replace", filter: Filter(replaceFilter))
        namespace.registerFilter("remove", filter: Filter(removeFilter))
        namespace.registerFilter("strip_html", filter: Filter(stripHTMLFilter))
        namespace.registerFilter("strip_newlines", filter: Filter(stripNewlinesFilter))
        namespace.registerFilter("truncate", filter: Filter(truncateFilter))
        namespace.registerFilter("join", filter: Filter(joinFilter))
        namespace.registerFilter("array_to_sentence_string", filter: Filter(arrayToSentenceStringFilter))
        namespace.registerFilter("number_of_words", filter: Filter(numberOfWordsFilter))
        namespace.registerFilter("divided_by", filter: Filter(dividedByFilter))
        namespace.registerFilter("floor", filter: Filter(floorFilter))
        namespace.registerFilter("ceil", filter: Filter(ceilFilter))
        namespace.registerFilter("default", filter: Filter(defaultFilter))
        
        namespace.registerTag("gist", parser: gistTag)
        namespace.registerTag("katex", parser: KaTexNode.parse)
        namespace.registerTag("raw", parser: RawNode.parse)
        
        return namespace
    }
}

func markdownFilter(value: Any?) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'markdown' filter expects string input")
    }
    return MarkdownConverter.htmlFromMarkdown(string)
}

func dateFilter(value: Any?, arguments: [Any?]) throws -> Any? {
    guard let date = value as? NSDate else {
        print(value as? String)
        throw TemplateSyntaxError("'date' filter expects input value to be of type NSDate, not \(value.dynamicType)")
    }
    
    guard let format = arguments.first as? String else {
        throw TemplateSyntaxError("'date' filter expects format argument as string")
    }
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.stringFromDate(date)
}

func dateToStringFilter(value: Any?) throws -> Any? {
    guard let date = value as? NSDate else {
        throw TemplateSyntaxError("'date_to_string' filter expects input value to be of type NSDate")
    }
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = .LongStyle
    return dateFormatter.stringFromDate(date)
}

func dateToRFC822Filter(value: Any?) throws -> Any? {
    guard let date = value as? NSDate else {
        throw TemplateSyntaxError("'date_to_rfc822' filter expects input value to be of type NSDate")
    }
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
    return dateFormatter.stringFromDate(date)
}

func dateToXMLSchemaFilter(value: Any?) throws -> Any? {
    guard let date = value as? NSDate else {
        throw TemplateSyntaxError("'date_to_xmlschema' filter expects input value to be of type NSDate")
    }
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ" // ISO8601 format
    return dateFormatter.stringFromDate(date)
}

func xmlEscapeFilter(value: Any?) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'xml_escape' filter expects string input")
    }
    return string.XMLEscapedString
}

func URLEncodeFilter(value: Any?) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'url_encode' filter expects string input")
    }
    return string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
}

func prependFilter(value: Any?, arguments: [Any?]) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'prepend' filter expects string input")
    }
    
    guard let stringToPrepend = arguments.first as? String else {
        throw TemplateSyntaxError("'prepend' filter expects string argument")
    }
    
    return stringToPrepend + string
}

func appendFilter(value: Any?, arguments: [Any?]) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'prepend' filter expects string input")
    }
    
    guard let stringToAppend = arguments.first as? String else {
        throw TemplateSyntaxError("'prepend' filter expects string argument")
    }
    
    return string + stringToAppend
}

func replaceFilter(value: Any?, arguments: [Any?]) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'replace' filter expects string input")
    }
    
    guard arguments.count == 2 else {
        return TemplateSyntaxError("'replace' filter expects 2 arguments")
    }
    
    guard let stringToReplace = arguments.first as? String, let substitute = arguments.last as? String else {
        return TemplateSyntaxError("'replace' filter expects string arguments")
    }
    
    return string.stringByReplacingOccurrencesOfString(stringToReplace, withString: substitute)
}


func removeFilter(value: Any?, arguments: [Any?]) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'remove' filter expects string input")
    }
    
    guard let stringToRemove = arguments.first as? String else {
        throw TemplateSyntaxError("'remove' filter expects string argument")
    }
    
    return string.stringByReplacingOccurrencesOfString(stringToRemove, withString: "")
}

func stripHTMLFilter(value: Any?) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'strip_html' filter expects string input")
    }
    return string.stripHTML()
}

func stripNewlinesFilter(value: Any?) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'strip_newlines' filter expects string input")
    }
    return string.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).joinWithSeparator("")
}

func truncateFilter(value: Any?, arguments: [Any?]) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'truncate' filter expects string input")
    }
    
    guard let numberOfCharacters = arguments.first as? Int else {
        throw TemplateSyntaxError("'truncate' filter expects integer argument")
    }
    
    let endIndex = string.startIndex.advancedBy(numberOfCharacters, limit: string.endIndex)
    return string[string.startIndex..<endIndex]
}

func joinFilter(value: Any?, arguments: [Any?]) throws -> Any? {
    guard let array = value as? [Any] else {
        return TemplateSyntaxError("'join' filter expects array input")
    }
    
    let stringArray = array.reduce([String]()) { strings, value in
        if let string = value as? String {
            return strings + [string]
        }
        return strings
    }
    
    guard stringArray.isEmpty == false else {
        return TemplateSyntaxError("'join' filter expects array of strings")
    }
    
    guard let separator = arguments.first as? String else {
        throw TemplateSyntaxError("'join' filter expects separator as argument")
    }
    
    return stringArray.joinWithSeparator(separator)
}

func arrayToSentenceStringFilter(value: Any?) throws -> Any? {
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
        return stringArray.joinWithSeparator(" and ")
    default:
        let slice = stringArray[0..<array.endIndex.predecessor()]
        return "\(slice.joinWithSeparator(", ")) and \(stringArray.last!)"
    }
}

func numberOfWordsFilter(value: Any?) throws -> Any? {
    guard let string = value as? String else {
        return TemplateSyntaxError("'number_of_words' filter expects string input")
    }
    
    return string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).count
}

func defaultFilter(value: Any?, arguments: [Any?]) throws -> Any? {
    guard arguments.count == 1 else {
        return TemplateSyntaxError("'default' filter expects (only) one argument")
    }
    
    if value == nil {
        return arguments.first
    }
    
    return value
}

func gistTag(parser: TokenParser, token: Token) throws -> NodeType {
    let components = token.components()
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
    public let mathNodes:[NodeType]
    public let inline: Bool
    
    public class func parse(parser:TokenParser, token:Token) throws -> NodeType {
        let components = token.components()
        guard components.count == 1 || components.count == 2 else {
            throw TemplateSyntaxError("'katex' tags should use the following syntax: 'katex (inline: true)'")
        }
        
        var inline: Bool = false
        if components.count == 2 {
            let inlineComponents = components[1].splitAndTrimWhitespace(":")
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
    
    public func render(context: Context) throws -> String {
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
    public let rawNodes:[NodeType]
    
    public class func parse(parser:TokenParser, token:Token) throws -> NodeType {
        let components = token.components()
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
    
    public func render(context: Context) throws -> String {
        return try context.push() {
            return try renderNodes(rawNodes, context)
        }
    }
}


