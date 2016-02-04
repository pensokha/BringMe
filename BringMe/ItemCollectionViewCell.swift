//
//  ItemCollectionViewCell.swift
//  BringMe
//
//  Created by Chuck on 2/3/16.
//  Copyright © 2016 kaichu. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    
    var item: Item?{
        didSet{
            if let newItem = item{
                self.itemImageView.image = UIImage(named: newItem.image!) ?? UIImage(named: "large")
                self.itemName.text = newItem.name
            }
        }
    }
}
