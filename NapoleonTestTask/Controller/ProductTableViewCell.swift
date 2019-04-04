//
//  ProductTableViewCell.swift
//  NapoleonTestTask
//
//  Created by Артем Жорницкий on 26/03/2019.
//  Copyright © 2019 Артем Жорницкий. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    #warning("цвет лучше вынести в extension UIColor в отдельный файл")
    let newPriceColor = #colorLiteral(red: 1, green: 0.4937272626, blue: 0.5617902092, alpha: 1)
    
    #warning("аутлеты через didSet настраивать можно, но как мне кажется, лучше такую настройку по максимуму вынести в .storyboard/.xib чтобы код был более читаемый ")
    @IBOutlet weak var ProductNameLabel: UILabel!
    
    @IBOutlet weak var productImage: UIImageView! {
        didSet {
            productImage.layer.masksToBounds = false
            productImage.layer.cornerRadius = 5
            productImage.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var bucketImage: UIImageView! {
        didSet {
            bucketImage.image = UIImage(named: "newBucketList")
        }
    }
    
    @IBOutlet weak var oldPrice: UILabel! {
        didSet {
            oldPrice.textColor = UIColor.lightGray
        }
    }
    
    @IBOutlet weak var newPriceLabel: UILabel! {
        didSet {
            newPriceLabel.textColor = newPriceColor
        }
    }
    
    @IBOutlet weak var priceLabel: UILabel! {
        didSet {
            priceLabel.layer.cornerRadius = priceLabel.frame.size.height / 2
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel!{
        didSet {
            descriptionLabel.textColor = UIColor.lightGray
        }
    }
    
    #warning("лучше удалять те методы, которые никак не используешь")
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    #warning("""
    по поводу этих методов настройки ячейки см. MainScreenViewController line 207
    
    мне лень проверять как у тебя работает) но не всегда нужно прятать лейблы, если текст nil, можешь просто передать в текст нил и лейбла не будет видно (если у лейбла конечно нет бекграунда)
    """)
    func setupNameLabel(name: String?) {
        if name != nil {
            self.ProductNameLabel.text = name
        }
        else {
            self.ProductNameLabel.isHidden = true
        }
    }
    
    func setupDecription(description: String?) {
        if description != nil {
            self.descriptionLabel.text = description
        }
        else {
            self.descriptionLabel.isHidden = true
        }
    }
    
    #warning("""
    в метод передаешь оба параметра как optional, а проверяешь только discount
    понятно, что не логично, что discount пришла с сервера, а price нет, но лучше не force unwrap без 100% уверенности
    """)
    func setupDiscountLabels(discount: Float?, price: Int?) {
        if discount != nil {
            self.priceLabel.text = "-\(Int(discount!*100))%"
        
            setupCrossedLabel(with: String(price!))
            self.newPriceLabel.text = String(Int(Float(price!) - discount! * Float(price!))) + "₽"
        }
        else {
            self.priceLabel.isHidden = true
            self.oldPrice.isHidden = true
            self.newPriceLabel.isHidden = true
        }
    }
    
    #warning("""
    ты используешь одинаковую загрузку изображения в 2 ячейках, при этом полностью переписываешь код
    
    лучше вынести это в отдельный метод, или сделать extension ImageView для загрузки картинки с URL (см. библиотеку AlamofireImage)
    
    также ты не делаешь catch let error, чтобы запринтить конкретную ошибку (которая скорее всего будет не особо информативной)
    поэтому можно либо:
    
    а) заменить вербозный do-catch на
    
        if let data = try? Data(contentsOf: imageUrl) {
            DispatchQueue...
        } else {
            print("error loading image with URL: \\(imageUrl)")
        }
    
    таким образом логируя некорректный URL
    
    
    b) в catch блоке ловить ошибку (catch let error) и принтить ее + принтить URL, по которому не удалось загрузить
    """)
    func setupImage(with stringUrl: String) {
        #warning("тут надо сначала через guard проверить создается ли URL со строки и не делать force unwrap на 129")
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
    
    
    //making crossed label
    func setupCrossedLabel(with label: String) {
        let attributedString = NSMutableAttributedString(string: (label + "₽"))
        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
        oldPrice.attributedText = attributedString
    }
}
