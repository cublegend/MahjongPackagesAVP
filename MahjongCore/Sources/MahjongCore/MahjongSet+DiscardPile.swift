//
//  MahjongSet+DiscardPile.swift
//
//
//  Created by Rex Ma on 4/8/24.
//

extension MahjongSet {
    static func removeFromDiscardPile(_ tile: MahjongEntity) {
        guard let dp = MahjongSet.discardPile[tile.owner] else { fatalError("No discard pile for \(tile.owner)")
        }
        // if failed, no effect
       dp.remove(tile)
    }
}
