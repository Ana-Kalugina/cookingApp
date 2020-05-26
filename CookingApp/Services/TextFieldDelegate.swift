//
//  TextFieldDelegate.swift
//  CookingApp
//
//  Created by  MAC on 5/26/20.
//

import Foundation
import UIKit

class TextFieldManager: NSObject, UITextFieldDelegate {
    static let shared = TextFieldManager()

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    var activeField: UITextField?
    var scrollView: UIScrollView?
    var view: UIView?

    func getScrollView(scrollView: UIScrollView) {
        self.scrollView = scrollView
    }

    func getActiveField(activeField: UITextField) {
        self.activeField = activeField
    }

    func getView(view: UIView) {
        self.view = view
    }

    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWasShown), name: UIResponder.keyboardDidShowNotification, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification) {
        guard let scrollView = scrollView else {return}
        guard let activeField = activeField else {return}
        guard let view = view else {return}
        scrollView.isScrollEnabled = true
        let info: NSDictionary = notification.userInfo! as NSDictionary
        guard let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size else {return}
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        var viewFrame: CGRect = view.frame
        viewFrame.size.height -= keyboardSize.height
        if !viewFrame.contains(activeField.frame.origin) {
            scrollView.scrollRectToVisible(activeField.frame, animated: true)
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }


   // private init() {}
}
