/*
 Example
 {
     "data": {
         "sNotes": [
             "uploads/videos/2017/강영미/시어/170417_국어_중등_강영미_001_시어_12.png",
             "uploads/videos/2017/강영미/시어/170417_국어_중등_강영미_001_시어_22.png"
         ],
         "sJson": {
             "aspectRatio": "0.5095108695652174",
             "strokes": [
                 {
                     "cap": "round",
                     "join": "round",
                     "miterLimit": 10,
                     "color": "#d82579",
                     "points": [
                         {
                             "x": 0.15460205,
                             "y": 0.24601291
                         }
                     ],
                     "size": 0.004514673
             ]
         }
     }
 }
 */

struct NoteResponse: Codable {
    
    var data: NoteData?
}

struct NoteData: Codable {
    
    var sNotes: [String]
    var sJson: [sJson]?
}

struct sJson: Codable {
    
    var aspectRatio: Double

    var strokes: [strokes]?
}

struct strokes: Codable {
    
    var cap: String
    var join: String
    var miterLimit: Int
    var color: String
    var points: [points]
    var size: Double
}

struct points: Codable {
    var x: Double
    var y: Double
}
