//
//  MahjongSet.swift
//
//
//  Created by Rex Ma on 4/7/24.
//

import Foundation
import RealityKit
import simd

public class MahjongSet {
    public static let TOTAL_TILES = 108
    public static var discardPile: [String: NSMutableArray] = [:]
    public static var lastTileDiscarded: MahjongEntity?
    
    public let rootEntity: Entity = Entity()
    public var mahjongs: [MahjongEntity]
    
    // A bool array stores if the mahjong in current index is already drawn.
    private var mahjongIsDrown: [Bool] = []
    private var drawIndex = 0
    private var lastTileIndex = TOTAL_TILES

    // A bool value to determine if all tiles have been drawn.
    public var lastTileDrawn: Bool {
        drawIndex >= MahjongSet.TOTAL_TILES || lastTileIndex < 0 || drawIndex > lastTileIndex
    }
    
    @MainActor
    init() {
        mahjongs = ModelLoader.getMahjongs()
        reset()
    }
    
    func reset() {
        mahjongIsDrown = []
        for mahjong in mahjongs {
            mahjong.isClickable = false
            mahjong.position = SIMD3<Float>(0.0, 0.0, 0.0)
            mahjong.orientation = simd_quatf()
            rootEntity.addChild(mahjong)
            
            // Initialize mahjongIsDrown
            mahjongIsDrown.append(false)
        }
        
        drawIndex = 0
        lastTileIndex = 107

        shuffle()
        makeWall()
    }
    
    private func shuffle() {
        for i in 1...MahjongSet.TOTAL_TILES {
            let tmp = mahjongs[i-1]
            let randomIndex = Int.random(in: 1...MahjongSet.TOTAL_TILES)
            mahjongs[i-1] = mahjongs[randomIndex-1]
            mahjongs[randomIndex-1] = tmp
        }
    }
    
    private func makeWall() {
        let width = MahjongEntity.TILE_WIDTH
        let height = MahjongEntity.TILE_HEIGHT
        let thick = MahjongEntity.TILE_THICK
        
        let startX = -6.0 * width
        let startZ = -6.5 * width
        let startY = thick + TableEntity.TABLE_HEIGHT

        // far away from player
        for i in 0...12 {
            for j in 0...1 {
                mahjongs[i*2 + j].setPosition(SIMD3<Float>(startX + Float(i) * width, startY - Float(j) * thick, -7 * width - 0.5 * height), relativeTo: nil)
            }
        }
        // close to player
        for i in 0...12 {
            for j in 0...1 {
                mahjongs[79 - i*2-j].setPosition(SIMD3<Float>(startX + Float(i) * width, startY - (1 - Float(j)) * thick, 7 * width + 0.5 * height), relativeTo: nil)
            }
        }
        // player right
        for i in 0...13 {
            for j in 0...1 {
                mahjongs[26 + i*2+j].setPosition(SIMD3<Float>(0.5 * height + 6.5 * width, startY - Float(j) * thick, startZ + Float(i) * width), relativeTo: nil)
                let quaternion = simd_quatf(angle: 90.0 * .pi / 180, axis: SIMD3<Float>.rotate_y)
                mahjongs[26 + i*2+j].transform.rotation = quaternion
            }
        }
        // player left
        for i in 0...13 {
            for j in 0...1 {
                mahjongs[107 - i*2-j].setPosition(SIMD3<Float>(-0.5 * height - 6.5 * width, startY - (1 - Float(j)) * thick, startZ + Float(i) * width), relativeTo: nil)
                let quaternion = simd_quatf(angle: 90.0 * .pi / 180, axis: SIMD3<Float>.rotate_y)
                mahjongs[80 + i*2+j].transform.rotation = quaternion
            }
        }
    }
    
    public func draw() -> MahjongEntity? {
        if lastTileDrawn {
            return nil
        }
        
        if mahjongIsDrown[drawIndex] {
            drawIndex += 1
        }
        
        let tile = mahjongs[drawIndex]
        mahjongIsDrown[drawIndex] = true
        drawIndex += 1
        
        return tile
    }
    
    public func drawLastTile() -> MahjongEntity? {
        if lastTileDrawn {
            return nil
        }
        
        if lastTileIndex % 2 != 0 && !mahjongIsDrown[lastTileIndex - 1] && lastTileIndex - 1 > drawIndex {
            let tile = mahjongs[lastTileIndex - 1]
            mahjongIsDrown[lastTileIndex - 1] = true
            return tile
        } else if lastTileIndex % 2 != 0 && !mahjongIsDrown[lastTileIndex - 1] && lastTileIndex - 1 == drawIndex {
            let tile = mahjongs[lastTileIndex-1]
            mahjongIsDrown[lastTileIndex - 1] = true
            drawIndex += 1
            return tile
        } else if lastTileIndex % 2 != 0 && mahjongIsDrown[lastTileIndex - 1] && lastTileIndex - 1 > drawIndex {
            let tile = mahjongs[lastTileIndex]
            mahjongIsDrown[lastTileIndex] = true
            lastTileIndex -= 2
            return tile
        } else if lastTileIndex % 2 != 0 && mahjongIsDrown[lastTileIndex - 1] && lastTileIndex == drawIndex {
            let tile = mahjongs[lastTileIndex]
            mahjongIsDrown[lastTileIndex] = true
            lastTileIndex -= 1
            return tile
        } else {
            return nil
        }
    }
}
