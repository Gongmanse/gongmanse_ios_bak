//
//  NoteTakingInput.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/18.
//

import Foundation

//"""
//{
//    "token" : "MzQ1MzQ0NDcxMTJjNmFkYzc2ZDQxNTVlOTgwYmI1MzU5MzdjYmFkYjA3NjkxZDZmM2JkNDg1YmMzNjY0NDA1MzQwMjAxZDZiNGUzMWFhNWM3MzJlOTEyZTFkNDg2YWZlMTY1NDM2Mzk0YmY5ZTI0ZTk1YTc2MzViZjA3N2Y5MTJrMVZvYSt6V2lOdzNyVDRHQzBWTHh4NDlmQXIrZ2dWOFNEMktZYmYrR0lMM3JGVlZlcmdTU0ZHWXo2eW90QlY0blpiYWFaMFFCU0ZqSmRvalBPQkZFZz09",
//    "video_id" : 23,
//    "sjson": "{
//        \"aspectRatio\":0.5095108695652174,
//        \"strokes\":[{\"points\":[{\"x\":0.4533333333333333,
//                                    \"y\":0.8389521059782609}],
//        \"color\":\"#d82579\",
//        \"size\":0.005333333333333333,
//        \"cap\":\"round\",
//        \"join\":\"round\",
//        \"miterLimit\":10}]
//        }"
//}
//"""

struct NoteTakingInput: Codable {
    
    var token: String
    var video_id: Int
    var sjson: String
}






