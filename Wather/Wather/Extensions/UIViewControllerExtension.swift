//
//  UIViewControllerExtension.swift
//  Wather
//
//  Created by Pushpendra on 19/05/23.
//

import UIKit

extension UIViewController {
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            T(nibName: String(describing: T.self), bundle: nil)
        }

        return instantiateFromNib()
    }
}
