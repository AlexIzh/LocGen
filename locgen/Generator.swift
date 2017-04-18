//
//  Parser.swift
//  locgen
//
//  Created by Alex Severyanov on 18/04/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import Foundation

class Generator {
	
	var separatorSet = CharacterSet(charactersIn: ".")
	var rootEntity = Entity(name: "Localizations")
	
	func add(_ line: String) {
		let string = line.trimmingCharacters(in: .whitespaces)
		guard string.isEmpty == false else { return }
		
		guard let end = string.substring(from: string.index(after: string.startIndex)).range(of: "\"")?.upperBound
			else { return }
		
		let key = string.substring(with: Range(uncheckedBounds: (string.index(after: string.startIndex), end)))
		var components = key.components(separatedBy: separatorSet)
		guard components.count > 1 else {
			return rootEntity.values[key] = key
		}
		
		let name = components.removeFirst()
		rootEntity.childs[name] = rootEntity.childs[name] ?? Entity(name: name)
		let root = rootEntity.childs[name]!
		var entity = root
		
		while components.count > 0 {
			let name = components.removeFirst()
			if components.isEmpty {
				entity.values[name] = key
			} else {
				entity.childs[name] = entity.childs[name] ?? Entity(name: name)
				entity = entity.childs[name]!
			}
		}
	}
	
	func generate(to stream: OutputStream) throws {
		stream.open()
		defer { stream.close() }
		
		let comment = "/* This file is Generated by LocGen. Please, don't change this file. */"
		let data = (comment + "\n\nimport Foundation\n\nprotocol Localizable {\n\tvar localized: String { get }\n}\n\n").data(using: .utf8)!
		_ = data.withUnsafeBytes { stream.write($0, maxLength: data.count) }
		
		try generate(for: rootEntity, level: 0, stream: stream)
	}
	
	func generate(for entity: Entity, level: Int, stream: OutputStream) throws {
		func write(_ string: String) throws {
			let data = string.data(using: .utf8)!
			_ = try data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Void in
				stream.write(bytes, maxLength: data.count)
				if let error = stream.streamError {
					throw error
				}
			}
		}
		
		let tabs = (0..<level).reduce("", { value, _ in value + "\t" })
		
		let name = entity.name.capitalized.components(separatedBy: CharacterSet(charactersIn: "_. ")).joined()
		let protocols = entity.values.keys.isEmpty ? "" : ": String, Localizable"
		try write(tabs + "enum \(name)\(protocols) {\n")
		
		for v in entity.values {
			try write(tabs + "\t")
			let key = v.key.lowercased().components(separatedBy: CharacterSet(charactersIn: ". ")).joined()
			try write("case \(key) = \"\(v.value)\"\n")
		}
		if !entity.childs.values.isEmpty {
			try write("\n")
		}
		
		for child in entity.childs.values {
			try generate(for: child, level: level+1, stream: stream)
		}
		try write(tabs + "}\n\n")
	}
	
	class Entity {
		var childs: [String: Entity] = [:]
		var values: [String: String] = [:]
		var name: String = ""
		init(name: String) { self.name = name }
	}
}
