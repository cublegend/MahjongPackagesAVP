//
//  Utils.swift
//
//  Core classes and functions
//  Created by Rex Ma on 4/7/24.
//

import Foundation
import RealityKit

// MARK: Game
public enum SwitchOrder: CaseIterable {
    case switchOrderFront
    case switchOrderRight
    case switchOrderLeft
}

// MARK: Player seating configurations
public struct PlayerSeat {
    let playerPosition: SIMD3<Float>
    let playerOrientation: simd_quatf
}

public func getPlayerSeat(withIndex index: Int)-> PlayerSeat {
    return PlayerSeat(playerPosition: getPlayerPosition(index), playerOrientation: getPlayerOrientation(index))
}

// Player Location
fileprivate func getPlayerPosition(_ index: Int) -> SIMD3<Float>{
    switch index {
    case 0:
        return SIMD3<Float>(0, 0, 0 + TableEntity.TABLE_LENGTH / 2)
    case 1:
        return SIMD3<Float>(0 + TableEntity.TABLE_WIDTH / 2, 0, 0)
    case 2:
        return SIMD3<Float>(0, 0, 0 - TableEntity.TABLE_LENGTH / 2)
    case 3:
        return SIMD3<Float>(0 - TableEntity.TABLE_WIDTH / 2, 0, 0)
    default:
        fatalError("Player Position \(index) not set!")
    }
}

// Player Orientation
fileprivate func getPlayerOrientation(_ index: Int) -> simd_quatf {
    switch index {
    case 0:
        return simd_quatf(angle: 0, axis: SIMD3<Float>.rotate_y)
    case 1:
        return simd_quatf(angle: 90 * .pi / 180, axis: SIMD3<Float>.rotate_y)
    case 2:
        return simd_quatf(angle: 180 * .pi / 180, axis: SIMD3<Float>.rotate_y)
    case 3:
        return simd_quatf(angle: -90 * .pi / 180, axis: SIMD3<Float>.rotate_y)
    default:
        fatalError("Player Orientation \(index) not set!")
    }
}
