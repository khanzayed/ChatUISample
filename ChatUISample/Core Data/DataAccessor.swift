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
    
    func saveMessages(messages:[MessageDataModel]) {
        var messageList = [Message]()
        for messageDataModel in messages {
            let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: managedObjectContext) as! Message
            message.setupManagedObject(message: messageDataModel)
            messageList.append(message)
        }
        
        do {
            try managedObjectContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func fetchAllMessages() -> NSFetchedResultsController<Message>? {
        let fetchRequest = NSFetchRequest<Message>(entityName: "Message")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "headerDateStr", cacheName: nil)
        do {
            try controller.performFetch()
            return controller
        } catch {
            print ("There was an error")
        }
        return nil
    }
    
    internal func deleteAllMessages() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try managedObjectContext.execute(request)
        } catch _ {
            
        }
    }
    
}
