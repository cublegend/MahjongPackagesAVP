//
//  EntityUtilities.swift
//  PlacingOnTable
//
//  Created by Katherine Xiong on 3/9/24.
//

import Foundation
import RealityKit

public extension Entity {
    /// Returns the position of the entity specified in the app's coordinate system. On
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
