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
        print("add to discard pile:\(tile.name), now \(dp.count) count")
    }
    
    func removeFromDiscardPile(_ tile: MahjongEntity, from ownerID: String) {
        print(discardPile[ownerID])
        guard let dp = discardPile[ownerID] else {
            fatalError("No discard pile for \(ownerID)")
        }
        // if failed, no effect
        dp.remove(tile)
        print("discard pile removed:\(tile.name), now \(dp.count) left")
    }
}
