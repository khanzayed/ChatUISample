//
//  MessageTableViewCell.swift
//  ChatUISample
//
//  Created by Faraz Habib on 15/05/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var lblMessage: UILabel!
    
    internal var lbl: UILabel?
    internal var textView: UIView?
    internal var dateLbl: UILabel?
    internal var imgView: UIImageView?
    internal var longTap: UILongPressGestureRecognizer?
    
    internal var lblFont:UIFont!
    internal var message:MessageDataModel! {
        didSet {
            switch message.getMessageType() {
            case .Text:
                setupTextViewCell()
            case .Image:
                setupImageViewCell()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupTextViewCell() {
        lbl?.removeFromSuperview()
        dateLbl?.removeFromSuperview()
        textView?.removeFromSuperview()
        imageView?.removeFromSuperview()
        
        longTap?.removeTarget(self, action: #selector(self.handleLongTap(sender:)))
        longTap = nil
        
        lbl = nil
        dateLbl = nil
        textView = nil
        imgView = nil
        
        let textWidth = message.getCGFloatWidth()
        let textHeight = message.getCGFloatHeight()
        
        lbl = UILabel(frame: CGRect(x: 5, y: 5, width: textWidth, height: textHeight))
        lbl!.numberOfLines = 0
        lbl!.font = lblFont
        lbl!.text = message.getText()
        lbl!.sizeToFit()
        
        dateLbl = UILabel(frame: CGRect(x: 0, y: textHeight + 10, width: textWidth + 5, height: 10))
        dateLbl!.numberOfLines = 1
        dateLbl!.font = UIFont.systemFont(ofSize: 9, weight: UIFont.Weight.light)
        dateLbl!.text = message.getTime()
        dateLbl!.textAlignment = .right
        
        let x:CGFloat = (message.getIsOutgoing()) ? (UIScreen.main.bounds.width - textWidth - 20 - 10) : 10
        let y:CGFloat = (message.getIsSpacingRequired()) ? 7 : 2
        textView = UIView(frame: CGRect(x: x, y: y, width: textWidth + 20, height: textHeight + 25))
        textView!.layer.cornerRadius = 4.0
        textView!.backgroundColor = (message.getIsOutgoing()) ? UIColor(rgba: "#DDF8C6") : UIColor(rgba: "#F4F4F4")
        
        textView!.addSubview(lbl!)
        textView!.addSubview(dateLbl!)
        self.addSubview(textView!)
        
        longTap = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap(sender:)))
        longTap!.minimumPressDuration = 1.0
        textView!.addGestureRecognizer(longTap!)
    }
    
    func setupImageViewCell() {
        lbl?.removeFromSuperview()
        dateLbl?.removeFromSuperview()
        textView?.removeFromSuperview()
        imgView?.removeFromSuperview()
        
        lbl = nil
        dateLbl = nil
        textView = nil
        imgView = nil
        
        let textWidth = message.getCGFloatWidth()
        let textHeight = message.getCGFloatHeight()
        
        imgView = UIImageView(frame: CGRect(x: 5, y: 5, width: textWidth, height: textHeight))
        imgView!.layer.cornerRadius = 4.0
        imgView!.clipsToBounds = true
        DispatchQueue.main.async {
            self.imgView?.image = self.message.getImage()
        }
        
        dateLbl = UILabel(frame: CGRect(x: 0, y: textHeight + 10, width: textWidth + 5, height: 10))
        dateLbl!.numberOfLines = 1
        dateLbl!.font = UIFont.systemFont(ofSize: 9, weight: UIFont.Weight.light)
        dateLbl!.text = message.getTime()
        dateLbl!.textAlignment = .right
        
        let x:CGFloat = (message.getIsOutgoing()) ? (UIScreen.main.bounds.width - textWidth - 20 - 10) : 10
        let y:CGFloat = (message.getIsSpacingRequired()) ? 7 : 2
        textView = UIView(frame: CGRect(x: x, y: y, width: textWidth + 20, height: textHeight + 25))
        textView!.layer.cornerRadius = 4.0
        textView!.backgroundColor = (message.getIsOutgoing()) ? UIColor(rgba: "#DDF8C6") : UIColor(rgba: "#F4F4F4")
        
        textView!.addSubview(imgView!)
        textView!.addSubview(dateLbl!)
        self.addSubview(textView!)
    }
    
}

extension MessageTableViewCell {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc fileprivate func handleLongTap(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began, let senderView = textView else {
            return
        }
        
        // Make responsiveView the window's first responder
        senderView.becomeFirstResponder()
        
        // Set up the shared UIMenuController
        let saveMenuItem = UIMenuItem(title: "Copy", action: #selector(copyTapped))
        UIMenuController.shared.menuItems = [saveMenuItem]
        
        // Tell the menu controller the first responder's frame and its super view
        UIMenuController.shared.setTargetRect(senderView.frame, in: self)
        
        // Animate the menu onto view
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }
    
    @objc fileprivate func copyTapped() {
        
    }
    
}
