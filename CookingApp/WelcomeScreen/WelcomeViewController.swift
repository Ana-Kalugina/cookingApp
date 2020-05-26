//
//  WelcomeViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/24/20.
//

import UIKit

// swiftlint:disable force_cast

class WelcomeViewController: UIViewController, UIScrollViewDelegate {

    var slides: [Slide] = []

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    var skipSegueID = "skipSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self

        slides = createSlides()
        setupSlideScrollView(slides: slides)

        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0

        view.bringSubviewToFront(pageControl)
    }

    func createSlides() -> [Slide] {

        let slide1: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide1.welcomeImageView.image = UIImage(named: "food1")
        slide1.welcomeLabel.text = "Welcome to RecipesApp"
        slide1.welcomeLabel.font = UIFont(name: "Palatino", size: 20)

        let slide2: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide2.welcomeImageView.image = UIImage(named: "fish")
        slide2.welcomeLabel.text = "Create your own recipes and master cooking with chefs"
        slide2.welcomeLabel.font = UIFont(name: "Palatino", size: 20)

        let slide3: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide3.welcomeImageView.image = UIImage(named: "steak")
        slide3.welcomeLabel.text = "Follow your friends and favourite bloggers"
        slide3.welcomeLabel.font = UIFont(name: "Palatino", size: 20)

        let slide4: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide4.welcomeImageView.image = UIImage(named: "pizza")
        slide4.welcomeLabel.text = "Enjoy watching videos"
        slide4.welcomeLabel.font = UIFont(name: "Palatino", size: 20)

        return [slide1, slide2, slide3, slide4]
    }

    func setupSlideScrollView(slides: [Slide]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 1.0)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: 1.0)
        scrollView.isPagingEnabled = true

        for item in 0 ..< slides.count {
            slides[item].frame = CGRect(x: view.frame.width * CGFloat(item), y: 0, width: view.frame.width, height: 1.0)
            scrollView.addSubview(slides[item])
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupSlideScrollView(slides: slides)
    }

}
