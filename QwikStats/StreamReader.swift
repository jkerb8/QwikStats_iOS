//
//  StreamReader.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 8/17/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import Foundation

class StreamReader {
    
    let encoding: UInt
    let chunkSize: Int
    
    var fileHandle: NSFileHandle!
    let buffer: NSMutableData!
    let delimData: NSData!
    var atEof: Bool = false
    
    init?(path: NSURL, delimiter: String = "\n", encoding: UInt = NSUTF8StringEncoding, chunkSize: Int = 4096) {
        self.chunkSize = chunkSize
        self.encoding = encoding
        
        if let fileHandle = try? NSFileHandle(forWritingToURL: path), delimData = delimiter.dataUsingEncoding(encoding), buffer = NSMutableData(capacity: chunkSize) {
            defer {
                print("closing fileHandle")
                fileHandle.closeFile()
            }
            self.fileHandle = fileHandle
            self.delimData = delimData
            self.buffer = buffer
        }
        else {
            self.fileHandle = nil
            self.delimData = nil
            self.buffer = nil
            print("StreamReader failed at \(path)")
            return nil
        }
    }
    
    deinit {
        self.close()
    }
    
    func nextLine() -> String? {
        precondition(fileHandle != nil, "Attempt to read from closed file")
        
        if atEof {
            return nil
        }
        print("checkpoint 1")
        var range = buffer.rangeOfData(delimData, options: [], range: NSMakeRange(0, buffer.length))
        
        while range.location == NSNotFound {
            print("chunksize: \(chunkSize)")
            let tmpData = fileHandle.readDataOfLength(chunkSize)
            print("checkpoint 2")
            if tmpData.length == 0 {
                atEof = true
                if buffer.length > 0  {
                    let line = NSString(data: buffer, encoding: encoding)
                    print("checkpoint 3")
                    
                    buffer.length = 0
                    return line as String?
                }
                return nil
            }
            buffer.appendData(tmpData)
            range = buffer.rangeOfData(delimData, options: [], range: NSMakeRange(0, buffer.length))
        }
        print("after while")
        let line = NSString(data: buffer.subdataWithRange(NSMakeRange(0, range.location)), encoding: encoding)
        buffer.replaceBytesInRange(NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
        print(line)
        
        return line as String?
    }
    
    func rewind() -> Void {
        fileHandle.seekToFileOffset(0)
        buffer.length = 0
        atEof = false
    }
    
    func close() -> Void {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}
