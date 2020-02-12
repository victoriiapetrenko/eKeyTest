//
//  PhotosViewModel.swift
//  eKey
//
//  Created by Victoria Petrenko on 2/12/20.
//  Copyright © 2020 Test App. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


let postPhotoURL = "https://jsonplaceholder.typicode.com/posts"

//MARK: - PhotoItem
struct PhotoItem {
    var image: UIImage?
    var photoType: PhotoType
    
    var json: [String: Any] {
        var data: [String: Any] = ["title": photoType]
        if let photoImage = image {
            data["image"] = photoImage.pngData()
        }
        return data
    }
}

class PhotosViewModel {
    
    //MARK: Properties
    var photos: Array<PhotoItem> = []
    var selectedPhoto: PhotoItem?
    var photosData: [String: Any] {
        var data: [String: Any] = ["title": "Photo post example"]
        var images: Array<Any> = []
        for photo in photos {
            images.append(photo.json)
        }
        data["images"] = images
        return data
    }
    
    //MARK: - Life-Cycle
    init() {
       fetchPhotoItems()
    }
    
    //MARK: - Private functions
    private func fetchPhotoItems() {
        
        //Create photo items with empty placeholders
        photos.append(PhotoItem(photoType: .frontSide))
        photos.append(PhotoItem(photoType: .backSide))
        photos.append(PhotoItem(photoType: .leftSide))
        photos.append(PhotoItem(photoType: .rightSide))
    }
    
    private func getPhotoDataParams(comment: String?) -> [String: Any] {
        var data = photosData
        data["body"] = comment
        return data
    }
    
    //MARK: - Public functions
    func addPhotoImage(image: UIImage?) {
        guard let photoItem = selectedPhoto else {
            return
        }
        
        let updatedPhotos = photos.map {(photo) -> PhotoItem in
            var item = photo
            if photo.photoType == photoItem.photoType {
              item.image = image
            }
            return item
        }
        
        photos = updatedPhotos
    }
    
    func deletePhotoImage() {
        guard let photoItem = selectedPhoto else {
            return
        }
        
        let updatedPhotos = photos.map {(photo) -> PhotoItem in
            var item = photo
            if photo.photoType == photoItem.photoType {
              item.image = nil
            }
            return item
        }
        
        photos = updatedPhotos
    }
    
    func postPhotos(comment: String?) {
        
        //Example of sending data
        let params = getPhotoDataParams(comment: comment)

        request(postPhotoURL, method: .post, parameters: params).validate().responseJSON { responseJSON in

            switch responseJSON.result {
            case .success(let value):
                print("Post sucess", value)
                break
            case .failure(let error):
                print(error)
            }
        }
    }
}
