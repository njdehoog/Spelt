import Foundation

/**
* YAMLDateFormatter parses dates according to format defined by Jekyll. See: http://jekyllrb.com/docs/frontmatter/
*/

public struct YAMLDateFormatter {
    static let dateFormatter = NSDateFormatter()
    static let allowedDateFormats = ["YYYY-MM-dd HH:mm:ss ZZZ", "YYYY-MM-dd HH:mm:ss", "YYYY-MM-dd HH:mm", "YYYY-MM-dd HH", "YYYY-MM-dd"]
    
    public static func dateFromString(string: String) -> NSDate? {
        for dateFormat in allowedDateFormats {
            if let date = tryFormat(dateFormat, dateString: string) {
                return date
            }
        }
        
        return nil
    }
    
    public static func stringFromDate(date: NSDate) -> String {
        dateFormatter.dateFormat = allowedDateFormats[0]
        return dateFormatter.stringFromDate(date)
    }
    
    private static func tryFormat(format: String, dateString: String) -> NSDate? {
        dateFormatter.dateFormat = format
        return dateFormatter.dateFromString(dateString)
    }
}