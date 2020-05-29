//
//  SearchViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/29/20.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var mainIngredientName = ["Pasta", "Pizza", "Meat", "Fish", "Vegetables", "Sweets", "Eggs", "Soups", "Drinks", "Fruits"]
    var mainIngredientImages = [UIImage(named: "pasta"), UIImage(named: "pizza-1"), UIImage(named: "meat"), UIImage(named: "fish-1"), UIImage(named: "vegetable"), UIImage(named: "sweet"), UIImage(named: "eggs"), UIImage(named: "soup"), UIImage(named: "drink"), UIImage(named: "fruit")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        searchBar.returnKeyType = UIReturnKeyType.done
        
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("ha")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //
    }
    
    
    
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainIngredientName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "search", for: indexPath) as? SearchCollectionViewCell else {fatalError("There is no such cellID or Class")}
        cell.recipeCategoryImg.image = mainIngredientImages[indexPath.row]
        cell.recipeCategoryName.text = mainIngredientName[indexPath.row]
        cell.layer.cornerRadius = 20
        cell.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        return cell
    }
    
}
