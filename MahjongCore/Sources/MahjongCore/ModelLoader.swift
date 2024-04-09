//
//  MahjongTableEntity.swift
//  PlacingOnTable
//
//  Created by Katherine Xiong on 3/9/24.
//

import Foundation
import RealityKit

@MainActor
public final class ModelLoader {
    private static var didStartLoading = false
    private static var didFinishLoading = false
    
    private static var table = [TableEntity]()
    private static var mahjongs = [MahjongEntity]()
    
    public static func getMahjongs() -> [MahjongEntity] {
//        if !didFinishLoading {
//            fatalError("Models didn't finish loading!")
//        }
        return mahjongs
    }
    
    public static func getTable() -> TableEntity {
        if !didFinishLoading {
            fatalError("Models didn't finish loading!")
        }
        return table[0]
    }
    
    public static func loadObjects() async {
        // Only allow one loading operation at any given time.
        guard !didStartLoading else { return }
        didStartLoading.toggle()

        guard let resourceURLs = Bundle.module.urls(forResourcesWithExtension: "usdz", subdirectory: nil) else {
            fatalError("No resources found")
        }
        guard resourceURLs.count != 0 else {
            fatalError("No models detected!")
        }
        
        await withTaskGroup(of: Void.self) { group in
            for url in resourceURLs {
                group.addTask {
                    if url.lastPathComponent == "MahjongTable.usdz" {
                        do {
                            try await self.loadTable(url)
                        } catch {
                            fatalError("Failed loading table")
                        }
                    } else {
                        do {
                            try await loadMahjong(url)
                        } catch {
                            fatalError("Failed loading mahjongs")
                        }
                    }
                }
            }
        }
        didFinishLoading = true
    }
    
    private static func loadMahjong(_ url: URL) throws {
        var modelEntity: ModelEntity
        let fileName = url.deletingPathExtension().lastPathComponent
        try modelEntity = ModelEntity.loadModel(contentsOf: url)
        modelEntity.name = fileName

        let shape = ShapeResource.generateConvex(from: modelEntity.model!.mesh)
        for _ in 1...4 {
            self.mahjongs.append(MahjongEntity(fileName: fileName, renderContentToClone: modelEntity, shapes: [shape]))
        }
    }
    
    private static func loadTable(_ url: URL) throws {
        var modelEntity: ModelEntity
        var previewEntity: Entity
        let fileName = url.lastPathComponent
        // Load the USDZ as a ModelEntity.
        try modelEntity = ModelEntity.loadModel(contentsOf: url)
        modelEntity.name = fileName

        // Load the USDZ as a regular Entity for previews.
        try previewEntity = Entity.loadModel(contentsOf: url)
        previewEntity.name = "Preview of \(modelEntity.name)"

        // Add collision and input target for preview entity
        let shape = ShapeResource.generateConvex(from: modelEntity.model!.mesh)
        previewEntity.components.set(CollisionComponent(shapes: [shape], isStatic: false,
                                                        filter: CollisionFilter(group: TableEntity.previewCollisionGroup, mask: .all)))

        // Ensure the preview only accepts indirect input (for tap gestures).
        let previewInput = InputTargetComponent(allowedInputTypes: [.indirect])
        previewEntity.components[InputTargetComponent.self] = previewInput

        let shapes = previewEntity.components[CollisionComponent.self]!.shapes
        let table = TableEntity(fileName: fileName, renderContentToClone: modelEntity, previewEntity: previewEntity, shapes: shapes)
        self.table.append(table)
    }
}
