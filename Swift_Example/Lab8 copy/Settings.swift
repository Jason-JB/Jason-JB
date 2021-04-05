//
//  Settings.swift
//  Lab8
//
//  Created by Bendickson, Jason J on 12/1/19.
//  Copyright © 2019 Bendickson, Jason J. All rights reserved.
//

import Foundation
import UIKit
import SQLite3

class Settings: UIViewController {
  /*
    override func viewDidLoad() {
    super.viewDidLoad()
        
        view.backgroundColor = UIColor.orange
        
        let mySwitch = UISwitch()
        mySwitch.isOn = true
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        mySwitch.addControlEventRecognizer(.valueChanged, action: {() -> () in
            if let color: UIColor = red.backgroundColor {
                red.backgroundColor = blue.backgroundColor
                blue.backgroundColor = color
            }
        })
        
        
        
    }
}

extension UIControl {
    private struct AssociatedObjectKeys {
        static var controlEventRecognizer = "ControlEventAssociatedObjectKey"
    }
    
    private var controlEventAction: (() -> Void)? {
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.controlEventRecognizer, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let controlEventActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.controlEventRecognizer) as? (() -> Void)
            return controlEventActionInstance
        }
    }
    
    public func addControlEventRecognizer(_ event: UIControl.Event, action: (() -> Void)?) {
        isUserInteractionEnabled = true
        controlEventAction = action
        addTarget(self, action: #selector(handleControlEvent), for: event)
    }
    
    @objc private func handleControlEvent() {
        if let action = controlEventAction {
            action()
        }
    }
 */
}
