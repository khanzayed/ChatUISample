//
//  MessageTextField.swift
//  ChatUISample
//
//  Created by Faraz Habib on 01/07/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import UIKit

class MessageTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    weak var overrideNextResponder: UIResponder?
    
    override var next: UIResponder? {
        if overrideNextResponder != nil {
            return overrideNextResponder
        } else {
            return super.next
        }
    }
   
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if overrideNextResponder != nil {
            return false
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }

}
