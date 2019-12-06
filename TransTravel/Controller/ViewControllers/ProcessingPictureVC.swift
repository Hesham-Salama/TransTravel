//
//  ProcessingPictureVC.swift
//  TransTravel
//
//  Created by Hesham Salama on 8/2/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProcessingPictureVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    public var pickedImage : UIImage!
    private let segueID = "toResult"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Processing Picture"
        imageView.image = pickedImage
        SVProgressHUD.setDefaultMaskType(.clear)
    }
    
    @IBAction func confirmButtonClicked(_ sender: UIButton) {
        parseTextAndNavigateIfNeeded()
    }
    
    private func parseTextAndNavigateIfNeeded() {
        displaySVProgressHUD(message: "Extracting Text from image...")
        MLVision.parseTextFrom(image: pickedImage) { [weak self](text) in
            guard let self = self else { return }
            self.dismissSVProgressHUD()
            guard let text = text, text.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
                self.displayAlertWithPoppingVC(title: "Error", details: "Couldn't identify text in the picture")
                return
            }
            guard let languageTextCode = Language.detectLanguage(text: text) else {
                self.displayAlertWithPoppingVC(title: "Error", details: "Language of extracted text couldn't be identified.")
                return
            }
            self.getTranslatedText(text, languageTextCode)
        }
    }
    
    fileprivate func getTranslatedText(_ text: String, _ languageTextCode: String) {
        self.displaySVProgressHUD(message: "Translating text to \(Language.languageNameSet)...")
        Network.getTranslation(for: text, textLanguageCode: languageTextCode, targetLanguageCode: Language.languageCodeSet, completionHandler: { (translatedText) in
            self.dismissSVProgressHUD()
            guard let translatedText = translatedText else {
                self.displayAlertWithPoppingVC(title: "Error", details: "Couldn't get translated text")
                return
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: self.segueID, sender: (text, translatedText, Language.getLanguageNameFor(languageCode: languageTextCode), Language.languageNameSet))
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let (originalText, translatedText, originalLanguage, targetLanguage) = sender as? (String?, String?, String?, String?), let resultVC = segue.destination as? ResultVC else {
            self.displayAlertWithPoppingVC(title: "Error", details: "Unknown error")
            return
        }
        resultVC.originalText = originalText
        resultVC.originalTextLanguage = originalLanguage
        resultVC.translatedText = translatedText
        resultVC.translatedTextLanguage = targetLanguage
    }
    
    private func displayAlertWithPoppingVC(title: String, details: String) {
        let alert = Alert.simple(title: title, content: details, defaultAction: {
            [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    private func dismissSVProgressHUD() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
    
    private func displaySVProgressHUD(message: String) {
        DispatchQueue.main.async {
            SVProgressHUD.show(withStatus: message)
        }
    }
}
