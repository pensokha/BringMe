//
//  SecondViewController.swift
//  BringMe
//
//  Created by Chuck on 1/31/16.
//  Copyright © 2016 kaichu. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    private lazy var presentationAnimator = GuillotineTransitionAnimation()
    private lazy var dataManager = (UIApplication.sharedApplication().delegate as! AppDelegate).dataService
    private var groceries: [Grocery] = []
    private var page = 1
    private var hasMore = false
    
    @IBAction func refreshControl(sender: UIRefreshControl) {
        sender.beginRefreshing()
        self.loadData()
    }
    //MARK: Data Load
    func loadData(){
        dataManager.queryGrocery{[unowned self] groceries, error in
            if error == nil{
                self.groceries = groceries
                if self.groceries.count != 0{
                    self.hasMore = true
                }
            }
        }
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func loadMoreData(){
        if self.hasMore{
            self.page++
        }else{
            return
        }
        
        dataManager.queryGrocery(page:self.page){[unowned self] groceries, error in
            if error == nil{
                if groceries.count==0{
                    self.hasMore = false
                    self.page--
                }else{
                    self.hasMore = true
                }
                print("gr count")
                print(groceries.count)
                print(self.page)
                if self.hasMore{
                    self.groceries += groceries
                }
            }
        }
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = UIColor.flatCoffeeColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.flatCoffeeColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.flatWhiteColor()]
        self.navigationController?.navigationBar.translucent = false
        self.tableView.backgroundColor = UIColor.flatCoffeeColorDark()
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        
        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        self.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showMenuTap(sender: UIButton) {
        let menuVC = storyboard!.instantiateViewControllerWithIdentifier("MenuViewController")
        menuVC.modalPresentationStyle = .Custom
        menuVC.transitioningDelegate = self
        if menuVC is GuillotineAnimationDelegate {
            presentationAnimator.animationDelegate = menuVC as? GuillotineAnimationDelegate
        }
        presentationAnimator.supportView = self.navigationController?.navigationBar
        presentationAnimator.presentButton = sender
        self.presentViewController(menuVC, animated: true, completion: nil)
    }

    @IBAction func returnFromEdit(segue: UIStoryboardSegue){
        if let source = segue.sourceViewController as? EditGroceryViewController{
            if let _ = source.grocery{
                self.dataManager.saveContext()
                self.loadData()
            }
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier ?? ""){
        case "EditGrocery":
            if let destinationController = segue.destinationViewController.contentViewController as? EditGroceryViewController{
                destinationController.grocery = dataManager.createGrocery()
            }
        case "ShowGrocery":
            if let destinationController = segue.destinationViewController.contentViewController as? EditGroceryViewController{
                if let selectRow = self.tableView.indexPathForSelectedRow?.row{
                    destinationController.grocery = self.groceries[selectRow]
                }
            }
            
        default:
            break;
        }
    }
}
extension MainViewController{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groceries.count + (self.hasMore ? 1 : 0)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == self.groceries.count{
            let cell = tableView.dequeueReusableCellWithIdentifier("LoadingItemCell") as! LoadingTableViewCell
            cell.backgroundColor = UIColor.flatCoffeeColorDark()
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("GroceryItemCell") as! GroceryTableViewCell
        
        
        let grocery = self.groceries[indexPath.row]
        configureCell(cell, grocery: grocery)
        
        return cell
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.groceries.count{
            self.loadMoreData()
        }
    }
    
    func configureCell(cell: GroceryTableViewCell, grocery:Grocery){
        cell.backgroundColor = UIColor.flatCoffeeColorDark()
        
        cell.nameLabel.text = grocery.gShopname
        cell.descriptionLabel.text = grocery.gDescription
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd a HH:mm"
        if let finished = grocery.gFinishDate{
            cell.createdOrFinishedLabel.text = formatter.stringFromDate(finished)
        }else{
            cell.createdOrFinishedLabel.text = formatter.stringFromDate(grocery.gCreateDate!)
        }
        
        cell.totalPriceLabel.text = "Price: \(grocery.gTotalPrice!)"
        cell.numberOfItemsLabel.text = "Count: \(grocery.gNumberOfTotalItems!)"
    }
    
}
extension MainViewController: DZNEmptyDataSetSource{
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "logo_twitter")
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.flatCoffeeColorDark()
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "Add your first grocery!"
        let attributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        return NSAttributedString(string: title, attributes: attributes)
    }
}
extension MainViewController: DZNEmptyDataSetDelegate{
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
}

extension MainViewController: UIViewControllerTransitioningDelegate{
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentationAnimator.mode = .Presentation
        return presentationAnimator
        
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentationAnimator.mode = .Dismissal
        return presentationAnimator
    }
    
    
    
    
}

