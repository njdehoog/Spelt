import SpeltKit
import Commandant
import Result


//let fixturesPath = "~/Projects/Spelt/framework/SpeltTests/Fixtures".stringByExpandingTildeInPath
//let sampleProjectPath = fixturesPath.stringByAppendingPathComponent("test-site")
//
//let site = try SiteReader(sitePath: sampleProjectPath).read()
//
////print("building site: \(site)")

struct SpeltError: ErrorType {
    let description = "Placeholder description"
}


let registry = CommandRegistry<SpeltError>()
registry.register(BuildCommand())

let helpCommand = HelpCommand(registry: registry)
registry.register(helpCommand)

registry.main(defaultVerb: helpCommand.verb) { error in
    fputs(error.description + "\n", stderr)
}