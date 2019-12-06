//
//  ResultVC.swift
//  TransTravel
//
//  Created by Hesham Salama on 8/2/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import UIKit

class ResultVC: UIViewController {
    
    @IBOutlet weak var originalTextView: UITextView!
    @IBOutlet weak var translatedFromToLabel: UILabel!
    @IBOutlet weak var translatedTextView: UITextView!
    var originalText: String?
    var translatedText: String?
    var originalTextLanguage: String?
    var translatedTextLanguage: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Result"
        setTextViews()
        setLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        if isMovingFromParent {
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    private func setTextViews() {
        originalTextView.text = originalText ?? ""
        translatedTextView.text = translatedText ?? ""
    }
    
    private func setLabel() {
        translatedFromToLabel.text = "Translated from \(originalTextLanguage ?? "undefined") to \(translatedTextLanguage ?? "undefined")"
    }
}
