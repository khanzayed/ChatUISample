//
//  Message.swift
//  ChatUISample
//
//  Created by Faraz Habib on 17/05/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Message: NSManagedObject {
    
    func setupManagedObject(message:MessageDataModel) {
        self.text = message.getText()
        self.width = NSNumber(value: message.getWidth())
        self.height = NSNumber(value: message.getHeight())
        self.type = NSNumber(value: message.getMessageType().rawValue)
        self.isSpacingRequired = NSNumber(value: message.getIsSpacingRequired())
        self.image = message.getImageData()
        self.dateTime = message.getDateTime()
        self.isOutgoing = NSNumber(value: message.getIsOutgoing())
        self.headerDateStr = message.getHeaderDateString()
        self.messageDateStr = message.getTime()
    }
    
    internal func getText() -> String {
        return self.text
    }
    
    internal func getWidth() -> CGFloat {
        return CGFloat(self.width.floatValue)
    }
    
    internal func getHeight() -> CGFloat {
        return CGFloat(self.height.floatValue)
    }
    
    internal func getIsSpacingRequired() -> Bool {
        return self.isSpacingRequired.boolValue
    }
    
    internal func getMessageType() -> MessageType {
        return MessageType(rawValue: self.type.intValue)!
    }
    
    internal func getImage() -> UIImage? {
        guard let binaryData = image else {
            return nil
        }
        
        return UIImage(data: binaryData, scale: 1)
    }
    
    internal func getIsOutgoing() -> Bool {
        return self.isOutgoing.boolValue
    }
    
    internal func getHeaderDate() -> String? {
        return self.headerDateStr
    }
    
    internal func getDateTime() -> Date {
        return self.dateTime
    }
   
    internal func getMessageDate() -> String? {
        return self.messageDateStr
    }
    
}

extension Message {
    
    internal func isFirstMessageForTheDay() -> Bool {
        if Calendar.current.compare(self.getDateTime(), to: Date(), toGranularity: .day) == .orderedAscending {
            return true
        } else {
            return false
        }
    }
    
}

extension Message {
    
    @NSManaged fileprivate var text: String!
    @NSManaged fileprivate var width: NSNumber!
    @NSManaged fileprivate var height: NSNumber!
    @NSManaged fileprivate var type: NSNumber!
    @NSManaged fileprivate var isSpacingRequired: NSNumber!
    @NSManaged fileprivate var isOutgoing: NSNumber!
    @NSManaged fileprivate var dateTime: Date!
    @NSManaged fileprivate var image: Data!
    @NSManaged fileprivate var headerDateStr: String!
    @NSManaged fileprivate var messageDateStr: String!
    
}
