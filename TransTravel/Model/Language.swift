//
//  Language.swift
//  TransTravel
//
//  Created by Hesham Salama on 8/2/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import Foundation
import UIKit

class Language {
    
    private static let LANGUAGE_KEY = "lang_code"
    private static let defaultLangCode = "en"
    private static let defaultLangLocalized = "English"
    private static var languagesMap = [String : String]()
    
    static var languageCodeSet : String {
        return UserDefaults.standard.string(forKey: LANGUAGE_KEY) ?? defaultLangCode
    }
    
    static var languageNameSet : String {
        return getLanguageNameFor(languageCode: languageCodeSet) ?? defaultLangLocalized
    }
    
    static var availableLanguages : [String] = {
        if languagesMap.isEmpty {
            setLanguages()
        }
        return Array(languagesMap.keys).sorted(by: { $0 < $1 })
    }()
    
    static func setLanguage(languageName: String) {
        UserDefaults.standard.set(languagesMap[languageName] ?? defaultLangCode, forKey: LANGUAGE_KEY)
    }
    
    static func getLanguageNameFor(languageCode: String) -> String? {
        return Locale.current.localizedString(forIdentifier: languageCode)
    }
    
    private static func setLanguages() {
        let availableLocaleIDs = NSLocale.availableLocaleIdentifiers
        for id in availableLocaleIDs {
            if let languageName = Locale.current.localizedString(forIdentifier: id), !languageName.contains("(") {
                languagesMap[languageName] = id
            }
        }
    }
    
    static func detectLanguage(text: String) -> String? {
        let text = text.replacingOccurrences(of: "\n", with: " ")
        guard let dominantLanguage = NSLinguisticTagger.dominantLanguage(for: text), dominantLanguage != "und" else {
            return nil
        }
        return dominantLanguage
    }
}
