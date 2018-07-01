//
//  ViewController.swift
//  ChatUISample
//
//  Created by Faraz Habib on 15/05/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import UIKit
import Foundation
import AlamofireImage
import CoreData

class ViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var msgTextView: MessageTextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBlankTableHeader: UIView!
    
    private var message = [MessageDataModel]()
    private let maxWidth = UIScreen.main.bounds.width * 0.75
    private let font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
    private let singleRowMessageHeight:CGFloat = 16.0
    private let lastVisiblePoint = CGPoint(x: 10.0, y: UIScreen.main.bounds.height - 50.0)
    private var lastVisibleIndexPath:IndexPath?
    private var lastTwoHeaderIndexPath:[IndexPath]?
    
    private let imageRowDimension:CGFloat = UIScreen.main.bounds.width / 2
    
    private var isOutgoing = false
    private var isSpacingRequired = false
    private var isFirstLoad = true
    
    private let dbAccessor = DatabaseAccessor()
    var imagePicker = UIImagePickerController()

    fileprivate lazy var controller : NSFetchedResultsController<Message> = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Message>(entityName: "Message")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
        
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "headerDateStr", cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentControl.selectedSegmentIndex = 0
        msgTextView.autocorrectionType = .no
        msgTextView.autocapitalizationType = .sentences
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        
        viewBlankTableHeader.layer.cornerRadius = 4.0
        viewBlankTableHeader.layer.borderColor = UIColor(rgba: "#CFCFCF").cgColor
        viewBlankTableHeader.layer.borderWidth = 0.5
        
        do {
            try controller.performFetch()
            
            if controller.sections!.count > 0 {
                viewBlankTableHeader.isHidden = true
                DispatchQueue.main.async {
                    let lastSection = self.controller.sections!.count - 1
                    let lastRow = self.controller.sections![lastSection].numberOfObjects - 1
                    if lastRow >= 0 {
                        self.tableView.scrollToRow(at: IndexPath(item: lastRow, section: lastSection), at: .bottom, animated: false)
                    }
                }
            } else {
                viewBlankTableHeader.isHidden = false
            }
        } catch {
            
        }
        
        imagePicker.delegate = self
    }


    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func updateVisibleIndexes() {
        lastVisibleIndexPath = self.tableView.indexPathsForVisibleRows?.last
    }
    
    @objc private func keyboardDidShow(notification:Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            updateVisibleIndexes()
            
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.textViewBottomConstraint.constant = -keyboardHeight
                self.view.layoutIfNeeded()
            }) { (true) in
                if let indexPath = self.lastVisibleIndexPath {
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    @objc private func keyboardDidHide(notification:Notification) {
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.textViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }) { (true) in
            if let index = self.lastVisibleIndexPath {
                self.tableView.scrollToRow(at: index, at: .bottom, animated: true)
            }
        }
    }
    
    private func reloadHeaders() {
        for section in 0..<self.tableView.numberOfSections {
            if let headerView = self.tableView.headerView(forSection: section) {
                configureHeaderView(headerView: headerView, section: section)
            }
        }
    }
    
    fileprivate func configureHeaderView(headerView:UIView, section:Int) {
        _ = headerView.subviews.compactMap{$0.removeFromSuperview()}
        
        let lbl = UILabel(frame: CGRect(x: 10, y: 0, width: 80, height: 20))
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.medium)
        
        let headerText = controller.sections![section].name
        if headerText.count > 0 {
            if let value = DateHelper.shared.getTodayOrYesterday(fromString: headerText) {
                lbl.text = value
            } else {
                lbl.text = headerText
            }
        } else if headerText.count == 0, controller.sections?.count == 1 {
            lbl.text = "Today"
        }
        lbl.textColor = UIColor.darkGray
        lbl.textAlignment = .center
        
        let x:CGFloat = (UIScreen.main.bounds.width / 2) - 50
        let textView = UIView(frame: CGRect(x: x, y: 0, width: 100, height: 20))
        textView.layer.cornerRadius = 4.0
        textView.backgroundColor = UIColor(rgba: "#DBF0F9")
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor(rgba: "#CFCFCF").cgColor
        
        textView.addSubview(lbl)
        
        headerView.addSubview(textView)
    }
    
    @IBAction func segmentControlTapped(_ sender: UISegmentedControl) {
        isOutgoing = !isOutgoing
        isSpacingRequired = true
    }
    
    @IBAction func sendTapped(_ sender: UIButton) {
        if msgTextView.text?.count == 0 {
            return
        }
        
        var lblWidth:CGFloat = 0
        var lblHeight:CGFloat = 0
        
        let text = msgTextView.text!
        let singleRowWidth = text.widthForSingleRow(font: font) //text.widthOfString(usingFont: font)
        if singleRowWidth > maxWidth {
            lblHeight = text.height(withConstrainedWidth: maxWidth, font: font)
            lblWidth = maxWidth
        } else {
            lblWidth = (singleRowWidth < 50) ? 50 : singleRowWidth
            lblHeight = singleRowMessageHeight
        }
    
        let dataModel = MessageDataModel(text: text, width: lblWidth, height: lblHeight, isSpacingRequired: isSpacingRequired, isOutgoing: isOutgoing)
        message.append(dataModel)
        msgTextView.text = ""
        isSpacingRequired = false
        
        dbAccessor.saveMessage(messageDataModel: dataModel)
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        if controller.sections!.count > 0 {
            controller.delegate = nil
            dbAccessor.deleteAllMessages()
            do {
                try controller.performFetch()
                viewBlankTableHeader.isHidden = false
                tableView.reloadData()
            } catch _ {
                
            }
            controller.delegate = self
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let index = newIndexPath {
                DispatchQueue.main.async {
                    self.viewBlankTableHeader.isHidden = true
                    if self.tableView.numberOfSections > index.section {
                        self.tableView.insertRows(at: [index], with: .bottom)
                    } else {
                        self.tableView.insertSections([index.section], with: .bottom)
                        self.reloadHeaders()
                    }
                    self.tableView.scrollToRow(at: index, at: .bottom, animated: true)
                    
                    self.lastVisibleIndexPath = index
                }
            }
        default:
            break
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return controller.sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.sections![section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let msg = MessageDataModel(database: controller.object(at: indexPath))
        let value:CGFloat = (msg.getIsSpacingRequired()) ? 34 : 29
        return msg.getCGFloatHeight() + value
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
        configureHeaderView(headerView: headerView, section: section)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageTypeIdentifier") as! MessageTableViewCell
        
        let msg = MessageDataModel(database: controller.object(at: indexPath))
        cell.lblFont = font
        cell.message = msg
        
        cell.changeNextResponderBlock = { [weak self] (messageCell) in
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.msgTextView.isFirstResponder {
                strongSelf.msgTextView.overrideNextResponder = messageCell
            } else {
                cell.becomeFirstResponder()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.view.endEditing(true)
    }
    
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateVisibleIndexes()
    }
    
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera() {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let scaledImage = pickedImage.af_imageAspectScaled(toFill: CGSize(width: imageRowDimension, height: imageRowDimension))
            
            let dataModel = MessageDataModel(image: scaledImage, dimension: imageRowDimension, isSpacingRequired: isSpacingRequired, isOutgoing: isOutgoing)
            message.append(dataModel)
            msgTextView.text = ""
            isSpacingRequired = false
          
            dbAccessor.saveMessage(messageDataModel: dataModel)
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
}

extension ViewController: UITextFieldDelegate {
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension String {
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let size = self.size(withAttributes: [.font: font])
        return size.width
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func widthForSingleRow( font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: 16.0)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = self
        label.font = font
        label.sizeToFit()
        
        return label.frame.height
    }
    
}
