//
//  PlayerMain.swift
//
//  Created by Katherine Xiong on 3/17/24.
//

import Foundation
import RealityKit
import MahjongCommons
import MahjongAnalyzer

// TODO: make IMahjongAnalyzer a rule enum to be used in both analysis and rules and other things
@Observable
public class Player {
    public var playerID: String
    public let style: IMahjongStyle
    public let mahjongSet: MahjongSet
    public var closeHand:[MahjongEntity] { handManager.closeHandArr }
    public var numCompleteSet:Int { openHandCompleteSets.count }
    public var rootEntity: Entity { entityManager.rootEntity }
    
    let entityManager: PlayerEntityManager
    let handManager: PlayerHandManager
    
    // FIXME: Bloody rules!
    private(set) public var discardType: MahjongType? = .none
    public var discardTypeTiles: [MahjongEntity] = []
    
    public var possibleKangTiles: [MahjongEntity] = []
    var kangedTileFaces: [IMahjongFace] = []
    var openHandCompleteSets = [String: [Int]]() // A helper var to store openHand
    
    // fan calculation flags
    var fans: [Fan] = []
    
    public init(playerId: String, seat: PlayerSeat, table: TableEntity, mahjongSet: MahjongSet, style: IMahjongStyle) {
        self.playerID = playerId
        mahjongSet.discardPile[playerId] = []
        handManager = PlayerHandManager()
        entityManager = PlayerEntityManager(seat: seat)
        self.style = style
        self.mahjongSet = mahjongSet
        table.addChild(entityManager.rootEntity)
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
            print("Can't discard this tile!")
            return
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
            let idx = handManager.closeHandArr.count
            handManager.addToCloseHandArr(mahjong)
            mahjong.owner = playerID
            entityManager.closeHandLocation[idx].addChild(mahjong)
            entityManager.resetTilePositionAndRotation(mahjong)
            entityManager.rotateTileFacingPlayer(mahjong)
            if mahjong.mahjongType == discardType {
                discardTypeTiles.append(mahjong)
            } else {
                // check if can kang
                let hand = handManager.getCompleteHandArr()
                if hand.filter({$0.sameAs(mahjong)}).count == 4 {
                    // make sure this tile is never been kanged nor in possible
                    if possibleKangTiles.filter ({$0.sameAs(mahjong)}).isEmpty &&
                        kangedTileFaces.filter({ $0.sameAs(mahjong)}).isEmpty {
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
        
        let idx = mahjongSet.discardPile[playerID]!.count
        entityManager.discardLocation[idx].addChild(mahjong)
        
        mahjongSet.lastTileDiscarded = mahjong
        mahjongSet.addToDiscardPile(mahjong, to: playerID)
    }
    
    /**
     * [
     *      "Tiao_1",   "Tiao_1",   "Tiao_1",
     *      "Tong_2", "Tong_2",    "Tong_2"
     * ]
     * example: ["Tong_2": [current: 2, index: 0, curr position: 0 * 4 + current = 2]]
     * example: ["Tiao_1": [current: 2, index: 1, curr position: 1 * 4 + current = 6]]
     * example: new "Wan_3". Does not contain in openHandCompleteSets.
     * openHandCompleteSets["Wan_3"] = [2, openHandCompleteSets.count, openHandCompleteSets.count * 4 + current]
     *
     **/
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
    public func canDiscardTile(mahjong: MahjongEntity)->Bool {
        guard let suit = discardType else {
            fatalError("discarding tile before setting discard type!")
        }
        if discardTypeTiles.count == 0 {
            return true
        }
        
        return mahjong.mahjongType == suit
    }
}
