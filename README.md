# Swift-CLI
Create Swift command line programs more easily. Adding in flags and options are simple and argument inputs are typed. SwiftCLI
is made to be customizable and give as much power to its user as possible.

## Usage
### Hello \*
#### Hello World
```Swift
var hello = Console()

hello.command {_, _ in
	print("Hello World")
	return nil
}

hello.run()
```
```Bash
$ ./hello
```
You create a `Console` struct that manages all your commands. This is just an example without any input.
#### Hello [string]
```Swift
hello.command(inputs: [.string]) {args, _ in
	let name = args[0].stringValue
	print("Hello \(name)")
	return nil
}
```
```Bash
./hello [string]
```

### Multiple Commands
Sometimes your program needs to do a lot of different things and checking every argument combination can become tiresome so here is an easy way to have a program with multiple argument input combinations
```Swift
hello.command(inputs: [.string]) {args, _ in
	let name = args[0].stringValue
	print("Hello \(name)")
	return nil
}

hello.command(inputs: [.string, .int]) {args, _ in
	let name = args[0].stringValue
	let count = args[1].intValue
	for _ in 0..<count {
		print("Hello \(name)")
	}
	return nil
}

hello.command(inputs: [.string, .int, .int]) {args, _ in
	let name = args[0].stringValue
	let col = args[1].intValue
	let row = args[2].intValue
	for _ in 0..<row {
		for _ in 0..<col {
			print(name, separator: " ", terminator: " ")
		}
		print("")
	}
	
	return nil
}
```
So now any of these prompts would work `./hello [string]` `./hello [string] [int]` `./hello [string] [int] [int]` and will match to the corrosponding closure

### Sheldon Cooper Presents Fun with Flags
for this example we'll use a text modifying app that can perform lowercase, uppercase and reversal operations on some text
```Swift
var textApp = Console()

let uppercase = Option(flag: "u")
let lowercase = Option(flag: "l")
let reverse = Option(flag: "r")

textApp.command(options: [Option.any, uppercase], inputs: [.string]) {args, _ in
	let text = args[0].stringValue
	return [.string(text.uppercased())]
}

textApp.command(options: [Option.any, lowercase], inputs: [.string]) {args, _ in
	let text = args[0].stringValue
	return [.string(text.lowercased())]
}

textApp.command(options: [Option.any, reverse], inputs: [.string]) {args, _ in
	let text = args[0].stringValue
	return [.string(String(text.characters.reversed()))]
}

textApp.completion = {args, _ in
	let text = args[0].stringValue
	print(text)
}

textApp.failure = {
  print("error no command found")
}

textApp.run(completeAll: true)
```
Using this allows your user with great leeway with some example calls being `./textApp -r John`, `./textApp -r -u John`, `./textApp John -ur`, `./textApp -l John -r` 
So there's a couple of things going on here, namely 'chaining/fallthroughs', 'completeAll' and 'Option.any'.

#### Chaining/Fallthrough
By default a `Console` terminates execution once it finds a command that matches the user input options and arguments, but when `run` is called with either `run(completeAll: true)` or `run(followUserOrder: true)` the `Console` object will continue comparing its other commands with the return value of the last executed command.  
Every command closure returns an `[Argument]?` that is then passed on to any subsequent command to be checked against. If a command returns nil no other command will get executed.

#### completeAll
A `Console` `run()` call by default takes no arguments, but has a completeAll flag that tells the console to continue checking other commands with in the order of the `Console.commands` order

#### followUserOrder
Such as `completeAll` `followUserOrder` runs through all commands with an exectuted commands closure result, but the order in which commands are checked are by the order of the options the user has inputed.
So with our `textApp` the call `./textApp -ru john` will reverse, then uppercase the text when `followUserOrder` is true

#### Completion
A `Console` object has a `completion` closure that gets called at the end of everything **if** some command has been executed else the `failure` closure will be called

#### Option.any
`Option.any` tells the console to run a command if any of the command options is in the user input options

#### Option.subset
`Option.subset` tells the console to run a command if all the command options is in the user input options

##### Subset example
`Option.subset` makes sure that a call has all the options required to run the command, so for an example let's print a range
```Swift
let rangeStart = Option(flag: "s")
let rangeLength = Option(flag: "l")

var range = Console()

range.command(options: [Option.subset, rangeStart, rangeLength]) {_, opts in
	let start = opts[rangeStart]!.intValue
	let length = opts[rangeLength]!.intValue
	
	for i in start...(start + length) {
		print(i)
	}
	
	return nil
}

range.run()
```
This will make sure a call has all flags if the command is executed
 
### Options With Values
Options can have associated values with usage such as `./app --count=4 --name=John`
```Swift
let name = Option(long: "name")
let count = Option(long: "count")

var greeter = Console()

greeter.command(options: [Option.any, name, count]) {_, opts in
	let n = opts[name]?.stringValue ?? "world"
	let c = opts[count]?.intValue ?? 1
	
	for _ in 0..<c {
		print("hello ", n)
	}
	return nil
}

greeter.run()
```
Any of these call would work `./greeter --name=John`, `./greeter --count=4`, `./greeter --count=2 --name=John`
Here we show that we can have commands with default values and how to use values associated with options. All command closure get passed with a `[Argument]` and `[Option: Argument]`. Options that are just flags are also added to this dictionary so you can check against it to check if a flag is set. Options without a value are given an .int(1) value.

### Help!!!
```Swift
greeter.command(options: [Option.help]) {_, _ in
  print("Display help")
  return nil
}
```
```Bash
./greeter --help
```
Just a little helper `Option` that defines a `-h--help` option

## Installation

### Manual
add "Swift CLI.swift" to your project
