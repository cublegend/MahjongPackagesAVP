//
//  PlayerMain+Managers.swift
//
//
//  Created by Rex Ma on 4/8/24.
//

import MahjongCommons

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
        var hand = handManager.getCompleteHandArr()
        sortTiles(&hand)
        var count = 0
        var currentTile = hand[0]
        for t in hand {
            if currentTile.sameAs(t) {
                count+=1
                if count == 4 && t.mahjongType != discardType {
                    possibleKangTiles.append(currentTile)
                }
            } else {
                currentTile = t
                count = 0
            }
        }
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
//        return HandUtil.calculateShanten(mahjongHand: tempHand, completeSets: openHandCompleteSets.count) == -1
        return false
    }
    
    public func canZimo() -> Bool {
        if discardTypeTiles.count != 0 {
            return false
        }
//        return HandUtil.calculateShanten(mahjongHand: closedHand, completeSets: openHandCompleteSets.count) == -1
        return false
    }
    
    // MARK: The rest of the functions are internal, please access via Commands
    
    func pong(_ mahjong: MahjongEntity) {
        MahjongSet.removeFromDiscardPile(mahjong)
        print("\(playerID) pong: \(mahjong.name)")
        mahjong.owner = playerID
        var tiles = [mahjong]
        for t in handManager.closeHandArr {
            if t.sameAs(mahjong) {
                tiles.append(t)
                if tiles.count == 3 {
                    break
                }
            }
        }
        removeTilesFromCloseHand(tiles)
        tiles.append(mahjong)
        addTilesToOpenHand(mahjongs: tiles)
        sortCloseHand()
    }
    
    func kang(_ mahjong: MahjongEntity) {
        MahjongSet.removeFromDiscardPile(mahjong)
        mahjong.owner = playerID
        var tiles = [mahjong]
        for t in handManager.closeHandArr {
            if t.sameAs(mahjong) {
                tiles.append(t)
                if tiles.count == 4 {
                    break
                }
            }
        }
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

