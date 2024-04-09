//
//  ModelEntity+Extension.swift
//  TimeForCube
//
//  Helper tools to show the detected hands and planes
//  Created by Katherine Xiong on 3/3/24.
//

import Foundation
import RealityKit

public extension ModelEntity {
    class func createFingertip() -> ModelEntity {
        let entity = ModelEntity(
            mesh: .generateSphere(radius: 0.005), // 5mm
            materials: [UnlitMaterial(color: .cyan)],
            collisionShape: .generateSphere(radius: 0.005),
            mass: 0.0
        )

        entity.components.set(PhysicsBodyComponent(mode: .kinematic))
        entity.components.set(OpacityComponent(opacity: 1))

        return entity
    }
}
