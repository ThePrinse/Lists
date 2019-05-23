//
//  ListCollectionViewController.swift
//  Lists
//
//  Created by Shahar Melamed on 4/27/19.
//  Copyright © 2019 Shahar Melamed. All rights reserved.
//

import UIKit
import DLRadioButton
import CoreData

var rows = [CheckRow]()
var currentList: ListCollectionViewController? = nil
var currentRow: Int64 = 0

class ListCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    fileprivate var cellId = "cell"
    fileprivate var header = "header"
    var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentList = self

        // Register cell classes
        self.collectionView!.register(ListRow.self, forCellWithReuseIdentifier: cellId)
        
        self.collectionView!.register(ListHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: header)
        
        view.tintColor = .init(red: 1, green: 147, blue: 78)
        
        rows.removeAll()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Row")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "parent = \(listElements[listElement].id)")
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                rows.append(CheckRow(id: data.value(forKey: "id") as! Int64, isCheck: data.value(forKey: "state") as! Bool, parent: data.value(forKey: "parent") as! Int64, text: data.value(forKey: "text") as! String))
            }
        } catch {
            
            print("Failed")
        }
        
        rows.sort { (p, n) -> Bool in
            return p.id < n.id
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        imageView.removeBlurEffect()
        if scrollView.contentOffset.y < -scrollView.adjustedContentInset.top - 2 {
            let scale = -scrollView.adjustedContentInset.top - scrollView.contentOffset.y
            imageView.frame = CGRect(x: -scale / 2, y: -scale, width: view.frame.width + scale, height: 250 + scale)
            imageView.blurImage()
            imageView.setBlur(to: ((2 * sigmoid(x: scale/60))-1)*0.75)
        }
        
        if scrollView.contentOffset.y > 137 - (-88 + scrollView.adjustedContentInset.top) {
            navigationItem.title = listElements[listElement].title
        } else {
            navigationItem.title = ""
        }
    }
    
    func sigmoid(x: CGFloat) -> CGFloat {
        return 1 / (1 + CGFloat(exp(Double(-x))))
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let h = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: header, for: indexPath)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.width, height: 250))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = listElements[listElement].image
        imageView.ignoresInvertColors = true
        imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250))
        imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: view.width))
        imageView.tag = 5
        
        let label = UILabel(frame: CGRect(x: 10, y: 200, width: view.width-20, height: 46))
        label.text = listElements[listElement].title
        label.font = UIFont(name: "Helvetica-Bold", size: 38)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        let strokeTextAttributes: [NSAttributedString.Key : Any] = [
            .strokeColor : UIColor.black,
            .foregroundColor : UIColor.white,
            .strokeWidth : -2.0,
        ]
        label.attributedText = NSAttributedString(string: label.text ?? "", attributes: strokeTextAttributes)
        
        let const = [NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal,                  toItem: h, attribute: .bottom, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: h, attribute: .top, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: h, attribute: .leading, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: h, attribute: .trailing, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: h, attribute: .bottomMargin, multiplier: 1, constant: 15),
                    NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: h, attribute: .leadingMargin, multiplier: 1, constant: 15)]
        
        h.addSubview(imageView)
        h.addSubview(label)
        h.addConstraints(const)
        
        return h
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: 250)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 10, height: 60)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListRow
        
        cell.tintColor = view.tintColor
        cell.start(checkRow: rows[indexPath.row])
        
        return cell
    }
    
    @IBAction func addRow(_ sender: Any) {
        for (n, _) in rows.enumerated() {
            let row = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: IndexPath(row: n, section: 0)) as! ListRow
            
            if row.fld?.isEditing ?? false {
                row.fld?.resignFirstResponder()
                row.textFieldDidEndEditing(UITextField())
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: "Row", in: context)
            let newRow = NSManagedObject(entity: entity!, insertInto: context)
            
            let parId = listElements[listElement].id
            let id = UserDefaults.standard.integer(forKey: "rows")
            
            newRow.setValue("New row", forKey: "text")
            newRow.setValue(false, forKey: "state")
            newRow.setValue(parId, forKey: "parent")
            print(id)
            newRow.setValue(id, forKey: "id")
            UserDefaults.standard.set(id + 1, forKey: "rows")
            
            do {
                try context.save()
                reloadRows()
            }
            catch {
                print("Failed")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let sub = view.hitTest((touches.first?.location(in: view))!, with: nil)
        // check if it's not the txt flds
        if sub?.tag != 69 {
            // hide the keyboard
            if rows.count > currentRow {
                let row = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: IndexPath(row: Int(currentRow), section: 0)) as! ListRow
                
                row.textFieldDidEndEditing(UITextField())
            }
        }
    }
}

struct CheckRow {
    var id: Int64
    var isCheck: Bool
    var parent: Int64
    var text: String
}

class ListHeader: UICollectionReusableView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var image: UIImageView!
    
}

