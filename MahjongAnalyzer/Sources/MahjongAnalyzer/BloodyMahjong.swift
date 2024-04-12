//
//  BloodyAnalyzer.swift
//
//
//  Created by Rex Ma on 4/8/24.
//

import Foundation
import MahjongCommons

// TODO: implement rule enforcements and other style-specific actions
// FIXME: also don't forget to extract common logics such as isPongPong(), etc. for other styles to use
public class BloodyMahjong: IMahjongStyle {
    public var name = "Bloody Mahjong"
    
    public init() {}
    
    public func calculateShanten(closeHand: [IMahjongFace], completeSets: Int) -> Int {
        BloodyMahjong.calculateShanten(closeHand: closeHand, completeSets: completeSets)
    }
    
    static func calculateShanten(closeHand: [IMahjongFace], completeSets: Int) -> Int {
        let hand = parseMahjongs(closeHand)
        return calculateShanten(hand: hand, completeSets: completeSets)
    }
    
    static func calculateShanten(hand : [Int], completeSets : Int = 0) -> Int {
        let testMan = Array(hand[0..<9])
        let testPin = Array(hand[9..<18])
        let testSuo = Array(hand[18..<27])
        
        // try all combinations of one with pair combo and two without pairs
        var bestValue = 0
        
        let manSet = TableManager.getSetCounts(testMan)
        let pinSet = TableManager.getSetCounts(testPin)
        let suoSet = TableManager.getSetCounts(testSuo)
        
        for i in 0..<4 {
            var value = 0
            let maxSets = 4 - completeSets
            var set = 0
            var pSet = 0
            
            switch i {
            case 0:
                if manSet[0] + manSet[1] > 7 { continue }
                set = manSet[1] + pinSet[3] + suoSet[3]
                pSet = manSet[0] + pinSet[2] + suoSet[2]
                value += 1 // pair
            case 1:
                if pinSet[0] + pinSet[1] > 7 { continue }
                set = manSet[3] + pinSet[1] + suoSet[3]
                pSet = manSet[2] + pinSet[0] + suoSet[2]
                value += 1 // pair
            case 2:
                if suoSet[0] + suoSet[1] > 7 { continue }
                set = manSet[3] + pinSet[3] + suoSet[1]
                pSet = manSet[2] + pinSet[2] + suoSet[0]
                value += 1 // pair
            case 3: // no pairs at all
                set = manSet[3] + pinSet[3] + suoSet[3]
                pSet = manSet[2] + pinSet[2] + suoSet[2]
            default:
                break
            }
            
            value += ((set > maxSets) ? 2 * maxSets : 2 * set) + ((pSet > (maxSets - set)) ? (maxSets - set) : pSet)
            
            if value > bestValue {
                bestValue = value
            }
        }
        
        let normal =  8 - completeSets * 2 - bestValue
        let qiDui = qiDuiShanten(hand: hand)
        return min(normal, qiDui)
    }
    
    static func qiDuiShanten(hand : [Int])->Int {
        if hand.filter({$0 != 0}).reduce(0,+) != 14 {
            return Int.max
        }
        return 6 - (hand.filter({$0 == 2}).count + 2*hand.filter({$0 == 4}).count)
    }
    
    static func qiDuiShanten(mahjongHand : [IMahjongFace])->Int {
        if mahjongHand.count != 14 {
            return Int.max
        }
        return qiDuiShanten(hand: parseMahjongs(mahjongHand))
    }
}
