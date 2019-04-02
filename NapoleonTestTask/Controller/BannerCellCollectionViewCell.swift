//
//  BannerCellCollectionViewCell.swift
//  NapoleonTestTask
//
//  Created by Артем Жорницкий on 31/03/2019.
//  Copyright © 2019 Артем Жорницкий. All rights reserved.
//

import UIKit

class BannerCellCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var productImage: UIImageView!{
        didSet {
        productImage.layer.masksToBounds = false
        productImage.layer.cornerRadius = 5
        productImage.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var descView: UIView! {
        didSet {
            descView.clipsToBounds = true
            descView.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var productName: UILabel!
    
    @IBOutlet weak var productDesc: UILabel!
    
    func setupImage(with stringUrl: String) {
        let imageUrl = URL(string: stringUrl)
        DispatchQueue.global().async {
            do{
                let data = try Data(contentsOf: imageUrl!)
                DispatchQueue.main.async {
                    self.productImage.image = UIImage(data: data)
                }
            }
            catch {
                print("something went wrong")
            }
        }
    }
    
    func setupProductName(with name: String?) {
        if name != nil {
            self.productName.text = name
        }
        else {
            self.productName.isHidden = true
        }
    }
    
    func setupProductDescription(with description: String?) {
        if description != nil {
            self.productDesc.text = description
        }
        else {
           self.productDesc.isHidden = true
        }
    }
    func checkForNameAndDescription(){
        if (self.productName.isHidden && self.productDesc.isHidden) {
            self.descView.isHidden = true
        }
    }
    func setupBlurView() {
        let blurEffect = UIBlurEffect(style : .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = descView.bounds
        blurView.autoresizingMask = [ .flexibleWidth, .flexibleHeight]
        descView.addSubview(blurView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
