//
//  PlacedEntities.swift
//
//
//  Created by Rex Ma on 4/7/24.
//

import Foundation
import RealityKit

public class PlacedObject: Entity {
    public let fileName: String
    private let renderContent: ModelEntity

    public static let defaultCollisionGroup = CollisionGroup(rawValue: 1 << 29)

    let uiOrigin = Entity()
    
    init(fileName: String, renderContentToClone: ModelEntity) {
        self.fileName = fileName
        renderContent = renderContentToClone.clone(recursive: true)
        super.init()
        name = renderContent.name
        
        scale = renderContent.scale
        renderContent.scale = .one
        
        addChild(renderContent)
        addChild(uiOrigin)
        uiOrigin.position.y = extents.y / 2 // Position the UI origin in the object’s center.
        renderContent.components.set(GroundingShadowComponent(castsShadow: true))
    }
    
    required init() {
        fatalError("`init` is unimplemented.")
    }
}

public class MahjongEntity: PlacedObject, IMahjongFace, HasModel {
    public let mahjongType: MahjongType
    public let num: Int
    public let boundingBox: BoundingBox
    let originRotation: simd_quatf
    let originalMaterials: [Material]?
    
    public var owner = ""
    public var isHolding = false
    
    static let clickableCollisionGroup = CollisionGroup(rawValue: 1 << 25)
    
    private(set) static public var TILE_THICK: Float = 0
    private(set) static public var TILE_WIDTH: Float = 0
    private(set) static public var TILE_HEIGHT: Float = 0
    
    var isHighlighted: Bool = false {
        didSet {
            guard isHighlighted != oldValue else { return }
            if isHighlighted {
                let highlightMaterial = SimpleMaterial(color: .yellow, isMetallic: false)
                self.model?.materials = [highlightMaterial]
            } else {
                guard let originalMaterials = originalMaterials else { return }
                self.model?.materials = originalMaterials
            }
        }
    }
    
    var isClickable: Bool = false {
        didSet {
            guard isClickable != oldValue else { return }
            if isClickable {
                components[InputTargetComponent.self]!.allowedInputTypes = .indirect
                components.set(HoverEffectComponent())
                components[CollisionComponent.self]!.filter = CollisionFilter(group: MahjongEntity.clickableCollisionGroup, mask: .all)
            } else {
                components[InputTargetComponent.self]!.allowedInputTypes = []
                components.remove(HoverEffectComponent.self)
                components[CollisionComponent.self]!.filter = CollisionFilter(group: PlacedObject.defaultCollisionGroup, mask: .all)
            }
        }
    }
    
    var affectedByPhysics = false {
        didSet {
            guard affectedByPhysics != oldValue else { return }
            if affectedByPhysics {
                components[PhysicsBodyComponent.self]!.mode = .dynamic
            } else {
                components[PhysicsBodyComponent.self]!.mode = .static
            }
        }
    }
    
    var isBeingDragged = false {
        didSet {
            affectedByPhysics = !isBeingDragged
        }
    }
    
    init(fileName: String, renderContentToClone: ModelEntity, shapes: [ShapeResource]) {
        let tmp = fileName.split(separator: "_")
        switch tmp[0] {
        case "Tiao":
            mahjongType = .Tiao
        case "Tong":
            mahjongType = .Tong
        case "Wan":
            mahjongType = .Wan
        default:
            fatalError( "Input File Error" )
        }
        if let num = Int(tmp[1]){
            self.num = num
        } else {
            fatalError( "Input File Error" )
        }
        
        boundingBox = shapes[0].bounds
        originRotation = renderContentToClone.transform.rotation
        originalMaterials = renderContentToClone.model?.materials

        super.init(fileName: fileName, renderContentToClone: renderContentToClone)
        
        setMahjongDimension(boundingBox: boundingBox)
        
        // Make the object respond to gravity.
        let physicsMaterial = PhysicsMaterialResource.generate(restitution: 0.0)
        let physicsBodyComponent = PhysicsBodyComponent(shapes: shapes, mass: 1.0, material: physicsMaterial, mode: .static)
        
        components.set(physicsBodyComponent)
        components.set(CollisionComponent(shapes: shapes, isStatic: false,
                                          filter: CollisionFilter(group: PlacedObject.defaultCollisionGroup, mask: .all)))
        components.set(InputTargetComponent(allowedInputTypes: []))
    }
    
    func setMahjongDimension(boundingBox: BoundingBox) {
        MahjongEntity.TILE_WIDTH = boundingBox.max.x - boundingBox.min.x
        MahjongEntity.TILE_HEIGHT = boundingBox.max.z - boundingBox.min.z
        MahjongEntity.TILE_THICK = boundingBox.max.y - boundingBox.min.y
    }
    
    required init() {
        fatalError("`init` is unimplemented.")
    }
    
    public func sameAs(_ mahjong: IMahjongFace?) ->Bool {
        guard let m = mahjong else { return false }
        return m.num == num && m.mahjongType == mahjongType
    }
}

public class TableEntity: PlacedObject {
    public var boundingBox: BoundingBox

    public var previewEntity: Entity
    public static let previewCollisionGroup = CollisionGroup(rawValue: 1 << 15)
    private(set) static public var TABLE_WIDTH: Float = 0
    private(set) static public var TABLE_HEIGHT: Float = 0
    private(set) static public var TABLE_LENGTH: Float = 0
    
    init(fileName: String, renderContentToClone: ModelEntity, previewEntity: Entity, shapes: [ShapeResource]) {
        self.previewEntity = previewEntity
        self.boundingBox = shapes[0].bounds
        print("table bounding box: ", shapes[0].bounds)
        super.init(fileName: fileName, renderContentToClone: renderContentToClone)

        previewEntity.applyMaterial(UnlitMaterial(color: .gray.withAlphaComponent(0.5)))
        components.set(CollisionComponent(shapes: shapes, isStatic: false,
                                          filter: CollisionFilter(group: PlacedObject.defaultCollisionGroup, mask: .all)))
    }
    
    func setTableDimension(boundingBox: BoundingBox){
        TableEntity.TABLE_WIDTH = boundingBox.max.x - boundingBox.min.x
        TableEntity.TABLE_HEIGHT = boundingBox.max.y - boundingBox.min.y
        TableEntity.TABLE_LENGTH = boundingBox.max.z - boundingBox.min.z
    }
    
    required init() {
        fatalError("`init` is unimplemented.")
    }
}
