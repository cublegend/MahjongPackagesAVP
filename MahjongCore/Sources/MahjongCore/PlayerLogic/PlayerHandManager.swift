//
//  PlayerHandManager.swift
//
//
//  Created by Rex Ma on 4/8/24.
//

import Foundation
import RealityKit
import simd
import MahjongCommons

class PlayerHandManager {
    private(set) var lastDrawTile: MahjongEntity?
    private(set) var closeHandArr: [MahjongEntity] = []
    private(set) var openHandArr: [MahjongEntity] = []
    
    init() {
    }
    
    func resetHandArr() {
        closeHandArr.removeAll()
        openHandArr.removeAll()
        lastDrawTile = nil
    }
    
    func getCompleteHandArr() -> [MahjongEntity] {
        return closeHandArr + openHandArr
    }
    
    func addToCloseHandArr(_ tile: MahjongEntity) {
        closeHandArr.append(tile)
    }
    
    func addToOpenHandArr(_ tile: MahjongEntity) {
        openHandArr.append(tile)
    }
    
    func sortCloseHandArr() {
        sortTiles(&closeHandArr)
    }
    
    @discardableResult
    func tryRemoveFromCloseHandArr(_ tile: MahjongEntity)->Bool {
        if let index = closeHandArr.firstIndex(of: tile) {
            closeHandArr.remove(at: index)
            return true
        }
        return false
    }
}
