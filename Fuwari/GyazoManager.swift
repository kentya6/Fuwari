//
//  GyazoManager.swift
//  Fuwari
//
//  Created by sho on 2021/03/13.
//  Copyright © 2021 AppKnop. All rights reserved.
//

import Cocoa

class GyazoManager: NSObject {
    
    static let shared = GyazoManager()
    
    let redirectUri = "fuwari://gyazo_oauth"
    
    private final let env = ProcessInfo.processInfo.environment
    private final let host = "https://gyazo.com"
    private let clientId: String?
    private let secretKey: String?
    private let isAvailable: Bool

    private var accessToken: String? = nil
    
    override init() {
        let _clientId = env["GYAZO_CLIENT_ID"]
        let _secretKey = env["GYAZO_SECRET"]
    
        isAvailable = (_clientId != nil && _secretKey != nil)
        clientId = _clientId
        secretKey = _secretKey
    }
    
    func startOauth() {
        if !isAvailable { warningAlert(); return }
        
        let requestURL = URL(string: "\(host)/oauth/authorize?client_id=\(clientId!)&redirect_uri=\(redirectUri)&response_type=code")
        NSWorkspace.shared.open(requestURL!)
    }
    
    func handleOauthCode(url: URL) {
        guard let code = url.queryValue(for: "code") else { return }
        getAccessToken(code: code)
    }
    
    func uploadImage(image: NSImage) {
        postImageWithEasyAuth(image: image)
    }
    
    private func getAccessToken(code: String) {
        if !isAvailable { warningAlert(); return }
        
        let url = URL(string: "\(host)/oauth/token?client_id=\(clientId!)&redirect_uri=\(redirectUri)&code=\(code)&grant_type=authorization_code&client_secret=\(secretKey!)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                print("request = \(data)")
                return
            }

            let responseString = String(data: data, encoding: .utf8)!
            let responseData: Data =  responseString.data(using: String.Encoding.utf8)!
            do {
                let items = try JSONSerialization.jsonObject(with: responseData) as! Dictionary<String, Any>
                accessToken = (items["access_token"] as! String)
            } catch {
                print("response json parse error: \(error)")
            }
        }

        task.resume()
    }
    
    private func postImageWithEasyAuth(image: NSImage) {
        if !isAvailable { warningAlert(); return }
        
        let boundary = UUID().uuidString
        let url = URL(string: "https://upload.gyazo.com/api/upload/easy_auth?client_id=\(clientId!)&referer_url=\(redirectUri)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = image.tiffRepresentation!
        let bitmap = NSBitmapImageRep(data: imageData)!
        let convertImage = bitmap.representation(using: .png, properties: [:])!
        let base64 = "data:image/png;base64," + convertImage.base64EncodedString()
        
        var form = Data()
        form.append("--\(boundary)\r\n".data(using: .utf8, allowLossyConversion: false)!)
        form.append("Content-Disposition: form-data; name=\"image_url\"\r\n\r\n".data(using: .utf8, allowLossyConversion: false)!)
        form.append("\(base64)\r\n".data(using: .utf8, allowLossyConversion: false)!)
        form.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = form
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                print("request = \(data)")
                return
            }

            let responseString = String(data: data, encoding: .utf8)!
            let responseData: Data =  responseString.data(using: String.Encoding.utf8)!
            do {
                let items = try JSONSerialization.jsonObject(with: responseData) as! Dictionary<String, Any>
                let imageUrl = URL(string: (items["get_image_url"] as! String))!
                print(imageUrl)
                NSWorkspace.shared.open(imageUrl)
            } catch {
                print("response json parse error: \(error)")
            }
            
            print(responseData)
        }

        task.resume()
    }
    
    private func warningAlert() {
        if isAvailable { return }
    
        let alert = NSAlert.init()
        alert.alertStyle = .critical
        alert.messageText = "Cannot connect Gyazo"
        alert.informativeText = "GYAZO_CLIENT_ID or GYAZO_SECRET is empty.\nPlease check your scheme's environment."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

public extension URL {
    func queryValue(for key: String) -> String? {
        let queryItems = URLComponents(string: absoluteString)?.queryItems
        return queryItems?.filter { $0.name == key }.compactMap { $0.value }.first
    }
}
