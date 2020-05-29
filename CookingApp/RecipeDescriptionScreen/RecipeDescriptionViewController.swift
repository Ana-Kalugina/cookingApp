//
//  RecipeDescriptionViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/29/20.
//

import UIKit

class RecipeDescriptionViewController: UIViewController {
    
    var recipeName: String
    var recipeNameLabel = UILabel()
    var recipePhotoView = UIImageView()
    var recipePhoto: UIImage
    var recipeDescriptionLabel = UILabel()
    var recipeDescription: String
    var scrollView = UIScrollView()
    var stackView = UIStackView()
    var color = UIColor(named: "Color")
    
    init(recipeName: String, recipePhoto: UIImage, recipeDescription: String) {
        self.recipeName = recipeName
        self.recipePhoto = recipePhoto
        self.recipeDescription = recipeDescription
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addSubview(recipeNameLabel)
        stackView.addSubview(recipePhotoView)
        stackView.addSubview(recipeDescriptionLabel)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        recipeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        recipePhotoView.translatesAutoresizingMaskIntoConstraints = false
        recipeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        
        setUpViews()
        changeConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = color
        navigationItem.prompt = "   "
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animate()
        
    }
    
    func animate() {
        UIImageView.animate(withDuration: 1) { [weak self] in
            guard let self = self else {return}
            self.recipePhotoView.layer.cornerRadius = 60
            self.recipePhotoView.clipsToBounds = true
        }
    }
    
    func setUpViews() {
        recipeNameLabel.text = recipeName
        recipeNameLabel.textColor = .black
        recipeNameLabel.font = UIFont(name: "Palatino", size: 30)
        recipeNameLabel.numberOfLines = 0
        recipeNameLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        recipeNameLabel.textAlignment = .center
        recipePhotoView.image = recipePhoto
        recipeDescriptionLabel.text = recipeDescription
        recipeDescriptionLabel.textColor = .black
        recipeDescriptionLabel.font = UIFont(name: "Palatino", size: 20)
        recipeDescriptionLabel.numberOfLines = 0
        recipeDescriptionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        recipeDescriptionLabel.textAlignment = .justified
    }
    
    func changeConstraints() {
        stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                                           constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor,
                                            constant: 20).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide
            .topAnchor, constant: 20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: 0).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor,
                                         multiplier: 0.9).isActive = true
        recipeNameLabel.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        recipeNameLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        recipeNameLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        
        recipePhotoView.topAnchor.constraint(equalTo: recipeNameLabel.bottomAnchor, constant: 20).isActive = true
        recipePhotoView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        recipePhotoView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        
        recipeDescriptionLabel.topAnchor.constraint(equalTo: recipePhotoView.bottomAnchor, constant: 20).isActive = true
        recipeDescriptionLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        recipeDescriptionLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        recipeDescriptionLabel.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
    }
}
