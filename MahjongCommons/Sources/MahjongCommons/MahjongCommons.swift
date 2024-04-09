// The Swift Programming Language
// https://docs.swift.org/swift-book
// This File contains all of the commonly used protocols, base classes and functions
// across the entire application

import RealityKit

// MARK: Mahjong
public protocol IMahjongFace {
    var mahjongType: MahjongType {get}
    var num: Int {get}
    func sameAs(_ mahjong: IMahjongFace?) ->Bool
}

public func sortTiles<T:IMahjongFace>(_ hand: inout [T]) {
    hand.sort { (a: IMahjongFace, b: IMahjongFace) -> Bool in
        if a.mahjongType != b.mahjongType {
            return a.mahjongType < b.mahjongType
        } else {
            return a.num > b.num
        }
    }
}

public enum MahjongType: Int, CaseIterable, Identifiable{
    case Wan = 3
    case Tong = 2
    case Tiao = 1
    public var id: Self { self }
    
    public var text: String {
        switch self {
        case .Wan:
            "Wan"
        case .Tong:
            "Tong"
        case .Tiao:
            "Tiao"
        }
    }
}
extension MahjongType: Comparable {
    public static func < (lhs: MahjongType, rhs: MahjongType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

// MARK: Fan
public enum Fan: String, CaseIterable, Comparable {
    public static func < (lhs: Fan, rhs: Fan) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case QingShiBa // 6 shibaluohan + 2 qing = 8 fan
    
    case Tian // max fan or 6 fan
    case Di // max fan or 6 fan
    
    case QingLong // 2 qidui + 2 qing + 1 extra + 1 gen = 6 fan
    case ShiBaLuoHan // 4 gen + 1 jingou + 1 pongpong = 6 fan
    
    case QingQiDui // 2 qing + 2 qidui = 4 fan
    case QingJinGou // 1 jingou + 1 pongpong + 2 qing = 4 fan
    case QingYaoJiu // 2 qing + 2 yaojiu = 4 fan
    case LongQiDui // 2 qidui + 1 extra + 1 gen = 4 fan
    
    case QingPong // 2 qing + 1 pong = 3 fan
    
    case QiDuiZi // 2 fan
    case QingYiSe // 2 fan
    case YaoJiu // 2 fan
    case JinGou // 1 jingou + 1 pongpong = 2 fan
    
    case PongPongHu
    case Gen
    case ZiMo // handled in the hu function, if mahjong==nil, zimo = true
    case KangHua
    case KangPao
    case QiangKang //x
    case HaiDi // handled in the hu function, passing lastTileDrawn from mahjongSet in appstate to hu()
    
    case PinHu
    
    public var name: String { rawValue }
    
    public var value: Int {
        switch self {
        case .QingShiBa:
            return 8
        case .ShiBaLuoHan, .QingLong, .Tian, .Di:
            return 6
        case .QingQiDui, .QingYaoJiu, .QingJinGou, .LongQiDui:
            return 4
        case .QingPong:
            return 3
        case .QiDuiZi, .QingYiSe, .YaoJiu:
            return 2
        case .PongPongHu, .JinGou, .ZiMo, .KangHua, .KangPao, .QiangKang, .HaiDi, .Gen:
            return 1
        case .PinHu:
            return 0
        }
    }
    
    public static func sum(_ fans: [Fan])->Int {
        return fans.map({$0.value}).reduce(0,+)
    }
}
