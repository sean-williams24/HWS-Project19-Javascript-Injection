//
//  ActionViewController.swift
//  Extension
//
//  Created by Sean Williams on 25/10/2019.
//  Copyright © 2019 Sean Williams. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        //inputItems will be an array of data the parent app is sending to our extension to use.
        if let inputItems = extensionContext?.inputItems.first as? NSExtensionItem {
            
            //pull out the first attachment from the first input item.
            if let itemProvider = inputItems.attachments?.first {
                
                //ask the item provider to actually provide us with its item
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    print(javaScriptValues)
                }
            }
        }
        
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}
