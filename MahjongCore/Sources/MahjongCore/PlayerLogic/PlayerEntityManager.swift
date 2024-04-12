//
//  PlayerEntityManager.swift
//
//
//  Created by Rex Ma on 4/8/24.
//

import Foundation
import RealityKit

class PlayerEntityManager {
    private let DISCARD_ROTATE_ANGLE_Z: Float = 180.0 * .pi / 180
    private let CLOSE_HAND_ROTATE_ANGLE_X: Float = 90.0 * .pi / 180
    private let CLOSE_HAND_ROTATE_ANGLE_Z: Float = 180.0 * .pi / 180
    private let CLOSE_HAND_OFFSET_ON_PLANE: Float = 0.005
    
    private(set) var closeHandLocation = [Entity]() // fixed location for closed hand
    private(set) var discardLocation = [Entity]() // fixed location for discard tiles
    private(set) var openHandLocation = [Entity]() // fixed location for peng cards
    
    public var rootEntity = Entity()
    
    init(seat: PlayerSeat) {
        self.rootEntity.name = "player root"
        self.rootEntity.transform.rotation = seat.playerOrientation
        setPlayerLocation(playerLocation: seat.playerPosition)
    }
    
    /// A function that set the player's position relative to the table. Also set the position for their closed hand cards.
    func setPlayerLocation(playerLocation: SIMD3<Float>) {
        // 1. First set player location relative to table
        self.rootEntity.position = playerLocation
        
        // 2. Second add player's 14 closeHand tile locations
        for i in 1...14 {
            let entity = Entity()
            entity.name = "closeHand\(i)"
            let xOffset = 8 * MahjongEntity.TILE_WIDTH - MahjongEntity.TILE_WIDTH * Float(i)
            entity.position = SIMD3<Float>(xOffset, TableEntity.TABLE_HEIGHT + CLOSE_HAND_OFFSET_ON_PLANE, -2 * MahjongEntity.TILE_HEIGHT)
            
            self.rootEntity.addChild(entity)
            closeHandLocation.append(entity)
        }
        // 3. Third set each player's discard tile positions
        for j in 0...3 { // row
            for i in 1...8 { // column
                let entity = Entity()
                entity.name = "discard\(i*j)"
                let xOffset = MahjongEntity.TILE_WIDTH * Float(i) - 3 * MahjongEntity.TILE_WIDTH
                entity.position = SIMD3<Float>(xOffset, TableEntity.TABLE_HEIGHT, 0 - TableEntity.TABLE_WIDTH / 2 + 2.5 * MahjongEntity.TILE_HEIGHT + Float(j) * MahjongEntity.TILE_HEIGHT)
                
                self.rootEntity.addChild(entity)
                discardLocation.append(entity)
            }
        }
        
        // 4. Forth set each player's open hand positions
        for j in stride(from: 4, to: 0, by: -1) { // row
            for i in stride(from: 4, to: 0, by: -1) { // column
                let entity = Entity()
                entity.name = "openHand\(i)"
                let xOffset = MahjongEntity.TILE_WIDTH * Float(i) + 5.8 * MahjongEntity.TILE_WIDTH
                entity.position = SIMD3<Float>(xOffset, TableEntity.TABLE_HEIGHT, 0 - 5 * MahjongEntity.TILE_HEIGHT + Float(j) * MahjongEntity.TILE_HEIGHT)
                
                self.rootEntity.addChild(entity)
                openHandLocation.append(entity)
            }
        }
    }
    
    func rotateTileFacingPlayer(_ tile: Entity) {
        let quaternionX = simd_quatf(angle: CLOSE_HAND_ROTATE_ANGLE_X, axis: SIMD3<Float>.rotate_x)
        let quaternionZ = simd_quatf(angle: CLOSE_HAND_ROTATE_ANGLE_Z, axis: SIMD3<Float>.rotate_z)
        tile.transform.rotation = quaternionX * quaternionZ
    }
    
    func rotateTileFacingUp(_ tile: Entity) {
        let quaternionZ = simd_quatf(angle: DISCARD_ROTATE_ANGLE_Z, axis: SIMD3<Float>.rotate_z)
        tile.transform.rotation = quaternionZ
    }
    
    func resetTilePositionAndRotation(_ tile: Entity) {
        tile.position = SIMD3<Float>(0.0, 0.0, 0.0)
        tile.orientation = simd_quatf()
    }
}
