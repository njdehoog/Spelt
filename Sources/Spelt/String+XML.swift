import Foundation

extension String {
    var XMLEscapedString: String {
        let escapedString = CFXMLCreateStringByEscapingEntities(nil, self, nil)
        return escapedString as String
    }
}