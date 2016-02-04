//
//  AddItemViewController.swift
//  BringMe
//
//  Created by Chuck on 2/3/16.
//  Copyright © 2016 kaichu. All rights reserved.
//

import UIKit
import TextFieldEffects

class AddItemViewController: UIViewController {
    
    let dataService = (UIApplication.sharedApplication().delegate as! AppDelegate).dataService
    //MARK: Data model
    
    // Grocery use currently is on
    var grocery: Grocery!{
        didSet{
            reloadItems()
        }
    }
    // Items current grocery
    private var items = [AnyObject]()
    
    // Editing item
    var editItem: Item?{
        didSet{
            configureItemForm()
            configureButton()
        }
    }
    
    //MARK: IB components
    @IBOutlet weak var itemsCollectionView: UICollectionView!{
        didSet{
            itemsCollectionView.delegate = self
            itemsCollectionView.dataSource = self
        }
    }
    @IBOutlet weak var nameTextField: HoshiTextField!{
        didSet{
            nameTextField.delegate = self
        }
    }
    @IBOutlet weak var AmountTextField: HoshiTextField!{
        didSet{
            AmountTextField.delegate = self
        }
    }
    @IBOutlet weak var priceTextField: HoshiTextField!{
        didSet{
            priceTextField.delegate = self
        }
    }
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var finishStatusSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    //MARK: Override method
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton()
        reloadItems()
        configureItemForm()
        
        self.view.backgroundColor = UIColor.flatPlumColorDark()
        self.itemsCollectionView.backgroundColor = UIColor.flatPlumColor()
        self.hiddenView.backgroundColor = UIColor.flatPlumColorDark()
        
    }
    
    @IBOutlet weak var hiddenView: UIView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private var nameTextFieldNotification: NSObjectProtocol?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let defaultCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        nameTextFieldNotification = defaultCenter.addObserverForName(UITextFieldTextDidChangeNotification, object: self.nameTextField, queue: mainQueue) { notification in
            self.configureButton()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        if let ntfn = nameTextFieldNotification{
            NSNotificationCenter.defaultCenter().removeObserver(ntfn)
        }
    }
    
    //MARK: Target-Actions
    // Save button for editing item
    @IBAction func saveButtonAction(sender: AnyObject) {
        if let editingItem = self.editItem{
            editingItem.name = self.nameTextField.text
            editingItem.amount = Int(self.AmountTextField.text!)
            editingItem.price = Double(self.priceTextField.text!)
            editingItem.finished = self.finishStatusSwitch.on
            editingItem.image = editingItem.name
            dataService.saveContext()
            self.editItem = nil
        }
    }
    
    //Delete edit item
    @IBAction func deleteButtonAction(sender: AnyObject) {
        print("delete")
        if let editingItem = self.editItem{
            dataService.removeItem(editingItem)
            self.editItem = nil
            reloadItems()
        }
    }
    
    //Add a new item button
    @IBAction func addItemToGrocery(sender: AnyObject) {
        if self.editItem != nil{
            self.editItem = nil
        }
        else if let toGrocery = grocery{
            let name = self.nameTextField.text
            let amount = Int(self.AmountTextField.text!)
            let price = Double(self.priceTextField.text!)
            let finished = self.finishStatusSwitch.on
            let image = name
            dataService.addItemToGrocery(toGrocery, name: name!, amount: amount!, price: price!, finished: finished, image: image!)
            reloadItems()
        }
    }
    
    //Back button
    @IBAction func backToGrocery(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private var switchLastValue: Int = 0
    @IBAction func switchControlAction(sender: UIStepper) {
        if let amount = Int(self.AmountTextField.text ?? "0") {
            if switchLastValue != amount{
                let switchIntValue = Int(sender.value)
                let currentValue = amount + (switchIntValue - switchLastValue)
                sender.value = Double(currentValue)
            }
        }
        self.AmountTextField.text = Int(sender.value).description
        switchLastValue = Int(sender.value)
    }
    
    //MARK: Helper functions
    // When grocery is given, items is load from it
    func reloadItems(){
        guard grocery != nil else { return}
        if let existItems = grocery.items{
            let des = NSSortDescriptor(key: "name", ascending: true)
            items = existItems.sortedArrayUsingDescriptors([des])
            self.itemsCollectionView?.reloadData()
        }
    }
    
    // If item is editing, save and delete button is shown
    func configureButton(){
        self.addButton.enabled = ((self.nameTextField.text ?? "") != "")
        self.saveButton.hidden = self.editItem == nil
        self.deleteButton.hidden = self.editItem == nil
    }
    
    // If there is a editing item, fill textfield based on it. Or other, give nil to all field
    func configureItemForm(){
        if let selectItem = editItem{
            self.nameTextField?.text = selectItem.name
            self.AmountTextField?.text = "\(selectItem.amount ?? 0)"
            self.priceTextField?.text = "\(selectItem.price ?? 0.0)"
            self.finishStatusSwitch?.on = (selectItem.finished != 0)
            self.itemImage.image = UIImage(named: selectItem.image!) ?? UIImage(named: "large")
        }else{
            self.nameTextField?.text = nil
            self.AmountTextField?.text = "0"
            self.priceTextField?.text = "0.0"
            self.finishStatusSwitch?.on = false
            self.itemImage.image = UIImage(named: "large")
        }
    }

}
extension AddItemViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
extension AddItemViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemCell", forIndexPath: indexPath) as! ItemCollectionViewCell
        let cellItem = self.items[indexPath.row] as! Item
        cell.item = cellItem
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ItemCollectionViewCell{
            self.editItem = cell.item
        }
    }
    
}
