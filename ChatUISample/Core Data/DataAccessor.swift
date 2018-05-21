    //
//  DataAccessor.swift
//  ChatUISample
//
//  Created by Faraz Habib on 17/05/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DatabaseAccessor {
    
    var appDelegate:AppDelegate!
    var managedObjectContext:NSManagedObjectContext!
    
    init() {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = self.appDelegate.persistentContainer.viewContext
    }
    
    func saveMessage(messageDataModel:MessageDataModel) {
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: managedObjectContext) as! Message
        message.setupManagedObject(message: messageDataModel)
        
        do {
            try managedObjectContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func fetchAllMessages() -> [MessageDataModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
        do {
            if let results = try managedObjectContext.fetch(fetchRequest) as? [Message], results.count > 0 {
                var messageArray = [MessageDataModel]()
                for msg in results {
                    switch msg.getMessageType() {
                    case .Text:
                        messageArray.append(MessageDataModel(text: msg.getText(), width: msg.getWidth(), height: msg.getHeight(), isSpacingRequired: msg.getIsSpacingRequired(), isOutgoing: msg.getIsOutgoing()))
                    case .Image:
                        if let image = msg.getImage() {
                            messageArray.append(MessageDataModel(image: image, dimension: msg.getWidth(), isSpacingRequired: msg.getIsSpacingRequired(), isOutgoing: msg.getIsOutgoing()))
                        }
                    }
                }
                return messageArray
            }
        } catch {
            print ("There was an error")
        }
        return nil
    }
    
}
