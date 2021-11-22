//
//  PaymentModel.swift
//  gongmanse
//
//  Created by 조철희 on 2021/11/22.
//
struct Purchase: Codable {
    var totalNum: String?
    var data: [PurchaseData]
}

struct PurchaseData: Codable {
    var iDuration: String
    var sPayMethod: String
    var dtPremiumActivate: String
    var dtPremiumExpire: String
    var dtInitiateDate: String
    var iPrice: String
}
