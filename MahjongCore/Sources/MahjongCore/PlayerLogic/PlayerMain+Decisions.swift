//
//  PlayerMain+Managers.swift
//
//
//  Created by Rex Ma on 4/8/24.
//

import MahjongCommons
import MahjongAnalyzer

extension Player {
    public func canPong(_ mahjong: IMahjongFace) -> Bool {
        if mahjong.mahjongType == discardType {
            return false
        }
        var count = 0
        for t in handManager.closeHandArr {
            if t.sameAs(mahjong) {
                count+=1
                if count == 2 {
                    return true
                }
            }
        }
        return false
    }
    
    public func canKang(_ mahjong : MahjongEntity) -> Bool {
        if mahjong.mahjongType == discardType {
            return false
        }
        var count = 0
        for t in handManager.closeHandArr {
            if t.sameAs(mahjong) {
                count+=1
                if count == 3 {
                    return true
                }
            }
        }
        return false
    }
    
    public func canSelfKang() -> Bool {
        return possibleKangTiles.count > 0
    }
    
    public func canHu(_ mahjong: MahjongEntity) -> Bool {
        if mahjong.mahjongType == discardType {
            return false
        }
        if discardTypeTiles.count != 0 {
            return false
        }
        var tempHand = handManager.closeHandArr
        tempHand.append(mahjong)
        return style.calculateShanten(closeHand: tempHand, completeSets: openHandCompleteSets.count) == -1
    }
    
    public func canZimo() -> Bool {
        if discardTypeTiles.count != 0 {
            return false
        }
        return style.calculateShanten(closeHand: handManager.closeHandArr, completeSets: openHandCompleteSets.count) == -1
    }
    
    // MARK: The rest of the functions are internal, please access via Commands
    
    func pong(_ mahjong: MahjongEntity) {
        print("\(playerID) pong: \(mahjong.name)")
        var tiles:[MahjongEntity] = []
        for t in handManager.closeHandArr {
            if t.sameAs(mahjong) {
                tiles.append(t)
                if tiles.count == 3 {
                    break
                }
            }
        }
        mahjongSet.removeFromDiscardPile(mahjong, from: mahjong.owner)
        removeTilesFromCloseHand(tiles)
        mahjong.owner = playerID
        
        tiles.append(mahjong)
        addTilesToOpenHand(mahjongs: tiles)
        sortCloseHand()
    }
    
    func kang(_ mahjong: MahjongEntity) {
        var tiles:[MahjongEntity] = []
        for t in handManager.closeHandArr {
            if t.sameAs(mahjong) {
                tiles.append(t)
                if tiles.count == 3 {
                    break
                }
            }
        }
        
        mahjongSet.removeFromDiscardPile(mahjong, from: mahjong.owner)
        mahjong.owner = playerID
        removeTilesFromCloseHand(tiles)
        
        tiles.append(mahjong)
        addTilesToOpenHand(mahjongs: tiles)
        kangedTileFaces.append(mahjong)
        possibleKangTiles.removeAll(where: {$0.sameAs(mahjong)})
        sortCloseHand()
    }
    
    func selfKang(_ mahjong: IMahjongFace) {
        var tiles: [MahjongEntity] = []
        for t in handManager.closeHandArr {
            if t.sameAs(mahjong) {
                tiles.append(t)
            }
        }
        print("selfkang of tile count: \(tiles.count)")
        removeTilesFromCloseHand(tiles)
        addTilesToOpenHand(mahjongs: tiles)
        kangedTileFaces.append(mahjong)
        possibleKangTiles.removeAll(where: {$0.sameAs(mahjong)})
        sortCloseHand()
    }
    
    func hu(_ mahjong: MahjongEntity) {
        print("\(playerID) hu!")
//        fans = HandUtil.FindBestFans(closeHand: closedHand, openHand: openHand, fans: fans)
    }
    
    func zimo() {
        print("\(playerID) zimo!")
//        fans = HandUtil.FindBestFans(closeHand: closedHand, openHand: openHand, fans: fans)
    }
}

