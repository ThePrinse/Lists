//
//  AddListViewController.swift
//  Lists
//
//  Created by Shahar Melamed on 4/26/19.
//  Copyright © 2019 Shahar Melamed. All rights reserved.
//

import UIKit
import CoreData
import DLRadioButton

class AddListViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var addListBtnBack: UIView!
    @IBOutlet weak var addListBtn: UIButton!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    var addBtnDefColor: UIColor = .black
    let imagePicker = UIImagePickerController()
    var shouldSelect = true
    
    var selectedImage = UIImage(named: "placeholder")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBtnDefColor = addListBtnBack.backgroundColor ?? .black
        addListBtn.isEnabled = false
        addListBtnBack.backgroundColor = .lightGray
        
        nameInput.tag = 69
        
        imagePicker.delegate = self
        
        nameInput.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let sub = view.hitTest((touches.first?.location(in: view))!, with: nil)
        // check if it's not the txt flds
        if sub?.tag != 69 {
            // hide the keyboard
            nameInput.resignFirstResponder()
        }
    }
    
    @IBAction func openSelectImage(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
            selectedImage = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addList(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "List", in: context)
        let newList = NSManagedObject(entity: entity!, insertInto: context)
        
        newList.setValue(nameInput.text ?? "", forKey: "title")
        newList.setValue(selectedImage?.pngData(), forKey: "image")
        let id = UserDefaults.standard.integer(forKey: "count")
        newList.setValue(id, forKey: "id")
        UserDefaults.standard.set(id + 1, forKey: "count")
        
        do {
            try context.save()
            reloadList()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Failed saving")
        }
    }
    
    @IBAction func textChanged(_ sender: UITextField) {
        if (sender.text ?? "").count > 0 {
            addListBtn.isEnabled = true
            addListBtnBack.backgroundColor = addBtnDefColor
        } else {
            addListBtn.isEnabled = false
            addListBtnBack.backgroundColor = .lightGray
        }
    }
}
