//
//  Offer.swift
//  NapoleonTestTask
//
//  Created by Артем Жорницкий on 26/03/2019.
//  Copyright © 2019 Артем Жорницкий. All rights reserved.
//

import Foundation

class Offer: Decodable {
    
    var name: String?
    var id: String?
    var desc: String?
    var groupName: String
    var type: String?
    var image: String?
    var price: Int?
    var discount: Float?
    
    
    init(name: String?, id: String?, description: String?, groupName: String, productType: String?, imageURL: String?, price: Int?, discount: Float?) {
        self.name = name
        self.id = id
        self.desc = description
        self.groupName = groupName
        self.type = productType
        self.image = imageURL
        self.price = price
        self.discount = discount
    }
    
}
