import Swift

extension String {
	func halve(with sep: Character) -> (String, String) {
		var first = ""
		var last = ""
		
		var isFirst = true
		
		for c in characters {
			if c == sep {
				isFirst = false
				continue
			}
			if isFirst {
				first += String(c)
			} else {
				last += String(c)
			}
		}
		
		return (first, last)
	}
}

enum ArgumentInput : ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
	case _double(Double), _int(Int), _string(String)
	case double, int, string
	
	typealias StringLiteralType = String
	init(stringLiteral value: StringLiteralType) {
		self = ._string(value)
	}
	typealias ExtendedGraphemeClusterLiteralType = String
	init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
		self = ._string(value)
	}
	typealias UnicodeScalarLiteralType = String
	init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
		self = ._string(value)
	}
	
	typealias IntegerLiteralType = Int
	init(integerLiteral: IntegerLiteralType) {
		self = ._int(integerLiteral)
	}
	
	typealias FloatLiteralType = Double
	init(floatLiteral: FloatLiteralType) {
		self = ._double(floatLiteral)
	}
}

enum Argument : ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, Equatable {
	case double(Double?)
	case int(Int?)
	case string(String?)
	
	typealias StringLiteralType = String
	init(stringLiteral value: StringLiteralType) {
		self = .string(value)
	}
	typealias ExtendedGraphemeClusterLiteralType = String
	init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
		self = .string(value)
	}
	typealias UnicodeScalarLiteralType = String
	init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
		self = .string(value)
	}
	
	typealias IntegerLiteralType = Int
	init(integerLiteral: IntegerLiteralType) {
		self = .int(integerLiteral)
	}
	
	typealias FloatLiteralType = Double
	init(floatLiteral: FloatLiteralType) {
		self = .double(floatLiteral)
	}
	
	init(_ s: String) {
		if let i = Int(s, radix: 10) {
			self = .int(i)
		} else if let d = Double(s) {
			self = .double(d)
		} else {
			self = .string(s)
		}
	}
	
	var stringValue: String {
		switch self {
		case .string(let s): return s ?? ""
		default: return ""
		}
	}
	
	var intValue: Int {
		switch self {
		case .int(let i): return i ?? 0
		default: return 0
		}
	}
	
	var doubleValue: Double {
		switch self {
		case .double(let d): return d ?? 0
		default: return 0
		}
	}
	
	var anyValue: Any {
		switch self {
		case .double(let d): return d as Any
		case .int(let i): return i as Any
		case .string(let s): return s as Any
		}
	}
	
	static func ==(lhs: Argument, rhs: Argument) -> Bool {
		if case let .double(l) = lhs, case let .double(r) = rhs {
			return l == nil || r == nil || l == r
		} else if case let .int(l) = lhs, case let .int(r) = rhs {
			return l == nil || r == nil || l == r
		} else if case let .string(l) = lhs, case let .string(r) = rhs {
			return l == nil || r == nil || l == r
		}
		
		return false
	}
	
	func represents(input: ArgumentInput) -> Bool {
		switch self {
		case .double(let md):
			if case ._double(let ad) = input {
				return ad == md
			} else if case .double = input {
				return true
			}
			
		case .int(let mi):
			if case ._int(let ai) = input {
				return ai == mi
			} else if case .int = input {
				return true
			}
			
		case .string(let ms):
			if case ._string(let at) = input {
				return at == ms
			} else if case .string = input {
				return true
			}
		}
		return false
	}
}

struct Option : Hashable, ExpressibleByStringLiteral {
	static var any: Option = "-*--{matchAny}"
	static var subset: Option = "-⊂--{matchAll}"
	static var help: Option = "-h--help"
	
	var flag: Character?
	var long: String?
	var argument: Argument?
	
	init(flag: Character? = nil, long: String? = nil, argument: Argument? = nil) {
		(self.flag, self.long, self.argument) = (flag, long, argument)
	}
	
	static func ==(lhs: Option, rhs: Option) -> Bool {
		var equal = false
		
		if let ls = lhs.flag, let rs = rhs.flag {
			equal = ls == rs
		}
		
		if let ll = lhs.long, let rl = rhs.long {
			equal = ll == rl
		}
		
		if let la = lhs.argument, let ra = rhs.argument {
			equal = equal && la == ra
		}
		
		return equal
	}
	
	var hashValue: Int {
		if let l = long {
			return l.hashValue
		}
		if let f = flag {
			return f.hashValue
		}
		return 0
	}
	
	static func option(from string: String) -> (Character?, String?) {
		var flag: Character? = nil
		var long: String? = nil
		
		let chars = string.characters
		if chars.contains("-") {
			let words = chars.split(separator: "-", omittingEmptySubsequences: true)
			for word in words {
				if word.count == 1 {
					flag = word.first!
				} else {
					long = String(word)
				}
			}
		} else if chars.count == 1 {
			flag = chars.first!
		} else {
			long = string
		}
		
		return (flag, long)
	}
	
	typealias StringLiteralType = String
	init(stringLiteral value: StringLiteralType) {
		(flag, long) = Option.option(from: value)
		argument = nil 
	}
	typealias ExtendedGraphemeClusterLiteralType = String
	init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
		(flag, long) = Option.option(from: value)
		argument = nil
	}
	typealias UnicodeScalarLiteralType = String
	init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
		(flag, long) = Option.option(from: value)
		argument = nil
	}
}

