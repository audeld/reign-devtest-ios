//
//  ArticleWebsiteViewController.swift
//  reign-devtest-ios
//
//  Created by Audel Dugarte on 7/12/18.
//  Copyright © 2018 Audel Dugarte. All rights reserved.
//

import UIKit

class ArticleWebsiteViewController: UIViewController {

    var articleLink = ""
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //let url = NSURL (string: "https://www.simplifiedios.net");
        let url = NSURL (string: articleLink);
        let request = NSURLRequest(url: url! as URL)
        webView.loadRequest(request as URLRequest);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTouchBackButton(_ sender: UIBarButtonItem) {
    
        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
