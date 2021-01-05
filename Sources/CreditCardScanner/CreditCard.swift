//
//  CreditCard.swift
//
//
//  Created by josh on 2020/07/26.
//

import Foundation

///
public struct CreditCard {
    ///
    public var number: String?
    ///
    public var name: String?
    ///
    public var expireDate: DateComponents?
    
    ///身份证号姓名
    public var cardName: String?
    
    ///身份证名族
    public var cardNation:String?
    
    ///身份证住址
    public var cardAddress:String?
    
    ///身份证号码
    public var cardNumber:String?
}


public struct CreditCardInfo {
    ///
    public var number: [String]
    ///
    public var name: [String]
    ///
    public var expireDate: [DateComponents]
    
    ///身份证号姓名
    public var cardName: [String]
    
    ///身份证名族
    public var cardNation:[String]
    
    ///身份证住址
    public var cardAddress:[String]
    
    ///身份证号码
    public var cardNumber:[String]
}
