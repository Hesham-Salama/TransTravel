//
//  Network.swift
//  TransTravel
//
//  Created by Hesham Salama on 8/5/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import Foundation

class Network {
    
    static func getTranslation(for text: String, textLanguageCode: String, targetLanguageCode: String, completionHandler: @escaping (String?) -> ()) {
        
        guard let textEncoded = text.urlEncoded() else {
            print("Text encoding failed, resulted nil")
            completionHandler(nil)
            return
        }
        
        let googleTranslateURLString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=" + textLanguageCode + "&tl=" + targetLanguageCode + "&dt=t&dt=t&q=" + textEncoded
        print(text)
        print(googleTranslateURLString)
        guard let url = URL(string: googleTranslateURLString) else {
            print("Making URL object from string url :\(googleTranslateURLString) failed")
            completionHandler(nil)
            return
        }
        
        getRequest(url: url, timeout: TimeInterval(25)) { (translatedText) in
            completionHandler(translatedText)
        }
    }
    
    private static func getRequest(url: URL, timeout: TimeInterval, completionHandler: @escaping (String?) -> ()) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: configuration)
        session.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print(error.localizedDescription)
                completionHandler(nil)
                return
            }
            guard let data = data else {
                print("No data recieved")
                completionHandler(nil)
                return
            }
            
            guard let translatedText = getTranslatedTextFromGoogleTranslateAPI(data: data) else {
                print("Failed to convert Data to JSON")
                completionHandler(nil)
                return
            }
            
            completionHandler(translatedText)
        }.resume()
    }
    
    private static func getTranslatedTextFromGoogleTranslateAPI(data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [Any], let translationPartJson = json[0] as? [Any] else {
            return nil
        }
        var translatedText = ""
        for translatedTextItemJSON in translationPartJson {
            if let temp = translatedTextItemJSON as? [Any], temp.count > 0, let partialTranslatedText = temp[0] as? String {
                translatedText = translatedText + partialTranslatedText
            }
        }
        return translatedText
    }
}

fileprivate extension CharacterSet {
    
    static let urlQueryParameterAllowed = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&?"))
    
    static let urlQueryDenied           = CharacterSet.urlQueryAllowed.inverted()
    static let urlQueryKeyValueDenied   = CharacterSet.urlQueryParameterAllowed.inverted()
    static let urlPathDenied            = CharacterSet.urlPathAllowed.inverted()
    static let urlFragmentDenied        = CharacterSet.urlFragmentAllowed.inverted()
    static let urlHostDenied            = CharacterSet.urlHostAllowed.inverted()
    
    static let urlDenied                = CharacterSet.urlQueryDenied
        .union(.urlQueryKeyValueDenied)
        .union(.urlPathDenied)
        .union(.urlFragmentDenied)
        .union(.urlHostDenied)
    
    func inverted() -> CharacterSet {
        var copy = self
        copy.invert()
        return copy
    }
}

fileprivate extension String {
    func urlEncoded(denying deniedCharacters: CharacterSet = .urlDenied) -> String? {
        return addingPercentEncoding(withAllowedCharacters: deniedCharacters.inverted())
    }
}