class ListRow: UICollectionViewCell, UITextFieldDelegate {
    
    var radioBtn: DLRadioButton? = nil
    var lbl: UILabel? = nil
    var fld: UITextField? = nil
    private var selectState = true
    var row: CheckRow? = nil
    
    func start(checkRow row: CheckRow) {
        radioBtn?.removeFromSuperview()
        lbl?.removeFromSuperview()
        fld?.removeFromSuperview()
        
        radioBtn = DLRadioButton(type: .custom)
        radioBtn?.frame = CGRect(x: NSLocalizedString("test", comment: "test") == "test" ? 15 : width - 55, y: height/2-20, width: 40, height: 40)
        radioBtn?.iconSize = 37
        radioBtn?.iconStrokeWidth = 2
        radioBtn?.indicatorSize = 30
        radioBtn?.iconColor = tintColor
        radioBtn?.indicatorColor = tintColor
        radioBtn?.addTarget(self, action: #selector(radioTap(_:)), for: .touchUpInside)
        radioBtn?.isSelected = row.isCheck
        
        selectState = !row.isCheck
        
        self.row = row
        
        let textFrame = CGRect(x: NSLocalizedString("test", comment: "test") == "test" ? 60 : 15, y: 15, width: width-75, height: 30)
        lbl = UILabel(frame: textFrame)
        lbl?.text = row.text
        lbl?.font = UIFont(name: "Helvetica-Bold", size: 30)
        lbl?.adjustsFontSizeToFitWidth = true
        lbl?.numberOfLines = 0
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(lblTap))
        gr.numberOfTapsRequired = 1
        lbl?.addGestureRecognizer(gr)
        lbl?.isUserInteractionEnabled = true
        
        fld = UITextField(frame: textFrame)
        fld?.font = UIFont(name: "Helvetica-Bold", size: 25)
        fld?.borderStyle = .none
        fld?.isHidden = true
        fld?.returnKeyType = .done
        fld?.delegate = self
        fld?.adjustsFontSizeToFitWidth = true
        fld?.tag = 69
        
        layer.addBorder(edge: .bottom, color: .lightGray, thickness: 0.5)
        
        addSubview(radioBtn!)
        addSubview(lbl!)
        addSubview(fld!)
    }
    
    func updateState() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Row")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "id == \(row?.id ?? 0)")
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                data.setValue(!selectState, forKey: "state")
            }
            try context.save()
        } catch {
            
            print("Failed")
        }
    }
    
    func updateText() {
        if (lbl?.text ?? "").count != 0 {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Row")
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "id == \(row?.id ?? 0)")
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    data.setValue(lbl?.text ?? "", forKey: "text")
                }
                try context.save()
            } catch {
                
                print("Failed")
            }
            reloadRows()
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Row")
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "id == \(row?.id ?? 0)")
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    context.delete(data)
                }
                print("delete")
            } catch {
                
                print("Failed")
            }
            reloadRows()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        lbl?.text = fld?.text
        fld?.isHidden = true
        lbl?.isHidden = false
        
        print("ok")
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        fld?.resignFirstResponder()
        lbl?.text = fld?.text
        fld?.isHidden = true
        lbl?.isHidden = false
        updateText()
        
        print("ok")
    }
    
    @objc func lblTap() {
        fld?.text = lbl?.text
        fld?.isHidden = false
        lbl?.isHidden = true
        fld?.becomeFirstResponder()
        
        currentRow = row?.id ?? 0
    }
    
    @objc func radioTap(_ sender: DLRadioButton) {
        radioBtn?.isSelected = selectState
        selectState.toggle()
        updateState()
    }
}

extension UIView {
    var height: CGFloat {
        return frame.height
    }
    
    var width: CGFloat {
        return frame.width
    }
}

extension UIImageView{
    func blurImage() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
    
    func removeBlurEffect() {
        let blurredEffectViews = self.subviews.filter{$0 is UIVisualEffectView}
        blurredEffectViews.forEach{ blurView in
            blurView.removeFromSuperview()
        }
    }
    
    func setBlur(to: CGFloat) {
        let blurredEffectViews = self.subviews.filter{$0 is UIVisualEffectView}
        blurredEffectViews.forEach{ blurView in
            blurView.alpha = to
        }
    }
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

func reloadRows() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        rows.removeAll()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Row")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "parent == \(listElements[listElement].id)")
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "text") as! String)
                rows.append(CheckRow(id: data.value(forKey: "id") as! Int64, isCheck: data.value(forKey: "state") as! Bool, parent: data.value(forKey: "parent") as! Int64, text: data.value(forKey: "text") as! String))
            }
        } catch {
            
            print("Failed")
        }
        
        rows.sort { (p, n) -> Bool in
            return p.id < n.id
        }
        
        currentList?.collectionView.reloadData()
    }
}
