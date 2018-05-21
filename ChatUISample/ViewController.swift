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

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var msgTextView: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    
    private var message = [MessageDataModel]()
    private let maxWidth = UIScreen.main.bounds.width * 0.75
    private let font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
    private let singleRowMessageHeight:CGFloat = 16.0
    private let lastVisiblePoint = CGPoint(x: 10.0, y: UIScreen.main.bounds.height - 50.0)
    private var lastVisibleIndexPath:IndexPath?
    
    private let imageRowDimension:CGFloat = UIScreen.main.bounds.width / 2
    
    private var isOutgoing = false
    private var isSpacingRequired = false
    private var isFirstLoad = true
    
    private let dbAccessor = DatabaseAccessor()
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentControl.selectedSegmentIndex = 0
        msgTextView.autocorrectionType = .no
        msgTextView.autocapitalizationType = .sentences
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        
        
        
        if let storedMessages = dbAccessor.fetchAllMessages() {
            message.append(contentsOf: storedMessages)

            tableView.reloadData()
            
            DispatchQueue.main.async {
                let indexPath = IndexPath(item: self.message.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
            
//            if storedMessages.count > 15 {
//                let start = storedMessages.count - 15 - 1
//                let lastMessages = storedMessages[start..<storedMessages.count]
//                message.append(contentsOf: lastMessages)
//            }
//
//            tableView.reloadData()
//
//            DispatchQueue.main.async {
//                let indexPath = IndexPath(item: self.message.count - 1, section: 0)
//                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//            }
//
//            let limit = storedMessages.count - 15 - 1
//            for i in (0..<limit).reversed() {
//                let msg = storedMessages[i]
//                message.insert(msg, at: 0)
//
//                let indexPath = IndexPath(item: 0, section: 0)
//                tableView.insertRows(at: [indexPath], with: .automatic)
//            }
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
    
    fileprivate func updateVisibleIndexesByOne() {
        lastVisibleIndexPath = IndexPath(item: message.count - 1, section: 0)
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
            self.tableView.scrollToRow(at: self.lastVisibleIndexPath!, at: .bottom, animated: true)
        }
    }
    
    @IBAction func segmentControlTapped(_ sender: UISegmentedControl) {
        isOutgoing = !isOutgoing
        isSpacingRequired = true
    }
    
    @IBAction func sendTapped(_ sender: UIButton) {
        if msgTextView.text?.count == 0 {
            return
        }
        
        tableView.scrollToRow(at: IndexPath(item: message.count - 1, section: 0), at: .bottom, animated: true)
        
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
        
        let indexPath = IndexPath(item: message.count, section: 0)
        
        let dataModel = MessageDataModel(text: text, width: lblWidth, height: lblHeight, isSpacingRequired: isSpacingRequired, isOutgoing: isOutgoing)
        message.append(dataModel)
        msgTextView.text = ""
        isSpacingRequired = false
        
        tableView.insertRows(at: [indexPath], with: .bottom)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        updateVisibleIndexesByOne()
        
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
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let value:CGFloat = (message[indexPath.row].getIsSpacingRequired()) ? 34 : 29
        return message[indexPath.row].getCGFloatHeight() + value
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageTypeIdentifier") as! MessageTableViewCell
        
        cell.lblFont = font
        cell.message = message[indexPath.row]
        
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
            
            tableView.scrollToRow(at: IndexPath(item: message.count - 1, section: 0), at: .bottom, animated: true)
            
            let indexPath = IndexPath(item: message.count, section: 0)
            
            let dataModel = MessageDataModel(image: scaledImage, dimension: imageRowDimension, isSpacingRequired: isSpacingRequired, isOutgoing: isOutgoing)
            message.append(dataModel)
            msgTextView.text = ""
            isSpacingRequired = false
            
            DispatchQueue.main.async {
                self.tableView.insertRows(at: [indexPath], with: .bottom)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                
                self.updateVisibleIndexesByOne()
            }
            
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
