//
//  Banners.swift
//  NapoleonTestTask
//
//  Created by Артем Жорницкий on 31/03/2019.
//  Copyright © 2019 Артем Жорницкий. All rights reserved.
//

import Foundation
class Banner: Decodable {
    var id: String?
    var image: String?
    var title: String?
    var desc: String?
    
    init(id: String, image: String, title: String, desc: String) {
        self.id = id
        self.image = image
        self.title = title
        self.desc = desc
    }
}


