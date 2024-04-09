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
        if !didFinishLoading {
            fatalError("Models didn't finish loading!")
        }
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

        // Get a list of all USDZ files in this app’s main bundle and attempt to load them.
        var usdzFiles: [String] = []
        if let resourcesPath = Bundle.main.resourcePath {
            try? usdzFiles = FileManager.default.contentsOfDirectory(atPath: resourcesPath).filter { $0.hasSuffix(".usdz") }
        }
        
        assert(!usdzFiles.isEmpty, "Add USDZ files to the '3D models' group of this Xcode project.")
        
        await withTaskGroup(of: Void.self) { group in
            for usdz in usdzFiles {
                if usdz == "MahjongTable.usdz" {
                    await self.loadTable(usdz)
                } else {
                    let fileName = URL(string: usdz)!.deletingPathExtension().lastPathComponent
                    
                    group.addTask {
                        await loadMahjong(fileName)
                    }
                }
            }
        }
        didFinishLoading = true
    }
    
    private static func loadMahjong(_ fileName: String) async {
        var modelEntity: ModelEntity
        do {
            // Load the USDZ as a ModelEntity.
            try await modelEntity = ModelEntity(named: fileName)
            modelEntity.name = fileName
        } catch {
            fatalError("Failed to load model \(fileName)")
        }

        do {
            let shape = try await ShapeResource.generateConvex(from: modelEntity.model!.mesh)
            for _ in 1...4 {
                self.mahjongs.append(MahjongEntity(fileName: fileName, renderContentToClone: modelEntity, shapes: [shape]))
            }
        } catch {
            fatalError("Failed to generate shape resource for model \(fileName)")
        }
    }
    
    private static func loadTable(_ fileName: String) async {
        var modelEntity: ModelEntity
        var previewEntity: Entity
        do {
            // Load the USDZ as a ModelEntity.
            try await modelEntity = ModelEntity(named: fileName)
            modelEntity.name = fileName

            // Load the USDZ as a regular Entity for previews.
            try await previewEntity = Entity(named: fileName)
            previewEntity.name = "Preview of \(modelEntity.name)"
        } catch {
            fatalError("Failed to load model \(fileName)")
        }

        // Add collision and input target for preview entity
        do {
            let shape = try await ShapeResource.generateConvex(from: modelEntity.model!.mesh)
            previewEntity.components.set(CollisionComponent(shapes: [shape], isStatic: false,
                                                            filter: CollisionFilter(group: TableEntity.previewCollisionGroup, mask: .all)))

            // Ensure the preview only accepts indirect input (for tap gestures).
            let previewInput = InputTargetComponent(allowedInputTypes: [.indirect])
            previewEntity.components[InputTargetComponent.self] = previewInput
        } catch {
            fatalError("Failed to generate shape resource for model \(fileName)")
        }

        let shapes = previewEntity.components[CollisionComponent.self]!.shapes
        let table = TableEntity(fileName: fileName, renderContentToClone: modelEntity, previewEntity: previewEntity, shapes: shapes)
        self.table.append(table)
    }
}
