import Witness

public typealias SiteChangeHandler = (sourcePath: String) -> ()

public class SiteObserver {
    var witness: Witness!
    
    public init(sourcePath: String, changeHandler handler: SiteChangeHandler) {
        witness = Witness(paths: [sourcePath], flags: .MarkSelf, latency: 0.3) { events in
            let combinedFlags = events.map({ $0.flags }).reduce(FileEventFlags.None, combine: { initial, value in
                return initial.union(value)
            })
            
            if combinedFlags.contains(.OwnEvent) == false {
                handler(sourcePath: sourcePath)
            }
        }
    }
}