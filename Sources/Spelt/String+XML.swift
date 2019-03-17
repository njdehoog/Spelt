import Foundation

extension String {
    var XMLEscapedString: String? {
        let escapedString = CFXMLCreateStringByEscapingEntities(nil, self as CFString, nil)
        return escapedString as String?
    }
}
