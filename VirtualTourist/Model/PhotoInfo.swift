//
//  photoInfo.swift
//  VirtualTourist
//
//  Created by Eman Albarqi on 23/01/2019.
//  Copyright © 2019 Eman Albarqi. All rights reserved.
//

import Foundation

struct PhotosInfo: Codable {
    let photos: Photos
}

struct Photos: Codable {
    let pages: Int
    let photo: [PhotoInfo]
}

struct PhotoInfo: Codable {
    
    let url: String?
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_m"
        case title
    }
}
