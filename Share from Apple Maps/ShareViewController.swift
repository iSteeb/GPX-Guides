//
//  ShareViewController.swift
//  Share from Apple Maps
//
//  Created by Steven Duzevich on 15/1/2024.
//

import UIKit
import UniformTypeIdentifiers
import SwiftUI

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem, let itemProvider = extensionItem.attachments?.last else {
            close()
            return
        }
        
        let urlDataType = UTType.url.identifier
        if itemProvider.hasItemConformingToTypeIdentifier(urlDataType) {
            
            itemProvider.loadItem(forTypeIdentifier: urlDataType , options: nil) { (providedURL, error) in
                if error != nil {
                    self.close()
                    return
                }
                
                if let text = (providedURL as? URL)?.absoluteString {
                    DispatchQueue.main.async {
                        // host the SwiftU view
                        let contentView = UIHostingController(rootView: ShareExtensionView(guideURL: text))
                        self.addChild(contentView)
                        self.view.addSubview(contentView.view)
                        
                        // set up constraints
                        contentView.view.translatesAutoresizingMaskIntoConstraints = false
                        contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                        contentView.view.bottomAnchor.constraint (equalTo: self.view.bottomAnchor).isActive = true
                        contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
                        contentView.view.rightAnchor.constraint (equalTo: self.view.rightAnchor).isActive = true
                    }                } else {
                        self.close()
                        return
                    }
            }
            
        } else {
            close()
            return
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("close"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.close()
            }
        }
        
    }
    
    func close() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
}
