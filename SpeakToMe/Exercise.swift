//
//  Exercise.swift
//  SpeakToMe
//
//  Created by Veronica Adamson on 10/18/17.
//

import Foundation
class Exercise{
    var id: String?
    var text: String?
    
    
    init(id: String, dictionary: AnyObject) {
        self.id = id
        text = dictionary.object(forKey: "text") as? String
        
        
    }
}
