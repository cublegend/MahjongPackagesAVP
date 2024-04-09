//
//  GeometryUtilities.swift
//  PlacingOnTable
//
//  Created by Katherine Xiong on 3/9/24.
//

import Foundation
import RealityKit
import UIKit
import ARKit

public extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        self[SIMD3(0, 1, 2)]
    }
}

public extension simd_float4x4 {
    init(translation vector: SIMD3<Float>) {
        self.init(SIMD4<Float>(1, 0, 0, 0),
                  SIMD4<Float>(0, 1, 0, 0),
                  SIMD4<Float>(0, 0, 1, 0),
                  SIMD4<Float>(vector.x, vector.y, vector.z, 1))
    }
    
    var translation: SIMD3<Float> {
        get {
            columns.3.xyz
        }
        set {
            self.columns.3 = [newValue.x, newValue.y, newValue.z, 1]
        }
    }
    
    var rotation: simd_quatf {
        simd_quatf(rotationMatrix)
    }
    
    var xAxis: SIMD3<Float> { columns.0.xyz }
    
    var yAxis: SIMD3<Float> { columns.1.xyz }
    
    var zAxis: SIMD3<Float> { columns.2.xyz }
    
    var rotationMatrix: simd_float3x3 {
        matrix_float3x3(xAxis,
                        yAxis,
                        zAxis)
    }
    
    /// Get a gravity-aligned copy of this 4x4 matrix.
    var gravityAligned: simd_float4x4 {
        // Project the z-axis onto the horizontal plane and normalize to length 1.
        let projectedZAxis: SIMD3<Float> = [zAxis.x, 0.0, zAxis.z]
        let normalizedZAxis = normalize(projectedZAxis)
        
        // Hardcode y-axis to point upward.
        let gravityAlignedYAxis: SIMD3<Float> = [0, 1, 0]
        
        let resultingXAxis = normalize(cross(gravityAlignedYAxis, normalizedZAxis))
        
        return simd_matrix(
            SIMD4(resultingXAxis.x, resultingXAxis.y, resultingXAxis.z, 0),
            SIMD4(gravityAlignedYAxis.x, gravityAlignedYAxis.y, gravityAlignedYAxis.z, 0),
            SIMD4(normalizedZAxis.x, normalizedZAxis.y, normalizedZAxis.z, 0),
            columns.3
        )
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
