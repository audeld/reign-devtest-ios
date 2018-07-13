//
//  ViewController.swift
//  reign-devtest-ios
//
//  Created by Audel Dugarte on 7/11/18.
//  Copyright © 2018 Audel Dugarte. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var articlesTableView: UITableView!
    
    var newsDownloaded = [NewsArticle]()
    var deletedArticlesIdsArray = [String]()
    
    //lazy var used to handle pull to refresh
    /*lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //check for user deleted articles
        let defaults = UserDefaults.standard
        deletedArticlesIdsArray = defaults.stringArray(forKey: "deletedIdsArray") ?? [String]()
        print("the array exists? \(deletedArticlesIdsArray.count > 0)" )
        
        articlesTableView.dataSource = self
        articlesTableView.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        articlesTableView.addSubview(refreshControl)
        
        obtainArticlesData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Sendingg data to next view controller
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ArticleWebsiteViewController {
            destinationViewController.articleLink = ""
        }
    }
    
    //function pointed by refresh handler
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        obtainArticlesData()
        
        //self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    //MARK; - Alamofire request and handling
    func obtainArticlesData(){
        Alamofire.request("https://hn.algolia.com/api/v1/search_by_date?query=ios").responseJSON { response in
            guard response.result.isSuccess,
                let value = response.result.value else {
                    print("Error while fetching tags: \(String(describing: response.result.error))")
                    //completion(nil)
                    return
            }
            
            // 3
            /*let tags = JSON(value)["results"][0]["tags"].array?.map { json in
                json["tag"].stringValue
            }*/
            if let mArray = JSON(value)["hits"].array {
                print("array is \(mArray)")
                var obtainedArray = [NewsArticle]()
                for i in 0 ... mArray.count-1{
                    let json = JSON(mArray[i])
                    let na = NewsArticle()
                    na.title = json["story_title"].stringValue
                    na.creator = json["author"].stringValue
                    na.linkUrl = json["story_url"].stringValue
                    na.createdDate = json["created_at"].stringValue
                    na.creationDateI = json["created_at_i"].doubleValue
                    na.articleId = json["objectID"].stringValue
                    print("creation date on integer is \(na.creationDateI)")
                    if(self.deletedArticlesIdsArray.contains(na.articleId)){
                        print("loaded an article that was deleted")
                    }else{
                        obtainedArray.append(na)
                    }
                }
                if obtainedArray.count > 0 {
                    self.newsDownloaded = [NewsArticle]()
                    self.newsDownloaded = obtainedArray
                    self.articlesTableView.reloadData()
                }
            }
            
            // 4
            //completion(tags)
        }
    }
    
    //NARK: - Conforming to UITableViewDataSource protocol to add data to the tableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return data.count
        return newsDownloaded.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleTableViewCell") as! ArticleTableViewCell //1.
        
        let title = "\(newsDownloaded[indexPath.row].title)"
        let author = "\(newsDownloaded[indexPath.row].creator) - \(newsDownloaded[indexPath.row].createdDate)"
        
        //NSLog("texto que deberia ir es \(String(describing: shoppingCartData[indexPath.row].productName))")
        
        cell.articleTitle?.text = title //3.
        cell.articleSubtitle?.text = author
        
        return cell //4.
    }
    
    //MARK: - conforming to the UITAbleView Delegate to enable interaction with the table cells
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog(" Selected item number  \(indexPath.row)")
        
        launchNewxtViewController(linkUrlStr: newsDownloaded[indexPath.row].linkUrl)
    }

    func launchNewxtViewController(linkUrlStr : String){
        print("launching viewcontroller to url \(linkUrlStr)")
        
        /*
        let articleWebsiteViewController = ArticleWebsiteViewController()
        articleWebsiteViewController.articleLink = linkUrlStr
        self.navigationController?.pushViewController(articleWebsiteViewController, animated: false)
         */
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "newsArticleIdForViewController") as! ArticleWebsiteViewController
        newViewController.articleLink = linkUrlStr
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func setDeletedNewsArticleInDefaults(articleIdStr : String){
        deletedArticlesIdsArray.append(articleIdStr)
        let defaults = UserDefaults.standard
        defaults.set(deletedArticlesIdsArray, forKey: "deletedIdsArray")
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            print("looking to delete item \(indexPath.row)")
            setDeletedNewsArticleInDefaults(articleIdStr: newsDownloaded[indexPath.row].articleId)
            newsDownloaded.remove(at: indexPath.row)
            articlesTableView.reloadData()
        }
    }

}

