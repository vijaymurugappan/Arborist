//
//  WebViewController.swift
//  Arborist
//
//  Created by Vijay Murugappan Subbiah on 9/22/18.
//  Copyright © 2018 VMS. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var urlString = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) {
            (data,response,error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.webView.load(request)
                }
            }
            else {
                //Error
            }
        }
        task.resume()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
