//
//  PlayerMain.swift
//
//  Created by Katherine Xiong on 3/17/24.
//

import Foundation
import RealityKit
import MahjongCommons

@Observable
class Player {
    public var playerID: String
    let entityManager: PlayerEntityManager
    let handManager: PlayerHandManager
    
    private(set) public var discardType: MahjongType? = .none
    public var discardTypeTiles: [MahjongEntity] = []
    public var possibleKangTiles: [MahjongEntity] = []
    
    var kangedTileFaces: [IMahjongFace] = []
    var openHandCompleteSets = [String: [Int]]() // A helper var to store openHand
    
    // fan calculation flags
    var fans: [Fan] = []
    
    init(playerId: String, rotation: simd_quatf, discardPile: NSMutableArray) {
        self.playerID = playerId
        handManager = PlayerHandManager(discardPile: discardPile)
        entityManager = PlayerEntityManager(rotation: rotation)
    }
    
    public func resetPlayer() {
        openHandCompleteSets.removeAll()
        discardTypeTiles.removeAll()
        kangedTileFaces.removeAll()
        fans.removeAll()
        handManager.resetHandArr()
        discardType = .none
    }
    
    // MARK: Interface
    
    /// sets the player's discard type
    /// if any tiles in hand are of that type, put them all into the discardTypeTiles
    public func setDiscardType(_ type: MahjongType) {
        discardType = type
        for tile in handManager.closeHandArr {
            if tile.mahjongType == discardType {
                discardTypeTiles.append(tile)
            }
        }
    }
    
    // MARK: Please access draw and discard through commands
    
    func discardTileOperation(_ mahjong: MahjongEntity) {
        if !canDiscardTile(mahjong: mahjong) {
            fatalError("Can't discard this tile!")
        }
        removeTilesFromCloseHand([mahjong])
        addTileToDiscardPile(mahjong)
        if let idx = discardTypeTiles.firstIndex(of: mahjong) {
            discardTypeTiles.remove(at: idx)
        }
    }
    
    func drawTileOperation(_ mahjong: MahjongEntity) {
        addTilesToCloseHand([mahjong])
    }
    
    // MARK: Encapsulated Behaviors

    /// A function that add a Mahjong tile to closed hand array.
    func addTilesToCloseHand(_ mahjongs: [MahjongEntity]) {
        for mahjong in mahjongs {
            mahjong.owner = playerID
            entityManager.resetTilePositionAndRotation(mahjong)
            
            entityManager.rotateTileFacingPlayer(mahjong)
                        
            handManager.addToCloseHandArr(mahjong)
            if mahjong.mahjongType == discardType {
                discardTypeTiles.append(mahjong)
            } else {
                // check if can kang
                let hand = handManager.getCompleteHandArr()
                if hand.filter({$0.sameAs(mahjong)}).count == 4 {
                    if possibleKangTiles.filter ({$0.sameAs(mahjong)}).count == 0 {
                        possibleKangTiles.append(mahjong)
                    }
                }
            }
        }
        
        sortCloseHand()
    }
    
    func removeTilesFromCloseHand(_ mahjongs: [MahjongEntity]) {
        for mahjong in mahjongs {
            if handManager.tryRemoveFromCloseHandArr(mahjong) {
                entityManager.resetTilePositionAndRotation(mahjong)
                mahjong.removeFromParent()
                mahjong.isClickable = false
            } else {
                fatalError("failed to remove tile from closeHand!")
            }
        }
        
        sortCloseHand()
    }
    
    /// A function that sort the closeHand array.
    func sortCloseHand() {
        handManager.sortCloseHandArr()
        let closeHand = handManager.closeHandArr
        
        for handCard in closeHand {
            handCard.removeFromParent()
        }
        let startInd = (entityManager.closeHandLocation.count / 2) - (closeHand.count / 2)
        for index in 0...closeHand.count-1 {
            entityManager.closeHandLocation[startInd + index].addChild(closeHand[index])
        }
    }
    
    func addTileToDiscardPile(_ mahjong: MahjongEntity) {
        // reset mahjong position and orientation
        entityManager.resetTilePositionAndRotation(mahjong)
        
        entityManager.rotateTileFacingUp(mahjong)
        
        let idx = handManager.discardPileRef.count
        entityManager.discardLocation[idx].addChild(mahjong)
        
        MahjongSet.lastTileDiscarded = mahjong
        handManager.addToDiscardPileArr(mahjong)
        
        print("\(self.playerID) add to discard pile index: ", idx)
    }
    
    // TODO: need clarification
    func addTilesToOpenHand(mahjongs: [MahjongEntity]) {
        for mahjong in mahjongs {
            entityManager.resetTilePositionAndRotation(mahjong)
            
            entityManager.rotateTileFacingUp(mahjong)
            
            if openHandCompleteSets[mahjong.name] == nil {
                var arr = [Int]()
                arr.append(0)
                arr.append(openHandCompleteSets.count)
                arr.append(openHandCompleteSets.count * 4)
                openHandCompleteSets[mahjong.name] = arr
                entityManager.openHandLocation[arr[2]].addChild(mahjong)
            } else {
                var arr = openHandCompleteSets[mahjong.name]!
                arr[0] += 1
                arr[2] = arr[1] * 4 + arr[0]
                openHandCompleteSets[mahjong.name] = arr
                entityManager.openHandLocation[arr[2]].addChild(mahjong)
            }
            handManager.addToOpenHandArr(mahjong)
        }
    }
    
    /// validate tile actions
    func canDiscardTile(mahjong: MahjongEntity)->Bool {
        guard let suit = discardType else {
            fatalError("discarding tile before setting discard type!")
        }
        if discardTypeTiles.count == 0 {
            return true
        }
        
        return mahjong.mahjongType == suit
    }
}
