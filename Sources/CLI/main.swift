import Commandant

struct SpeltError: Error {
    let underlyingError: Error
}

extension SpeltError: CustomStringConvertible {
    var description: String {
        return "\(underlyingError)"
    }
}

let registry = CommandRegistry<SpeltError>()
registry.register(BuildCommand())
registry.register(ServeCommand())
registry.register(NewCommand())
registry.register(VersionCommand())

let helpCommand = HelpCommand(registry: registry)
registry.register(helpCommand)

registry.main(defaultVerb: helpCommand.verb) { error in
    fputs(error.description + "\n", stderr)
}
