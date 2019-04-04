//
//  ViewController.swift
//  NapoleonTestTask
//
//  Created by Артем Жорницкий on 25/03/2019.
//  Copyright © 2019 Артем Жорницкий. All rights reserved.
//

import UIKit

#warning("реализацию протоколов таблицы сделал в экстеншенах как красавец, а UISearchBarDelegate тут объявил почему то))")
class ViewController: UIViewController, UISearchBarDelegate {
    
    #warning("это 100% моя вкусовщина, но у нас в компании как-то сложилось, что в классе сначала @IBOutlet, потом остальные свойства, будь к этому готов, когда будешь работать хех)")
    var offers = [Offer]()
    var banners = [Banner]()
    
    let baseUrl = "https://s3.eu-central-1.amazonaws.com/sl.files/"
    
    #warning("nested types либо наверх класса, либо вниз, либо в экстеншен. У тебя, по моему, теряется в коде")
    struct Sections {
        #warning("implicitly unwrapped здесь не нужны, тем более что это struct, который автоматом генерит себе init")
        var sectionName: String!
        var sectionObjects : [Offer]!
    }
    
    var sectionArray = [Sections]()
    
    #warning("цвета лучше выносить в отдельный файл как extension для UIColor")
    let colorForSegment = #colorLiteral(red: 0.7203173905, green: 0.8411524608, blue: 1, alpha: 1)
    
    #warning("""
    ты разбил прил по MVC (это оч круто), но не вынес методы загрузки в отдельный менеджер (который поидее относится к model)
    
    лучше было бы:
    
        - сделать класс MainScreenDataProvider
        - в нем описать эти же методы загрузки
        - в коллбеке этих методов отдавать данные, если их удалось загрузить
    """)
    //downloading banners data
    func getBannersData(){
        guard let jsonUrl = URL(string: baseUrl + "banners.json") else { return }
        URLSession.shared.dataTask(with: jsonUrl) { (data, response, error) in
            #warning("""
            по поводу вербозности do catch и обработки ошибки тут см. ProductTableViewCell line 109
            
            если юзаешь do-catch, то тут 100% надо делать catch let error { print(error) }
            потому что при декодинге JSON error очень информативна: в ней пишется что конкретно пошло не так (какое поле не удалось распарсить)
            """)
            do {
                if let error = error { fatalError("\(error)") }
                #warning("force unwrap data не надо делать, надо проверку ебануть сначала")
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
        #warning("тоже самое про этот метод, что и про предыдущий можно сказать")
        guard let jsonUrl = URL(string: baseUrl + "offers.json")
        //offerJsonUrl = Bundle.main.url(forResource: "offers", withExtension: ".json")
            else { return }
        URLSession.shared.dataTask(with: jsonUrl) { (data, response, error) in
            do {
                if let error = error { fatalError("\(error)") }
                let downloadOffers = try JSONDecoder().decode([Offer].self, from: data!)
                DispatchQueue.main.async {
                    self.offers = downloadOffers
                    #warning("не знал про Dictinary(grouping), прикольная тема, буду юзать теперь)")
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

    #warning("""
    см ProductTableViewCell line 15 по поводу аутлетов
    
    лучше либо привязать dataSource и delegate в сториборде, либо в контроллере (а не часть тут часть там)
    """)
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            //collectionView.delegate = self
            collectionView.register(UINib(nibName: "BannerCellCollectionViewCell", bundle : nil), forCellWithReuseIdentifier: "BannerCellCollectionViewIdentifier")
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            #warning("в сториборде уже протянуты делегат и датасорс, можно не писать, либо см. line 78")
            // tableView.delegate = self
            tableView.dataSource = self
            
            #warning("принято выносить nibname, reuseIdentifier куда-нибудь в константы, допустим как static let в класс ячейки, чтобы проще было искать и дебажить")
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
        #warning("никогда не видел такую запись селектора, не знаю, ошибка ли это, но обычно делаю keyboardWillShow(notification:)")
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    //func for handling keyboard show
    @objc func keyboardWillShow(notification: Notification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
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
    
    #warning("""
    а если будет 4,5,6 кнопок, для каждой будешь писать tapped/untapped?)
    
    вообще, я думаю, что в задании подразумевалось, что кнопки сверху - это коллекция с ячейками, потому что фильтровать
    можно по разным параметрам, в зависимости от того, какие товары тебе пришли
    + в коллекции можно сделать настройку ширины ячейки в зависимости от ее текста ( см. скрин задания, средняя кнопка шире остальных, потому что текст длиннее )
    
    потом можешь попробовать переделать эти кнопки на коллекцию, если будет желание
    """)
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
    
        #warning("""
        не могу сказать, что ты сделал тут неправильно, потому что по-хорошему ячейка не должна знать ничего о модели
        (для этого часто делают отдельно viewModel с полями, которые нужны только ячейке, но в твоем случае нужны все поля и создавать вторую такую же модель нет смысла)
        
        но при этом соблюдение правил пораждает проблему: у тебя на каждый лейбл по методу настройки, читаемость падает
        
        можно немножко нарушить правила и передать ячейке модель в одном методе (setupCell(with model: Offer))
        и в нем сконфигурировать, при этом условившись, что мы не будем из ячейки изменять модель
        
        так же можно:
            сделать протокол, в котором описать те же поля, что и у модели
            сделать поля { get } (get only)
            реализовать протокол в модели
            в ячейку передавать модель по протоколу
        
            таким образом из скоупа ячейки нельзя будет изменить модель
            (но можно не париться и не делать этого)
        """)
        
        cell.setupNameLabel(name: sectionArray[indexPath.section].sectionObjects[indexPath.row].name)
        
        cell.setupDiscountLabels(discount: sectionArray[indexPath.section].sectionObjects[indexPath.row].discount, price: sectionArray[indexPath.section].sectionObjects[indexPath.row].price)
        
        cell.setupDecription(description: sectionArray[indexPath.section].sectionObjects[indexPath.row].desc)
        
        #warning("в модели image optional, метод ожидает optional, а тут ты делаешь force unwrap, хотя картинка может не прийти")
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
        #warning("неиспользуемый метод лучше удалить, либо реализовать удаление")
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Удалить"
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionArray[section].sectionName
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        #warning("вроде футер по дефолту имееть 0 высоту, не?")
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
        
        #warning("cм line 207")
        cell.setupProductName(with: banners[indexPath.row].title)
        
        cell.setupImage(with: banners[indexPath.row].image!)
        
        cell.setupProductDescription(with: banners[indexPath.row].desc)
        
        cell.setupBlurView()
        
        cell.checkForNameAndDescription()
        
        return cell
    }
}

extension ViewController : UICollectionViewDelegate {
    #warning("этот метод никогда не вызовется, потому что у collection view не протянут делегат")
    func collectionView(_ collectionView: UICollectionView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 177.0
    }
}




