//
//  StreamReader.swift
//  paymaker
//
//  Created by Alex Severyanov on 18/04/2017.
//  Copyright © 2017 CREALOGIX Digital Payment. All rights reserved.
//

import Foundation

class StreamReader  {
	
	let encoding: String.Encoding
	let chunkSize: Int
	var fileHandle: FileHandle
	let delimData: Data
	var buffer: Data
	var atEof: Bool
	
	init?(url: URL, delimiter: String = "\n", encoding: String.Encoding = .utf8, chunkSize: Int = 4096) {
		
		guard let fileHandle = try? FileHandle(forReadingFrom: url),
			let delimData = delimiter.data(using: encoding) else {
				return nil
		}
		self.encoding = encoding
		self.chunkSize = chunkSize
		self.fileHandle = fileHandle
		self.delimData = delimData
		self.buffer = Data(capacity: chunkSize)
		self.atEof = false
	}
	
	deinit {
		fileHandle.closeFile()
	}
	
	/// Return next line, or nil on EOF.
	func nextLine() -> String? {
		// Read data chunks from file until a line delimiter is found:
		while !atEof {
			if let range = buffer.range(of: delimData) {
				// Convert complete line (excluding the delimiter) to a string:
				let line = String(data: buffer.subdata(in: 0..<range.lowerBound), encoding: encoding)
				// Remove line (and the delimiter) from the buffer:
				buffer.removeSubrange(0..<range.upperBound)
				return line
			}
			let tmpData = fileHandle.readData(ofLength: chunkSize)
			if tmpData.count > 0 {
				buffer.append(tmpData)
			} else {
				// EOF or read error.
				atEof = true
				if buffer.count > 0 {
					// Buffer contains last line in file (not terminated by delimiter).
					let line = String(data: buffer as Data, encoding: encoding)
					buffer.count = 0
					return line
				}
			}
		}
		return nil
	}
	
	/// Start reading from the beginning of file.
	func rewind() -> Void {
		fileHandle.seek(toFileOffset: 0)
		buffer.count = 0
		atEof = false
	}
}

extension StreamReader : Sequence {
	func makeIterator() -> AnyIterator<String> {
		return AnyIterator {
			return self.nextLine()
		}
	}
}
