import SpeltKit
import Commandant
import Result

struct VersionCommand: CommandProtocol {
    let verb = "version"
    let function = "Display the current version of Spelt"
    
    func run(_ options: NoOptions<SpeltError>) -> Result<(), SpeltError> {
        let versionString = Bundle(identifier: SpeltKitBundleIdentifier)?.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        print("\(versionString)")
        return .success(())
    }
}
