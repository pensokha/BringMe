//
//  EditGroceryViewController.swift
//  BringMe
//
//  Created by Chuck on 2/1/16.
//  Copyright © 2016 kaichu. All rights reserved.
//

import UIKit
import TextFieldEffects

class EditGroceryViewController: UIViewController, UITextFieldDelegate {
    private lazy var dataManager = (UIApplication.sharedApplication().delegate as! AppDelegate).dataService
    
    //MARK: Model
    var grocery: Grocery? {didSet{updateUI()}}
    
    
    //MARK: UI components
    @IBOutlet weak var numberOfTotalItems: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var createdDatedLabel: UILabel!
    @IBOutlet weak var finishedDateLabel: UILabel!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var nameTextField: HoshiTextField!{
        didSet{
            nameTextField.delegate = self
        }
    }
    @IBOutlet weak var descriptionTextField: HoshiTextField!{
        didSet{
            descriptionTextField.delegate = self
        }
    }
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    
    //MARK: UI Target Actions
    @IBAction func viewItemsButton(sender: AnyObject) {
    }
    
    
    @IBAction func cancelButton(sender: AnyObject) {
        if let _ = self.presentingViewController as? UINavigationController{
            if let gc = grocery {
                dataManager.removeGrocery(gc)
            }
            dismissViewControllerAnimated(true, completion: nil)
        }else{
            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    //MARK: View Controller Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if grocery?.gShopname == nil{
            self.infoStackView.hidden = true
        }
        self.navigationController?.navigationBar.barTintColor = UIColor.flatPlumColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.view.backgroundColor = UIColor.flatPlumColorDark()
        updateUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startObserver()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        cancelObserver()
    }
    
    //MARK: Text Field Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    //MARK: Helper functions
    func updateUI(){
        if let _ = grocery{
            self.numberOfTotalItems?.text = "\(grocery!.gNumberOfTotalItems)"
            self.totalPriceLabel?.text = "\(grocery!.gTotalPrice)"
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            self.createdDatedLabel?.text = grocery!.gFinishDate == nil ? "-" : "\(formatter.stringFromDate(grocery!.gFinishDate!))"
            self.finishedDateLabel?.text = "\(formatter.stringFromDate(grocery!.gCreateDate!))"
            self.nameTextField?.text = grocery?.gShopname
            self.descriptionTextField?.text = grocery?.gDescription
        }
        disableDoneButton()
    }
    
    func disableDoneButton(){
        self.doneButton?.enabled = (self.nameTextField?.text ?? "").isNotEmpty
    }
    var nameObserver: NSObjectProtocol?
    var descriptionObserver: NSObjectProtocol?
    func startObserver(){
        let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
        let operationQueue = NSOperationQueue.mainQueue()
        self.nameObserver = defaultNotificationCenter.addObserverForName(UITextFieldTextDidChangeNotification, object: nameTextField, queue: operationQueue) { notification in
            self.grocery?.gShopname = self.nameTextField.text
            self.disableDoneButton()
        }
        self.descriptionObserver = defaultNotificationCenter.addObserverForName(UITextFieldTextDidChangeNotification, object: descriptionTextField, queue: operationQueue, usingBlock: { notification in
            self.grocery?.gDescription = self.descriptionTextField.text
        })
    }
    
    func cancelObserver(){
        if let nos = self.nameObserver{
            NSNotificationCenter.defaultCenter().removeObserver(nos)
        }
        if let dos = self.descriptionObserver{
            NSNotificationCenter.defaultCenter().removeObserver(dos)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch(segue.identifier ?? ""){
        case "AddItemSegue":
            print("segue add item")
                if let destination = segue.destinationViewController.contentViewController as? AddItemViewController{
                    destination.grocery = self.grocery
                    
                    print(self.grocery?.gShopname)
                }
        default:
            break
        }
    }
    
}

extension UIViewController{
    var contentViewController: UIViewController?{
        if let nv = self as? UINavigationController{
            return nv.visibleViewController
        }else{
            return self
        }
    }
}
