//
//  Commands.swift
//  PlacingOnTable
//
//  Created by Rex Ma on 3/27/24.
//

import Foundation

public protocol ICommand {
    func Execute();
}

public class Commands {
    public static func ExecuteCommand(command : ICommand) {
        command.Execute()
    }
}

/// A class that handle bot draw cards
public class DrawCommand: ICommand {
    private let player : Player
    private let mahjong : MahjongEntity
    init(player : Player, mahjong : MahjongEntity) {
        self.player = player
        self.mahjong = mahjong
    }
    
    public func Execute() {
        player.drawTileOperation(mahjong)
    }
}

public class DiscardCommand : ICommand {
    private let player : Player
    private let mahjong : MahjongEntity
    init(player : Player, mahjong : MahjongEntity) {
        self.player = player
        self.mahjong = mahjong
    }
    
    public func Execute() {
        player.discardTileOperation(mahjong)
    }
}

public class PongCommand : ICommand {
    private let player : Player
    private let mahjong : MahjongEntity
    init(player : Player, mahjong : MahjongEntity) {
        self.player = player
        self.mahjong = mahjong
    }
    
    public func Execute() {
        player.pong(mahjong)
    }
}

public class KangCommand : ICommand {
    private let player : Player
    private let mahjong : MahjongEntity
    private let selfKang : Bool
    init(player : Player, mahjong : MahjongEntity, selfkang : Bool) {
        self.player = player
        self.mahjong = mahjong
        self.selfKang = selfkang
    }
    
    public func Execute() {
        if selfKang {
            player.selfKang(mahjong)
        } else {
            player.kang(mahjong)
        }
    }
}

public class HuCommand : ICommand {
    private let player : Player
    private let mahjong : MahjongEntity?
    private let zimo: Bool
    init(player : Player, mahjong : MahjongEntity?, zimo: Bool) {
        self.player = player
        self.mahjong = mahjong
        self.zimo = zimo
    }
    
    public func Execute() {
        if zimo {
            player.zimo()
        } else {
            player.hu(mahjong!)
        }
    }
}

public class SetDiscardTypeCommand: ICommand {
    private let player : Player
    private let type : MahjongType
    init(player : Player, type : MahjongType) {
        self.player = player
        self.type = type
    }
    
    public func Execute() {
        player.setDiscardType(type)
    }
}

public class SwitchTilesCommand : ICommand {
    private let players : [Player]
    private let switchTiles : [String : [MahjongEntity]]
    private let order : SwitchOrder
    init(players: [Player], switchTiles: [String : [MahjongEntity]], order: SwitchOrder) {
        self.players = players
        self.switchTiles = switchTiles
        self.order = order
    }
    public func Execute() {
        // remove all tiles from hands FIRST, so closeHand won't exceed 14 tiles
        for key in switchTiles.keys {
            guard let player = players.first(where: {$0.playerID == key}) else {
                fatalError("player not found!")
            }
            player.removeTilesFromCloseHand(switchTiles[key]!)
        }
        
        for key in switchTiles.keys {
            guard let idx = players.firstIndex(where: {$0.playerID == key}) else {
                fatalError("player not found!")
            }
            
            var playerReceiveTile = players[idx]
            // FIXME: after adding dice, use dice to calculate switch order instead of enum
            // This way we can also take care of other num of player cases
            switch (order) {
            case .switchOrderLeft:
                playerReceiveTile = players[(idx+1) % players.count]
            case .switchOrderFront:
                playerReceiveTile = players[(idx+2) % players.count]
            case .switchOrderRight:
                playerReceiveTile = players[(idx+3) % players.count]
            }
            playerReceiveTile.addTilesToCloseHand(switchTiles[players[idx].playerID]!)
        }
    }
}
