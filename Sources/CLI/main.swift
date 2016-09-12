import Commandant

struct SpeltError: ErrorType {
    let underlyingError: ErrorType
}

extension SpeltError: CustomStringConvertible {
    var description: String {
        return "\(underlyingError)"
    }
}

let registry = CommandRegistry<SpeltError>()
registry.register(BuildCommand())
registry.register(ServeCommand())

let helpCommand = HelpCommand(registry: registry)
registry.register(helpCommand)

registry.main(defaultVerb: helpCommand.verb) { error in
    fputs(error.description + "\n", stderr)
}