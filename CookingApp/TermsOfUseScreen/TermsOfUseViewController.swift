//
//  TermsOfUseViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/24/20.
//

import UIKit

class TermsOfUseViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var termsOfUseLabel: UILabel!
    var termsOfUseText: String?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var skipTermsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        termsOfUseText = prepareTermsOfUseText()
        termsOfUseLabel.text = termsOfUseText
        termsOfUseLabel.font = UIFont(name: "Palatino", size: 20)
        scrollView.bringSubviewToFront(skipTermsButton)
        scrollView.delegate = self

    }

    func prepareTermsOfUseText() -> String {
        var termsOfUse = ""
        guard let path = Bundle.main.path(forResource: "TermsOfUse", ofType: "txt") else {return termsOfUse}
        var wholeText: String = ""
        do {
            wholeText = try String(contentsOfFile: path)
        } catch {}
        termsOfUse = wholeText
        return termsOfUse
    }

    @IBAction func scrollToBottomPressed(_ sender: Any) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: true)

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.panGestureRecognizer.translation(in: scrollView).y > 0 {
            // down
            skipTermsButton.isHidden = false
        } else {
            // up
            skipTermsButton.isHidden = true
        }
    }


}
