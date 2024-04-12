//
//  IMahjongAnalyzer.swift
//
//
//  Created by Rex Ma on 4/8/24.
//

import Foundation
import MahjongCommons

/// This class delegates style specifc analyze logic to add another layer of encapsulation
//public class MahjongAnalyzer {
//    let style: IMahjongStyle
//    
//    public init(style: IMahjongStyle) {
//        self.style = style
//    }
//    
//    public func findBestFanGroup(closeHand: [IMahjongFace], openHand: [IMahjongFace]) -> [Fan] {
//        return style.findBestFanGroup(closeHand: closeHand, openHand: openHand)
//    }
//    
//    public func calculateShanten(closeHand: [IMahjongFace], completeSets: Int) -> Int {
//        return style.calculateShanten(closeHand: closeHand, completeSets: completeSets)
//    }
//}

/// This is a useful function to convert an array of mahjong to integer to query tables
func parseMahjongs(_ hand: [IMahjongFace]) -> [Int] {
    var tiles = [Int](repeating: 0, count: 27)
    for tile in hand {
        var offset = 0
        switch(tile.mahjongType) {
        case .Wan:
            offset = 0
        case .Tong:
            offset = 9
        case .Tiao:
            offset = 18
        }
        tiles[tile.num-1 + offset]+=1
    }
    return tiles
}
