//
//  BaseViewController.swift
//  Smartally Support
//
//  Created by Muqtadir Ahmed on 19/05/17.
//  Copyright © 2017 Bitjini. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    // Class Instances.
    // Indicator.
    lazy var indicator: ILIndicator = ILIndicator()

    override func viewDidLoad() { super.viewDidLoad() ; oninit() }
    
    // End editing.
    func endEditing() {
        view.endEditing(true)
    }
    
    func oninit() {
        middleware.http.hdelegate = self
    }
    
    // Error to User interface.
    func dropBanner(withString message: String) {
        let banner = ILBanner(title: "Error Occurred",
                              subtitle: message, image: nil,
                              backgroundColor: .white)
        banner.titleLabel.textColor = .darkGray
        banner.detailLabel.textColor = .darkGray
        banner.dismissesOnTap = true
        banner.dismissesOnSwipe = true
        banner.show(navigationController?.view ?? view, duration: 3.0)
    }
}

// MARK: Invalid token handler.
extension BaseViewController: HttpDelegate {
    
    func invalidateSession() {
        let alert = UIAlertController(title: "Authenticate Again",
                                      message: "You cannot use SmarTally on two devices using same registration number simultaneously.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: { (okHandler) in
                                        // Delete user settings.
                                        // dataManager.logOutUser()
                                       // dataManager.shouldLogin(value: false)
                                        user.logOut()
                                        
                                        // Load login screen.
                                    //    let appdelegate = UIApplication.shared.delegate as! AppDelegate
//                                        let storyboard = UIStoryboard(name: "Register", bundle: nil)
//                                        let rootVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
//                                        appdelegate.window?.rootViewController = rootVC
        }))
        
        DispatchQueue.main.async {
            self.present(alert,
                         animated: true,
                         completion: nil)
        }
    }
}