extension CommandLine {
	static func options() -> [Option] {
		var result = [Option]()
		for arg in CommandLine.arguments.dropFirst() {
			var cs = arg.characters
			guard let f = cs.popFirst(), f == "-" else {
				continue
			}
			
			if cs.contains("=") {
				let text = String(cs)
				let (name, value) = text.halve(with: "=")
				if name.characters.count == 1 {
					result.append(Option(flag: name.characters.first!, argument: Argument(value)))
				} else {
					result.append(Option(long: name, argument: Argument(value)))
				}
				continue
			}
			
			guard let s = cs.popFirst() else {
				continue
			}
			
			if s == "-" {
				result.append(Option(long: String(cs)))
			} else {
				result.append(Option(flag: s))
				for c in cs {
					result.append(Option(flag: c))
				}
			}
		}
		
		return result
	}
	
	static func args() -> [Argument] {
		var result = [Argument]()
		for arg in CommandLine.arguments.dropFirst() {
			var cs = arg.characters
			guard let f = cs.popFirst(), f != "-" else {
				continue
			}
			
			result.append(Argument(arg))
		}
		return result
	}
}

struct Command {
	let inputs: [ArgumentInput]
	let options: [Option]
	let execution: (CommandArg) -> ([Argument]?)
	let matchAny: Bool
	let isSubset: Bool
	
	init(options: [Option], inputs: [ArgumentInput], execution: @escaping (CommandArg) -> ([Argument]?)) {
		matchAny = options.contains(Option.any)
		isSubset = options.contains(Option.subset)
		self.inputs = inputs
		self.options = options.filter { $0 != Option.any && $0 != Option.subset }
		self.execution = execution
	}
	
	func validOptions(_ opts: [Option]) -> Bool {
		if matchAny {
			for opt in opts {
				if options.contains(opt) {
					return true
				}
			}
			return false
		} else if isSubset {
			return options.filter { opts.contains($0) }.count == options.count
		} else {
			guard opts.count == options.count else {
				return false
			}
			for opt in opts {
				if !options.contains(opt) {
					return false
				}
			}
			return true
		}
	}
	
	func responseOptions(_ opts: [Option]) -> [Option: Argument] {
		var result = [Option: Argument]()
		for opt in opts {
			guard let arg = opt.argument else {
				if opts.contains(opt) {
					result[opt] = 1
				}
				continue
			}
			
			if options.contains(opt) {
				result[opt] = arg
			}
		}
		return result
	}
	
	func validArguments(_ args: [Argument]?) -> Bool {
		guard let args = args else {
			return inputs.isEmpty
		}
		
		guard inputs.count == args.count else {
			return false
		}
		
		guard !(inputs.isEmpty && args.isEmpty) else {
			return true
		}
		
		for (mine, theirs) in zip(inputs, args) {
			if !theirs.represents(input: mine) {
				return false
			}
		}
		
		return true
	}
}

typealias OptionArg = [Option: Argument]
typealias CommandArg = ([Argument], OptionArg)

struct Console {
	var commands: [Command]
	var completion: ((CommandArg) -> ())?
	var failure: (() -> ())?
	var name: String
	
	init() {
		commands = [Command]()
		completion = nil
		failure = nil
		name = CommandLine.arguments.first!
	}
	
	mutating func append(command: Command) {
		commands.append(command)
	}
	
	mutating func command(options: [Option] = [], inputs: [ArgumentInput] = [], execution: @escaping (CommandArg) -> ([Argument]?)) {
		let com = Command(options: options, inputs: inputs, execution: execution)
		commands.append(com)
	}
	
	func run(completeAll: Bool = false, followUserOrder: Bool = false) {
		let completeAll = completeAll || followUserOrder
		let userOptions = CommandLine.options()
		var args: [Argument]? = CommandLine.args()
		var failed = true 
		
		var blacklistSubset = [Option]()
		if followUserOrder {
			for option in userOptions {
				for command in commands {
					let vo: Bool
					if command.matchAny {
						vo = command.options.contains(option)
						blacklistSubset.append(option)
					} else if command.isSubset {
						vo = command.options.contains(option) && command.validOptions(userOptions) && !blacklistSubset.contains(option)
						if vo {
							blacklistSubset.append(contentsOf: command.options)
						}
					} else {
						vo = false
					}
					let va = command.validArguments(args)
					
					if vo && va {
						let resopts = command.responseOptions(userOptions)
						failed = false
						if let newArgs = command.execution((args ?? [], resopts)) {
							args = newArgs
						}
					}
				}
			}
		}
		
		for command in commands {
			var vo = command.validOptions(userOptions)
			vo = followUserOrder ? vo && !(command.matchAny || command.isSubset) : vo
			let va = command.validArguments(args)
			
			if vo && va {
				let resopts = command.responseOptions(userOptions)
				failed = false
				args = command.execution((args ?? [], resopts))
				if (!completeAll) {
					break
				}
			}
		}
		if failed {
			failure?()
		} else {
			completion?((args ?? [], [:]))
		}
		
	}
} 