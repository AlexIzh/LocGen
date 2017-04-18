//
//  main.swift
//  locgen
//
//  Created by Alex Severyanov on 18/04/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import Foundation

let help = "Example of usage: \n locgen -i ./en.lproj/Localizable.strings -o Localizable.swift -cs \".\" -so ./Localizations+Strings.swift\n"
			+ "Where:\n -i: Input Localizable.strings file. Default value is Localizable.strings in current directory.\n"
			+ "-o: Output file where generated strings should be placed. Default value is Localizable.swift in current directory.\n"
			+ "-cs: String with characters which should be used for separating modules. Default is \".\"\n"
			+ "-so: Support output file. IF this file exists already, this application will not replace it. "
			+ "This file contains default implementation for `localized` function. You can change it if you have another localization logic (for example, get translation from specific table). Default value is Localiztions+Strings.swift in current directory."

let arguments = ProcessInfo.processInfo.arguments

var inputFile = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Localizable.strings")
var outputFile = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Localizations.swift")
var set = CharacterSet(charactersIn: ".")
var supportOutputFile = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Localizations+Strings.swift")

for (index, argument) in arguments.enumerated() {
	switch argument {
	case "-i":
		guard index < arguments.count - 1 else { print(help); exit(0) }
		inputFile = URL(fileURLWithPath: arguments[index+1])
		
	case "-o":
		guard index < arguments.count - 1 else { print(help); exit(0) }
		outputFile = URL(fileURLWithPath: arguments[index+1])
		
	case "-so":
		guard index < arguments.count - 1 else { print(help); exit(0) }
		supportOutputFile = URL(fileURLWithPath: arguments[index+1])
	
	case "-cs":
		guard index < arguments.count - 1 else { print(help); exit(0) }
		set = CharacterSet(charactersIn: arguments[index+1])
		
	default: break
	}
}

guard let reader = StreamReader(url: inputFile)
	else { print("Invalid input file\n" + help); exit(0) }

//let outputStream = OutputStream(url: URL(fileURLWithPath: outputFile), append: false)
let generator = Generator()
generator.separatorSet = set

while let line = reader.nextLine() {
	generator.add(line)
}

guard let stream = OutputStream(url: outputFile, append: false)
	else { print("Can't create output file"); exit(0) }

do {
	try generator.generate(to: stream)
	
	let comment = "/* This file is geneerated by LocGen, but it will not be generated while it exists, so you can change this. If you remove this file, LocGen will generate it again. */"
	let additionalFileContent = comment + "\n\nimport Foundation\n\nextension Localizable where Self: RawRepresentable, Self.RawValue == String {\n\tvar localized: String { return NSLocalizedString(rawValue, comment: \"\") } \n}"
	if !FileManager.default.fileExists(atPath: supportOutputFile.absoluteString) {
		try additionalFileContent.write(to: supportOutputFile, atomically: true, encoding: .utf8)
	}
} catch {
	print(error)
}
