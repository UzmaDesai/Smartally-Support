//
//  HTTPUtility.swift
//  Smartally Support
//
//  Created by Muqtadir Ahmed on 19/05/17.
//  Copyright © 2017 Bitjini. All rights reserved.
//

import Alamofire

protocol HTTPUtilityDelegate {
    func completedRequest(response: [String : AnyObject])
    func failedRequest(response: String)
}

class HTTPUtility {
    
    static let shared = HTTPUtility()
    
    // Delegate.
    var delegate: HTTPUtilityDelegate?
    // Current request.
    var request: DataRequest?
}

extension HTTPUtility {
    
    func send(url: String, method: HTTPMethod, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) {
        print(url)
//        request = Alamofire
//            .request(url,
//                     method: method,
//                     parameters: parameters,
//                     headers: headers)
//            .responseJSON() { (response) in
//                print(response)
//                switch response.result {
//                case .success:
//                    self.success(response.result.value)
//                case .failure(let error):
//                    self.failure(error)
//                }
//        }
        
        request = Alamofire.request(url,
                                    method: method,
                                    parameters: parameters,
                                    encoding: JSONEncoding(options: []))
        .responseJSON() { (response) in
            print(response)
            switch response.result {
            case .success:
                self.success(response.result.value)
            case .failure(let error):
                self.failure(error)
            }
        }

}
    
    private func success(_ data: Any?) {
        guard let data = data as? [String : AnyObject] else { failure(nil); return }
        self.delegate?.completedRequest(response: data)
    }
    
    private func failure(_ data: Error?) {
        self.delegate?.failedRequest(response: data?.localizedDescription ?? "Unknown response." )
    }
    
    func registerDevice(withToken token: String) {
    guard let url = URL(string: "https://reimburse.herokuapp.com/register_device/")
        else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(token,
                         forHTTPHeaderField: "DEVICE-TOKEN")
        request.addValue("",
                         forHTTPHeaderField: "NAME")
        request.addValue("ios",
                         forHTTPHeaderField: "PLATFORM")
        request.addValue(getDate(),
                         forHTTPHeaderField: "DATE")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("Register device token status =>", httpResponse.statusCode)
            }
        }
        task.resume()
    }
    
    func getDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}
