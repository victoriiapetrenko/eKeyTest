//
//  PhotoPicker.swift
//  eKey
//
//  Created by Victoria Petrenko on 2/12/20.
//  Copyright © 2020 eKey. All rights reserved.
//

import Foundation
import UIKit

public protocol PhotoPickerDelegate: class {
    func didSelect(image: UIImage?)
}

open class PhotoPicker: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: PhotoPickerDelegate?

    public init(presentationController: UIViewController, delegate: PhotoPickerDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    public func showPhotoPicker(for type: UIImagePickerController.SourceType) {
        self.pickerController.sourceType = type
        self.presentationController?.present(self.pickerController, animated: true)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)

        self.delegate?.didSelect(image: image)
    }
}

extension PhotoPicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension PhotoPicker: UINavigationControllerDelegate {

}
