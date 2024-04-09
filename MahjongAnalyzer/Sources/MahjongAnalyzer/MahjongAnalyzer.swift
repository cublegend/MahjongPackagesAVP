//
//  IMahjongAnalyzer.swift
//
//
//  Created by Rex Ma on 4/8/24.
//

import Foundation
import MahjongCommons

/// This class provides analysis methods include:
/// - Shanten Calculation
/// - Fan Calculation
public protocol IMahjongAnalyzer {
    /// This method should be called after a player hu to find the highest scoring fan group
    static func findBestFanGroup(closeHand: [IMahjongFace], openHand: [IMahjongFace])->[Fan]
    /// This method should be called to calculate the  player's shanten value: how many tile they need to reach tin-pai
    static func calculateShanten(closeHand: [IMahjongFace], completeSets: Int)->Int
}

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
