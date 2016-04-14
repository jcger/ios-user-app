//
//  TermsViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 11/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

class TermsViewController: UIViewController {
    
    @IBOutlet weak var termsWebView: UIWebView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadTermsHTML()
    }
    
    
    func loadTermsHTML() {
        
        //Load the HTML file from resources
        let path = NSBundle.mainBundle()
            .pathForResource("terms", ofType: "html")
        
        let url = NSURL(fileURLWithPath: path!)
        
        if let data = NSData(contentsOfURL: url) {
            
            termsWebView.loadHTMLString(NSString(data: data,
                encoding: NSUTF8StringEncoding) as! String, baseURL: nil)
            
        }
    }
}
