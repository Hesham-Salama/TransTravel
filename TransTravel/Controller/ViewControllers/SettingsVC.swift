//
//  SettingsVC.swift
//  TransTravel
//
//  Created by Hesham Salama on 8/2/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {
    
    private let segueID = "aboutsegue"
    private let cellID = "settingscell"
    private let settings = ["Target Language", "About"]
    private let rowHeight : CGFloat = 60.0
    private let pickerHeight : CGFloat = 400
    
    lazy var picker : UIPickerView = {
        var picker = UIPickerView.init()
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - pickerHeight, width: UIScreen.main.bounds.size.width, height: pickerHeight)
        return picker
    }()
    
    lazy var toolBar: UIToolbar = {
        var toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - pickerHeight, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .blackTranslucent
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        return toolBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
        setupPickerDelegates()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            showLanguagesPicker()
        case 1:
            performSegue(withIdentifier: segueID, sender: self)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var detailText = ""
        if indexPath.row == 0 {
            detailText = Language.languageNameSet
        }
        return makeCell(indexPath: indexPath, mainText: settings[indexPath.row], detailText: detailText)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    private func makeCell(indexPath: IndexPath, mainText: String, detailText: String) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = mainText
        cell.detailTextLabel?.text = detailText
        return cell
    }
}

extension SettingsVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func setupPickerDelegates() {
        picker.delegate = self
        picker.dataSource = self
    }
    
    func showLanguagesPicker() {
        self.view.addSubview(picker)
        self.view.addSubview(toolBar)
    }
    
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Language.availableLanguages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Language.availableLanguages[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Language.setLanguage(languageName: Language.availableLanguages[row])
        tableView.reloadData()
    }
}
