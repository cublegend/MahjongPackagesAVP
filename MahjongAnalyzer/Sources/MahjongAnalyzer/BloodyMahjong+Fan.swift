//
//  BloddyAnalyzer+Fan.swift
//
//
//  Created by Rex Ma on 4/8/24.
//

import Foundation
import MahjongCommons

extension BloodyMahjong {
    public func findBestFanGroup(closeHand: [IMahjongFace], openHand: [IMahjongFace]) -> [Fan] {
        BloodyMahjong.findBestFanGroup(closeHand: closeHand, openHand: openHand)
    }
    
    static func findBestFanGroup(closeHand: [IMahjongFace], openHand: [IMahjongFace]) -> [Fan] {
        // all the fans calculated bottom up
        var dict: [Fan:Bool] = [:]
        
        // 1 fan
        var genCount = countGen(fullHand: closeHand+openHand)
        
        dict[.PongPongHu] = isPongPong(closeHand: closeHand)
        
        // 2 fan
        if isJinGou(closeHandCount: closeHand.count) {
            dict[.JinGou] = true
            dict[.PongPongHu] = false
        }
        dict[.QiDuiZi] = isQiDuiZi(closeHand: closeHand)
        dict[.QingYiSe] = isQingYiSe(fullHand: closeHand+openHand)
        dict[.YaoJiu] = isYaoJiu(closeHand: closeHand, openHand: openHand)
        
        if isShiBaLuoHan(openHand: openHand) {
            dict[.ShiBaLuoHan] = true
            dict[.JinGou] = false
            genCount -= 4
        }
        
        // start to build up
        
        // qidui >= yaojiu
        if dict[.QiDuiZi, default: false] {
            dict[.YaoJiu] = false
        }
        
        if dict[.QingYiSe, default: false] {
            // jingou > pongpong
            if dict[.JinGou, default: false] {
                dict[.QingJinGou] = true
                dict[.JinGou] = false
                dict[.QingYiSe] = false
            } else if dict[.QiDuiZi, default: false] {
                if genCount > 0 {
                    dict[.QingLong] = true
                    dict[.QiDuiZi] = false
                    dict[.QingYiSe] = false
                    genCount -= 1
                } else {
                    dict[.QingQiDui] = true
                    dict[.QiDuiZi] = false
                    dict[.QingYiSe] = false
                }
            } else if dict[.YaoJiu, default: false] {
                dict[.QingYaoJiu] = true
                dict[.YaoJiu] = false
                dict[.QingYiSe] = false
            } else if dict[.PongPongHu, default: false] {
                dict[.QingPong] = true
                dict[.PongPongHu] = false
                dict[.QingYiSe] = false
            } else if dict[.ShiBaLuoHan, default: false] {
                dict[.QingShiBa] = true
                dict[.ShiBaLuoHan] = false
                dict[.QingYiSe] = false
            }
        }
        
        if dict[.QiDuiZi, default: false] && genCount > 0 {
            dict[.QiDuiZi] = false
            dict[.LongQiDui] = true
            genCount -= 1
        }
        
        var result = dict.filter { $0.value }.map { $0.key }
        
        // check if anything other than extra fans are registered
        if result.filter({ ![.ZiMo,.KangHua,.KangPao,.QiangKang,.HaiDi,.Gen].contains($0)}).count == 0 {
            // if not, means pinhu
            result.append(.PinHu)
        }
        
        for _ in 0..<genCount {
            result.append(.Gen)
        }
        
        return result
    }
    
    static func isPongPong(closeHand: [IMahjongFace])->Bool {
        let hand = parseMahjongs(closeHand)
        var findPair = false
        for count in hand {
            if count == 3 || count == 0 {
                continue
            }
            if findPair {
                return false
            } else if !findPair && count == 2 {
                findPair = true
            } else {
                return false
            }
        }
        return true
    }
    
    static func isQiDuiZi(closeHand: [IMahjongFace])->Bool {
        return qiDuiShanten(mahjongHand: closeHand) == -1
    }
    
    static func isYaoJiu(closeHand: [IMahjongFace], openHand: [IMahjongFace])->Bool {
        let open = parseMahjongs(openHand)
        let close = parseMahjongs(closeHand)
        // since only pong or kang is possible
        // all open hand should be 1s or 9s
        for i in 0..<open.count {
            if open[i] > 0 && ![0,8,9,17,18,26].contains(i) {
                return false
            }
        }
        // query the yaojiu table for closeHand
        let man = Array(close[0..<9])
        let pin = Array(close[9..<18])
        let suo = Array(close[18..<27])
        return TableManager.isGroupYaoJiu(man) && TableManager.isGroupYaoJiu(pin)
            && TableManager.isGroupYaoJiu(suo)
    }
    
    static func isShiBaLuoHan(openHand: [IMahjongFace])->Bool {
        return parseMahjongs(openHand).filter({$0 == 4}).count == 4
    }
    
    static func isQingYiSe(fullHand: [IMahjongFace])->Bool {
        let parsed = parseMahjongs(fullHand)
        let manSum = parsed[0..<9].reduce(0, +)
        let pinSum = parsed[9..<18].reduce(0, +)
        let souSum = parsed[18..<27].reduce(0, +)
        let suitsGreaterThanZero = [manSum, pinSum, souSum].filter { $0 > 0 }.count
        return suitsGreaterThanZero == 1
    }
    
    static func isJinGou(closeHandCount: Int)->Bool {
        return closeHandCount == 2
    }
    
    static func countGen(fullHand: [IMahjongFace])->Int {
        return parseMahjongs(fullHand).filter({$0 == 4}).count
    }
    
    
}
