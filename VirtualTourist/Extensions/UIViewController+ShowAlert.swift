//
//  UIViewController+ShowAlert.swift
//  VirtualTourist
//
//  Created by Eman Albarqi on 23/01/2019.
//  Copyright © 2019 Eman Albarqi. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
