//
//  ViewUtils.swift
//  IDnow
//
//  Created by Aare Undo on 02.12.2021.
//

import Foundation
import UIKit

class ViewUtils {
    
    static func rootController() -> UIViewController {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            return rootViewController
        }
        return UIApplication.shared.windows.last?.rootViewController ?? UIViewController()
    }
    
}
