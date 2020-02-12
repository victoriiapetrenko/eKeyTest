//
//  PhotosViewController.swift
//  eKey
//
//  Created by Victoria Petrenko on 2/12/20.
//  Copyright © 2020 Test App. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding
import Alamofire

// MARK: - PhotosViewController Constants
private enum PhotosVCConstants {
    static let horizontalCellCount: CGFloat = 2
    static let verticalCellCount: CGFloat = 2
    static let cellSpasing: CGFloat = 10
    static let maxCommentCharacters = 150
}


class PhotosViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var nextButton: UIButton!
    
    //MARK: - Properties
    lazy var viewModel: PhotosViewModel = { [unowned self] in
        return PhotosViewModel()
    }()
    
    var filledData: Bool = false {
        didSet {
            nextButton.alpha = filledData ? 1 : 0.6
            nextButton.isEnabled = filledData
        }
    }
    
    var enabledCommentView: Bool = false {
        didSet {
            if enabledCommentView {
                commentTextView.textColor = .black
            } else {
                commentTextView.textColor = .lightGray
            }
        }
    }
    
    var filledPhotos: Bool {
        var filledPhotosCount = 0
        for photo in viewModel.photos {
            if photo.image != nil {
                filledPhotosCount += 1
            }
        }
        return filledPhotosCount == viewModel.photos.count
    }
    
    var photoPicker: PhotoPicker!
    
    //MARK: - Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Register xib file
        collectionView.register(UINib(nibName: PhotoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        //Configure UI
        commentTextView.layer.borderColor = UIColor.lightGray.cgColor
        commentTextView.sizeToFit()
        commentTextView.flashScrollIndicators()
        
        //Add scroll for comment textView
        KeyboardAvoiding.avoidingView = self.view
        
        photoPicker = PhotoPicker(presentationController: self, delegate: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Dismiss keyboard when press return button
        view.endEditing(true)
    }
    
    //MARK: - Private functions
    private func checkFilledData() {
        filledData = enabledCommentView && filledPhotos
    }
    
    private func showChoosePhotoAlert(photoItem: PhotoItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        viewModel.selectedPhoto = photoItem
        
        // Add take photo from gallery
        let galleryAction = UIAlertAction(title: Constants.takePhotoFromGallery, style: .default) { (action) in
            print("didPress take photo from gallery")
            self.photoPicker.showPhotoPicker(for: .photoLibrary)
        }

        // Add take photo from camera
        let cameraAction = UIAlertAction(title: Constants.takePhotoFromCamera, style: .default) { (action) in
            
            print("didPress take photo from camera")
            #if targetEnvironment(simulator)
              print("simulator not support camera")
            #else
              self.photoPicker.showPhotoPicker(for: .camera)
            #endif
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("didPress cancel")
        }

        // Add the actions to your actionSheet
        actionSheet.addAction(galleryAction)
        actionSheet.addAction(cameraAction)
        
        if photoItem.image != nil {
            //Show delete photo action
            let deletePhotoAction = UIAlertAction(title: Constants.deletePhoto, style: .destructive) { (action) in
                print("didPress delete photo")
                self.viewModel.deletePhotoImage()
                //Check fill data or not
                self.checkFilledData()
                //Reload data
                self.collectionView.reloadData()
            }
            actionSheet.addAction(deletePhotoAction)
        }

        
        actionSheet.addAction(cancelAction)
        // Present the controller
        self.present(actionSheet, animated: true, completion: nil)
        self.view.layoutIfNeeded()
    }
    
    //MARK: - Actions
    @IBAction func onPressNextButton(_ sender: UIButton) {
        print("didPress next button")
        viewModel.postPhotos(comment: self.commentTextView.text)
    }
}

//MARK: - Delegates
//MARK: - UICollectionViewDelegate/UICollectionViewDataSource
extension PhotosViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let photoItem = viewModel.photos[indexPath.row]
        cell.configureCell(photoItem: photoItem)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoItem = viewModel.photos[indexPath.row]
        showChoosePhotoAlert(photoItem: photoItem)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension PhotosViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenSize = UIScreen.main.bounds.size
        return CGSize(width: (screenSize.width - 2*PhotosVCConstants.cellSpasing)/PhotosVCConstants.horizontalCellCount - 2*PhotosVCConstants.horizontalCellCount, height: collectionView.bounds.size.height/PhotosVCConstants.verticalCellCount)
    }
}

//MARK: - UITextViewDelegate
extension PhotosViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Constants.commentPlaceholder {
            textView.text = nil
        }
        enabledCommentView = !textView.text.isEmpty && textView.text != ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //Check filled comment or not
        checkFilledData()
        if textView.text.isEmpty || textView.text == "" {
            //Add placeholder
            commentTextView.text = Constants.commentPlaceholder
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        //Check inserted comment or not
        enabledCommentView = !newText.isEmpty && newText != ""
        //Check fill data or not
        checkFilledData()

        if text == "\n" {
            //Dismiss keyboard when press return button
            view.endEditing(true)
        }
        
        //Comment field has maximum 200 characters
        return newText.count < PhotosVCConstants.maxCommentCharacters
    }
}

//MARK: - PhotoPickerDelegate
extension PhotosViewController : PhotoPickerDelegate {
    func didSelect(image: UIImage?) {
        
        viewModel.addPhotoImage(image: image)
        
        //Check fill data or not
        checkFilledData()
        //Reload data
        self.collectionView.reloadData()
    }
}
