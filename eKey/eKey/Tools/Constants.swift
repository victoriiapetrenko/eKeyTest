//
//  Constants.swift
//  eKey
//
//  Created by Victoria Petrenko on 2/12/20.
//  Copyright © 2020 Test App. All rights reserved.
//

import Foundation

public enum PhotoType: String {
    case frontSide = "Front Side"
    case backSide = "Back Side"
    case leftSide = "Left Side"
    case rightSide = "Right Side"
}

struct Constants {
    
    static let commentPlaceholder = "Enter Comment"
    static let takePhotoFromGallery = "Take photo from gallery"
    static let takePhotoFromCamera = "Take photo from camera"
    static let deletePhoto = "Delete Photo"
    static let cancel = "Cancel"
}
