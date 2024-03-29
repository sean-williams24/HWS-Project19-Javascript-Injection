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

    @IBOutlet var script: UITextView!

    var pageTitle = ""
    var pageURL = ""
    var scripts = ["Title" : "alert(document.title);"]
    var selectedScript: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        let scripts = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(selectScript))
        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveScript))
        
        navigationItem.leftBarButtonItems = [scripts, save]
    
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
        //inputItems will be an array of data the parent app is sending to our extension to use.
        if let inputItems = extensionContext?.inputItems.first as? NSExtensionItem {
            
            //pull out the first attachment from the first input item.
            if let itemProvider = inputItems.attachments?.first {
                
                //ask the item provider to actually provide us with its item
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                }
            }
        }
        let url = URL(string: pageURL)
    
        UserDefaults.standard.set(url, forKey: "url")
        UserDefaults.standard.set(pageTitle, forKey: "title")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedScript = selectedScript {
            script.text = selectedScript
            print("View will appear")
        }

    }
    
    @objc func saveScript() {
        
        let ac = UIAlertController(title: "Save Script", message: "Please eneter a name...  ", preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
            //Add textfield text to sciptname
            let scriptName = ac.textFields?[0].text ?? "New Script"
            self.scripts[scriptName] = self.script.text

        }))
        
        present(ac, animated: true)
    }
    
    @objc func selectScript () {
//        let ac = UIAlertController(title: "Choose JavaScript", message: nil, preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "Display Title", style: .default, handler: { (alert) in
//            self.script.text = "alert(document.title);"
//        }))
//
//        present(ac, animated: true)
        
        //SEGUE to tableview
        
              
        performSegue(withIdentifier: "Scripts", sender: self)
  
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! Scripts
        vc.scripts = scripts
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        // Convert frame from size of screen which will now be the correct size of the kyboard
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        //Check if we are hiding
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        //Make scroll view scroll down to show what user has just tapped on
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]

        extensionContext?.completeRequest(returningItems: [item])
    }

}
