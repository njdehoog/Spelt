import Commandant

enum SpeltError: ErrorType {
    case defaultError
    
    var description: String {
        switch self {
        case .defaultError:
            // FIXME
            return "Some error occurred"
        }
    }
}

let registry = CommandRegistry<SpeltError>()
registry.register(BuildCommand())

let helpCommand = HelpCommand(registry: registry)
registry.register(helpCommand)

registry.main(defaultVerb: helpCommand.verb) { error in
    fputs(error.description + "\n", stderr)
}