//
//  LocationService.swift
//  Wather
//
//  Created by Pushpendra on 18/05/23.
//

import Foundation
import UIKit

struct AlertManager {
    static func createErrorAlert(title: String, error: Error) -> UIAlertController {
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okButton)
        return alert
    }

    static func createAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okButton)
        return alert
    }
}
