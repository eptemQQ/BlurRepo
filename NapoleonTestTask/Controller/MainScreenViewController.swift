//
//  ViewController.swift
//  NapoleonTestTask
//
//  Created by Артем Жорницкий on 25/03/2019.
//  Copyright © 2019 Артем Жорницкий. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UISearchBarDelegate {
    var offers = [Offer]()
    var banners = [Banner]()
    
    let baseUrl = "https://s3.eu-central-1.amazonaws.com/sl.files/"
    
    struct Sections {
        var sectionName: String!
        var sectionObjects : [Offer]!
    }
    
    var sectionArray = [Sections]()
    
    let colorForSegment = #colorLiteral(red: 0.7203173905, green: 0.8411524608, blue: 1, alpha: 1)
    //downloading banners data
    func getBannersData(){
        guard let jsonUrl = URL(string: baseUrl + "banners.json")
            //bannerJsonUrl = Bundle.main.url(forResource: "banners", withExtension: ".json")
            else { return }
        URLSession.shared.dataTask(with: jsonUrl) { (data, response, error) in
            do {
                if let error = error { fatalError("\(error)") }
                let downloadBanners = try JSONDecoder().decode([Banner].self, from: data!)
                DispatchQueue.main.async {
                    print(downloadBanners)
                    self.banners = downloadBanners
                    self.collectionView.reloadData()
                }
            }
            catch {
                print("error")
            }
        }.resume()
    }
    
    
    func getOffersData(){
        guard let jsonUrl = URL(string: baseUrl + "offers.json")
        //offerJsonUrl = Bundle.main.url(forResource: "offers", withExtension: ".json")
            else { return }
        URLSession.shared.dataTask(with: jsonUrl) { (data, response, error) in
            do {
                if let error = error { fatalError("\(error)") }
                let downloadOffers = try JSONDecoder().decode([Offer].self, from: data!)
                DispatchQueue.main.async {
                    self.offers = downloadOffers
                    let groupedDict = Dictionary(grouping: self.offers) { $0.groupName }
                    // converting dictionary to array of objects to make our work with filtered sections easier
                    for (key, value) in groupedDict {
                        self.sectionArray.append(Sections(sectionName: key, sectionObjects: value))
                    }
                    for offer in self.offers{
                        print(offer.groupName)
                    }
                    self.tableView.reloadData()
                }
            }
            catch {
                print("error")
            }
        }.resume()
    }

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            //collectionView.delegate = self
            collectionView.register(UINib(nibName: "BannerCellCollectionViewCell", bundle : nil), forCellWithReuseIdentifier: "BannerCellCollectionViewIdentifier")
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            // tableView.delegate = self
            tableView.dataSource = self
            
            tableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCellIdentifier")
        }
    }
    
    @IBOutlet weak var sbSearchBar: UISearchBar!
    
    @IBOutlet weak var topTenButton: UIButton! {
        didSet {
            topTenButton.layer.cornerRadius = topTenButton.frame.size.height / 2
            topTenButton.layer.borderWidth = 1
            topTenButton.layer.borderColor = UIColor.white.cgColor
        }
    }
    @IBOutlet weak var itemsButton: UIButton! {
        didSet {
            itemsButton.layer.cornerRadius = itemsButton.frame.size.height / 2
            itemsButton.layer.borderWidth = 1
            itemsButton.layer.borderColor = UIColor.white.cgColor

        }
    }
    @IBOutlet weak var shopsButton: UIButton! {
        didSet {
            shopsButton.layer.cornerRadius = shopsButton.frame.size.height / 2
            shopsButton.layer.borderWidth = 1
            shopsButton.layer.borderColor = UIColor.white.cgColor

        }
    
    }
    
    override func viewDidLoad() {
        getOffersData()
        getBannersData()
        setupSearchBarStyle()
        //making an observer to work with keyboard appearance
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    //func for handling keyboard show
    @objc func keyboardWillShow(notification: Notification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let point = CGPoint(x: 0, y: keyboardSize.height)
        var bottomStuff: CGFloat = 0
        if #available (iOS 11.0, *) {
            bottomStuff += view.safeAreaInsets.bottom
        }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - bottomStuff, right: 0)
        tableView.setContentOffset(point, animated: true)
        }
    
    //func for handling keyboard hiding
    @objc func keyboardWillHide(notification: Notification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //Managing button's tapps
    @IBAction func firstSegmentTapped(_ sender: Any) {
        filterIsTapped(button: topTenButton)
        filterIsUnTapped(button: shopsButton)
        filterIsUnTapped(button: itemsButton)
        
    }
    
    @IBAction func secondSegmentTapped(_ sender: Any) {
        filterIsTapped(button: shopsButton)
        filterIsUnTapped(button: itemsButton)
        filterIsUnTapped(button: topTenButton)
    }
    
    @IBAction func thirdSegmentTapped(_ sender: Any) {
        filterIsTapped(button: itemsButton)
        filterIsUnTapped(button: shopsButton)
        filterIsUnTapped(button: topTenButton)
    }
    //Setting up filter if it was tapped
    func filterIsTapped(button: UIButton) {
        button.layer.backgroundColor = colorForSegment.cgColor
        button.layer.borderColor = UIColor.blue.cgColor
    }
    //Setting up filter if it was untapped
    func filterIsUnTapped(button: UIButton) {
        button.layer.backgroundColor = UIColor.white.cgColor
        button.layer.borderColor = UIColor.white.cgColor
    }
    //Setting up search bar
    func setupSearchBarStyle() {
        sbSearchBar.delegate = self
        sbSearchBar.barTintColor = UIColor.white
        if let textfield = sbSearchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.lightGray
        }
        sbSearchBar.placeholder = "Поиск"
        sbSearchBar.backgroundImage = UIImage()
    }
    //keyboard dismissing by tapping search button
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // hides the keyboard.
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
        //return dicton.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return dicton[Array(dicton.keys)[section]]!.count
        return sectionArray[section].sectionObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCellIdentifier", for: indexPath) as! ProductTableViewCell
    
        cell.setupNameLabel(name: sectionArray[indexPath.section].sectionObjects[indexPath.row].name)
        
        cell.setupDiscountLabels(discount: sectionArray[indexPath.section].sectionObjects[indexPath.row].discount, price: sectionArray[indexPath.section].sectionObjects[indexPath.row].price)
        
        cell.setupDecription(description: sectionArray[indexPath.section].sectionObjects[indexPath.row].desc)
        
        cell.setupImage(with: sectionArray[indexPath.section].sectionObjects[indexPath.row].image!)

        return cell
    }
    //Making tableview looking good
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Avenir-Black", size: 17)!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Удалить"
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionArray[section].sectionName
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 109.5
    }
}


extension ViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banners.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCellCollectionViewIdentifier", for: indexPath) as! BannerCellCollectionViewCell
        cell.setupProductName(with: banners[indexPath.row].title)
        
        cell.setupImage(with: banners[indexPath.row].image!)
        
        cell.setupProductDescription(with: banners[indexPath.row].desc)
        
        cell.setupBlurView()
        
        cell.checkForNameAndDescription()
        
        return cell
    }
}

extension ViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 177.0
    }
}




