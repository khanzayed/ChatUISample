//
//  MessageDataModel.swift
//  ChatUISample
//
//  Created by Faraz Habib on 17/05/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import Foundation
import UIKit

enum MessageType:Int {
    case Text = 0
    case Image
}

class MessageDataModel {
    
    private var text: String
    private var width: CGFloat
    private var height: CGFloat
    private var type: MessageType
    private var image: UIImage?
    private var isSpacingRequired: Bool
    private var isOutgoing: Bool
    
    init(text:String, width:CGFloat, height:CGFloat, isSpacingRequired:Bool, isOutgoing:Bool) {
        self.text = text
        self.width = width
        self.height = height
        self.type = .Text
        self.isSpacingRequired = isSpacingRequired
        self.image = nil
        self.isOutgoing = isOutgoing
    }
    
    init(image:UIImage, dimension:CGFloat, isSpacingRequired:Bool, isOutgoing:Bool) {
        self.text = "Image"
        self.image = image
        self.width = dimension
        self.height = dimension
        self.type = .Image
        self.isSpacingRequired = isSpacingRequired
        self.isOutgoing = isOutgoing
    }
    
    internal func getText() -> String {
        return self.text
    }
    
    internal func getWidth() -> Float {
        return Float(self.width)
    }
    
    internal func getCGFloatWidth() -> CGFloat {
        return self.width
    }
    
    internal func getHeight() -> Float {
        return Float(self.height)
    }
    
    internal func getCGFloatHeight() -> CGFloat {
        return self.height
    }
    
    internal func getIsSpacingRequired() -> Bool {
        return self.isSpacingRequired
    }
    
    internal func getMessageType() -> MessageType {
        return self.type
    }
    
    internal func getImageData() -> Data? {
        guard let img = image else {
            return nil
        }
        
        return UIImagePNGRepresentation(img)
    }
    
    internal func getImage() -> UIImage? {
        return self.image
    }
    
    internal func getIsOutgoing() -> Bool {
        return isOutgoing
    }
    
}
