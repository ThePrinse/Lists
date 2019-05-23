//
//  EditListViewController.swift
//  Lists
//
//  Created by Shahar Melamed on 11/05/2019.
//  Copyright © 2019 Shahar Melamed. All rights reserved.
//

import UIKit
import CoreData

class EditListViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var txtFld: UITextField!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    var saveBtnDefColor: UIColor = .black
    let imagePicker = UIImagePickerController()
    var shouldSelect = true
    
    var selectedImage = listElements[listElement].image
    
    var id = listElements[listElement].id
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationItem.backBarButtonItem?.title = listElements[listElement].title
        
        txtFld.text = listElements[listElement].title
        img.image = listElements[listElement].image
        
        txtFld.delegate = self
        txtFld.tag = 69
        
        saveBtnDefColor = saveBtn.backgroundColor ?? .black
        
        imagePicker.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtFld.resignFirstResponder()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let sub = view.hitTest((touches.first?.location(in: view))!, with: nil)
        // check if it's not the txt flds
        if sub?.tag != 69 {
            // hide the keyboard
            txtFld.resignFirstResponder()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            img.image = pickedImage
            selectedImage = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openSelectImage(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func textChanged(_ sender: UITextField) {
        if (sender.text ?? "").count > 0 {
            saveBtn.isEnabled = true
            saveBtn.backgroundColor = saveBtnDefColor
        } else {
            saveBtn.isEnabled = false
            saveBtn.backgroundColor = .lightGray
        }
    }
    
    @IBAction func save(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "id = \(id)")
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                data.setValue(selectedImage?.pngData(), forKey: "image")
                data.setValue(txtFld.text, forKey: "title")
            }
            
            try context.save()
        } catch {
            
            print("Failed")
        }
        
        navigationItem.backBarButtonItem?.title = txtFld.text
        
        currentList?.collectionView.reloadData()
        
        reloadList()
    }
}
