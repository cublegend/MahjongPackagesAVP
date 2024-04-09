//
//  TableManager.swift
//  This class loads and processes tables into convieniet interfaces
//
//  Created by Rex Ma on 4/8/24.
//

import Foundation

class TableManager {
    private static var shantenTable: [UInt32:UInt16] = [:]
    private static var yaojiuTable: [UInt32:Bool] = [:]
    private static var tableLoaded: Bool = false
    
    static func loadTables() {
        if tableLoaded {
            return
        }
        
        // load shanten table
        var tableFile = ""
        if let url = Bundle.module.url(forResource: "shanten", withExtension: "csv") {
            do {
                tableFile = try String(contentsOf: url)
            } catch {
                fatalError("table.csv cannot find")
            }
        }

        let lines = tableFile.split(separator: "\n", omittingEmptySubsequences: true)
        for line in lines {
            let parts = line.split(separator: ": ")
            guard let key = UInt32(parts[0]) else {
                fatalError("conver key failed \(parts[0])")
            }
            guard let value = UInt16(parts[1]) else {
                fatalError("convert value failed \(parts[1])")
            }
            shantenTable[key] = value
        }
        
        // load yaojiu table
        if let url = Bundle.module.url(forResource: "yaojiu", withExtension: "csv") {
            do {
                tableFile = try String(contentsOf: url)
            } catch {
                fatalError("yaojiu.csv cannot find")
            }
        }

        let entries = tableFile.split(separator: "\n", omittingEmptySubsequences: true)
        for line in entries {
            guard let key = UInt32(line) else {
                fatalError("conver key failed \(line)")
            }
            yaojiuTable[key] = true
        }
        tableLoaded = true
    }
    
    static func getSetCounts(_ group : [Int]) -> [Int] {
        if !tableLoaded {
            loadTables()
        }
        let key = encodeKey(group)
        return decodeValue(shantenTable[key])
    }
    
    static func isGroupYaoJiu(_ group: [Int])-> Bool {
        if !tableLoaded {
            loadTables()
        }
        let key = encodeKey(group)
        return yaojiuTable[key] ?? false
    }
    
    private static func encodeKey(_ group : [Int]) -> UInt32 {
        if group.count != 9 {
            fatalError("encoding a group of count != 9")
        }
        
        var key : UInt32 = 0
        for i in 0..<9 {
            key |= UInt32(group[i] << (i*3))
        }
        return key
    }
    
    private static func decodeValue(_ value : UInt16?)-> [Int] {
        guard let value = value else {
            return [Int.max,Int.max,Int.max,Int.max]
        }
        var sets = [0,0,0,0]
        for i in 0...3 {
            sets[i] = Int((value >> (i*3)) & 0b111)
        }
        return sets
    }
}
