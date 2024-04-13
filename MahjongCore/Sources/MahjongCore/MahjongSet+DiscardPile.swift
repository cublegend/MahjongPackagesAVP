//
//  MahjongSet+DiscardPile.swift
//
//
//  Created by Rex Ma on 4/8/24.
//

extension MahjongSet {
    func addToDiscardPile(_ tile: MahjongEntity, to ownerID: String) {
        guard let dp = discardPile[ownerID] else {
            fatalError("No discard pile for \(ownerID)")
        }
        dp.add(tile)
    }
    
    func removeFromDiscardPile(_ tile: MahjongEntity, from ownerID: String) {
        guard let dp = discardPile[ownerID] else {
            fatalError("No discard pile for \(ownerID)")
        }
        // if failed, no effect
        dp.remove(tile)
    }
}
