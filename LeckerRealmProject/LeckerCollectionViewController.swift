//
//  LeckerCollectionViewController.swift
//  LeckerRealmProject
//
//  Created by Emre Tekin on 16.06.2023.
//

import UIKit
import RealmSwift
import StoreKit

typealias DataSource = UICollectionViewDiffableDataSource<Section, RealFlower>
typealias Snapshot = NSDiffableDataSourceSnapshot<Section, RealFlower>

enum Section {
    case main
}


class LeckerCollectionViewController: UICollectionViewController {

    private lazy var dataSource = makeDataSource()
    
    private var flowerList = [RealFlower]()
    private var filteredFlowerList = [RealFlower]()
    private var searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let realm = try Realm()
            let savedData = realm.objects(RealFlower.self)
            for saveData in savedData {
                print(saveData)
            }
        } catch {
            print("Veritabanına erişim sağlanamadı: \(error)")
        }
        flowerList = DatabaseHelper.shared.getAllFlowers()
        applySnapshot()
        configureLayout()
        configureSearchController()
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped)), UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareWithFriends))]
        navigationItem.leftBarButtonItems = [UIBarButtonItem(title: "Rate Us1", style: .plain, target: self, action: #selector(rateApp)),UIBarButtonItem(title: "Rate Us2", style: .plain, target: self, action: #selector(rateUs))
        ]
        
        
    }
    
    @objc func rateUs() {
        showAppStoreRatingPopup()
    }
    
    @objc func rateApp() {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/id6446604137?mt=8&action=write-review") else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
                                            
                                             
    @objc func shareWithFriends() {
        let appStoreLink = "itms-apps://itunes.apple.com/app/id6446604137?mt=8&action=write-review"
        let items = [URL(string: appStoreLink)!]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        applySnapshot()
    }
    
    
    func showAppStoreRatingPopup() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    
    @objc func addButtonTapped() {
        performSegue(withIdentifier: "toAddVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddVC" {
            if let addVC = segue.destination as? AddLeckerViewController {
                addVC.delegate = self
            }
        }
    }
    
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, flower -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LeckerCell", for: indexPath) as? LeckerCollectionViewCell
            
            cell?.configure(with: flower)
            
            return cell
        }
        return dataSource
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        let filteredFlowers = filteredFlowers(for: searchController.searchBar.text)
        snapshot.appendItems(filteredFlowers)

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFlower = flowerList[indexPath.row]
        flowerList.remove(at: indexPath.row)
        DatabaseHelper.shared.deleteFlowers(rFlowers: selectedFlower)
        
        applySnapshot()
    }
    
}


extension LeckerCollectionViewController {
    private func configureLayout() {
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.3)), subitem:item, count: 2)
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
    
    
}

extension LeckerCollectionViewController: AddLeckerViewControllerDelegate {
    func didAddNewFlower() {
        flowerList = DatabaseHelper.shared.getAllFlowers()
        applySnapshot()
    }
    
    
}

extension LeckerCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredFlowerList = filteredFlowers(for: searchController.searchBar.text)
        applySnapshot()
    }
    
    func filteredFlowers(for queryOrNil: String?) -> [RealFlower] {
        guard let query = queryOrNil, !query.isEmpty else {
            return flowerList
        }
        
        return flowerList.filter { $0.firstName.localizedCaseInsensitiveContains(query) }
    }
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Flower"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}
