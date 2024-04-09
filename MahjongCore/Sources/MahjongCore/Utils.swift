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

// MARK: Fan
public enum Fan: String, CaseIterable, Comparable {
    public static func < (lhs: Fan, rhs: Fan) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case QingShiBa // 6 shibaluohan + 2 qing = 8 fan
    
    case Tian // max fan or 6 fan
    case Di // max fan or 6 fan
    
    case QingLong // 2 qidui + 2 qing + 1 extra + 1 gen = 6 fan
    case ShiBaLuoHan // 4 gen + 1 jingou + 1 pongpong = 6 fan
    
    case QingQiDui // 2 qing + 2 qidui = 4 fan
    case QingJinGou // 1 jingou + 1 pongpong + 2 qing = 4 fan
    case QingYaoJiu // 2 qing + 2 yaojiu = 4 fan
    case LongQiDui // 2 qidui + 1 extra + 1 gen = 4 fan
    
    case QingPong // 2 qing + 1 pong = 3 fan
    
    case QiDuiZi // 2 fan
    case QingYiSe // 2 fan
    case YaoJiu // 2 fan
    case JinGou // 1 jingou + 1 pongpong = 2 fan
    
    case PongPongHu
    case Gen
    case ZiMo // handled in the hu function, if mahjong==nil, zimo = true
    case KangHua
    case KangPao
    case QiangKang //x
    case HaiDi // handled in the hu function, passing lastTileDrawn from mahjongSet in appstate to hu()
    
    case PinHu
    
    public var name: String { rawValue }
    
    public var value: Int {
        switch self {
        case .QingShiBa:
            return 8
        case .ShiBaLuoHan, .QingLong, .Tian, .Di:
            return 6
        case .QingQiDui, .QingYaoJiu, .QingJinGou, .LongQiDui:
            return 4
        case .QingPong:
            return 3
        case .QiDuiZi, .QingYiSe, .YaoJiu:
            return 2
        case .PongPongHu, .JinGou, .ZiMo, .KangHua, .KangPao, .QiangKang, .HaiDi, .Gen:
            return 1
        case .PinHu:
            return 0
        }
    }
    
    public static func sum(_ fans: [Fan])->Int {
        return fans.map({$0.value}).reduce(0,+)
    }
}

// MARK: Entity

extension Entity {/// Returns the position of the entity specified in the app's coordinate system. On
    /// iOS and macOS, which don't have a device native coordinate system, scene
    /// space is often referred to as "world space".
    var scenePosition: SIMD3<Float> {
        get { position(relativeTo: nil) }
        set { setPosition(newValue, relativeTo: nil) }
    }
    
    /// Returns the orientation of the entity specified in the app's coordinate system. On
    /// iOS and macOS, which don't have a device native coordinate system, scene
    /// space is often referred to as "world space".
    var sceneOrientation: simd_quatf {
        get { orientation(relativeTo: nil) }
        set { setOrientation(newValue, relativeTo: nil) }
    }
    
    func applyMaterial(_ material: Material) {
        if let modelEntity = self as? ModelEntity {
            modelEntity.model?.materials = [material]
        }
        for child in children {
            child.applyMaterial(material)
        }
    }

    var extents: SIMD3<Float> { visualBounds(relativeTo: self).extents }

    func look(at target: SIMD3<Float>) {
        look(at: target,
             from: position(relativeTo: nil),
             relativeTo: nil,
             forward: .positiveZ)
    }
}

public extension SIMD3 where Scalar == Float {
    
    /// Returns a vector that represents a rotate vector.
    static let rotate_x = SIMD3<Float>(x: 1, y: 0, z: 0)
    static let rotate_y = SIMD3<Float>(x: 0, y: 1, z: 0)
    static let rotate_z = SIMD3<Float>(x: 0, y: 0, z: 1)

    /// The magnitude of this vector.
    var magnitude: Float {
        return simd_length(self)
    }
    
    /// Returns a vector with all values set to `0.0`.
    static let zero = SIMD3<Float>.zero
}
