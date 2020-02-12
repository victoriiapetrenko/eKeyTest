//
//  PhotoCollectionViewCell.swift
//  eKey
//
//  Created by Victoria Petrenko on 2/12/20.
//  Copyright © 2020 Test App. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionViewCell : UICollectionViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: - Properties
    static let identifier = "PhotoCollectionViewCell"
    
    //MARK: - Life-Cycle
    override func awakeFromNib() {
       super.awakeFromNib()
        
    }
    
    func configureCell(photoItem: PhotoItem) {
        //Setup imageView
        imageView.image = photoItem.image != nil ? photoItem.image : #imageLiteral(resourceName: "imagePlaceholder")
        //Setup title
        titleLabel.text = photoItem.photoType.rawValue
    }
}
