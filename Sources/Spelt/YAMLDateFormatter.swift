import Foundation

/**
* YAMLDateFormatter parses dates according to format defined by Jekyll. See: http://jekyllrb.com/docs/frontmatter/
*/

public struct YAMLDateFormatter {
    static let dateFormatter = DateFormatter()
    static let allowedDateFormats = ["YYYY-MM-dd HH:mm:ss ZZZ", "YYYY-MM-dd HH:mm:ss", "YYYY-MM-dd HH:mm", "YYYY-MM-dd HH", "YYYY-MM-dd"]
    
    public static func dateFromString(_ string: String) -> Date? {
        for dateFormat in allowedDateFormats {
            if let date = tryFormat(dateFormat, dateString: string) {
                return date
            }
        }
        
        return nil
    }
    
    public static func stringFromDate(_ date: Date) -> String {
        dateFormatter.dateFormat = allowedDateFormats[0]
        return dateFormatter.string(from: date)
    }
    
    fileprivate static func tryFormat(_ format: String, dateString: String) -> Date? {
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
    }
}
