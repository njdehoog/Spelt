import Witness

public typealias SiteChangeHandler = (_ sourcePath: String) -> ()

public class SiteObserver {
    var witness: Witness!
    
    public init(sourcePath: String, changeHandler handler: @escaping SiteChangeHandler) {
        witness = Witness(paths: [sourcePath], flags: .MarkSelf, latency: 0.3) { events in
            let combinedFlags = events.map({ $0.flags }).reduce(FileEventFlags.None, { initial, value in
                return initial.union(value)
            })
            
            if combinedFlags.contains(.OwnEvent) == false {
                handler(sourcePath)
            }
        }
    }
}
