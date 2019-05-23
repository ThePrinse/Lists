//
//  ListsTableViewController.swift
//  Lists
//
//  Created by Shahar Melamed on 4/26/19.
//  Copyright © 2019 Shahar Melamed. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

var listElements = [ListElement]()
var listElement = 0
var currentListView: ListsTableViewController? = nil

class ListsTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        currentListView = self
        
        listElements.removeAll()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                listElements.append(ListElement(id: data.value(forKey: "id") as! Int64, title: data.value(forKey: "title") as! String, image: data.value(forKey: "image") as! Data))
            }
        } catch {
            
            print("Failed")
        }
        
        listElements.sort { (p, n) -> Bool in
            return p.id < n.id
        }
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(goHowTo), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: infoButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func goHowTo() {
        performSegue(withIdentifier: "goHowTo", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let editSwipe = SwipeAction(style: .default, title: NSLocalizedString("edit", comment: "edit"), handler: { (_, index) in
            listElement = indexPath.row
            self.performSegue(withIdentifier: "edit", sender: self)
        })
        editSwipe.backgroundColor = .init(red: 0, green: 125, blue: 255)
        
        let actions = [SwipeAction(style: .destructive,
                                   title: NSLocalizedString("rm", comment: "rm"),
                                   handler: { (_, index) in
                                        listElements[index.row].delete()
        }), editSwipe]
        let test = NSLocalizedString("test", comment: "test") == "test"
        if orientation == .left {
            return test ? actions : []
        } else {
            return test ? [] : actions
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listElements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listElement", for: indexPath) as! ListViewTableCell

        cell.img.image = listElements[indexPath.row].image
        cell.title.text = listElements[indexPath.row].title
        cell.title.textColor = .black
        cell.delegate = self

        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listElement = indexPath.row
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        listElement = indexPath.row
    }
}

class ListViewTableCell: SwipeTableViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!
}

struct ListElement {
    
    var id: Int64
    var title: String
    var image: UIImage?
    
    init(id: Int64, title: String, image: Data) {
        self.id = id
        self.title = title
        self.image = UIImage(data: image)
    }
    
    func delete() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "id == \(id)")
        if let result = try? context.fetch(request) {
            for object in result as! [NSManagedObject] {
                context.delete(object)
                reloadList()
            }
        }
    }
}

extension UIView {
    @IBInspectable var ignoresInvertColors: Bool {
        get {
            if #available(iOS 11.0, *) {
                return accessibilityIgnoresInvertColors
            }
            return false
        }
        set {
            if #available(iOS 11.0, *) {
                accessibilityIgnoresInvertColors = newValue
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}

func reloadList() {
    listElements.removeAll()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
    request.returnsObjectsAsFaults = false
    do {
        let result = try context.fetch(request)
        for data in result as! [NSManagedObject] {
            listElements.append(ListElement(id: data.value(forKey: "id") as! Int64, title: data.value(forKey: "title") as! String, image: data.value(forKey: "image") as! Data))
        }
    } catch {
        
        print("Failed")
    }
    
    listElements.sort { (p, n) -> Bool in
        return p.id < n.id
    }
    
    currentListView?.tableView.reloadData()
}
