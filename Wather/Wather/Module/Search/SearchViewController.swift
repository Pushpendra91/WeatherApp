//
//  SearchVC.swift
//  Weather
//
//  Created by Pushpendra on on 19/05/23.
//

import UIKit

// For sending city lat lon for searching weather  data
protocol SearchViewControllerDelegate: AnyObject {
    func getSelectedCity(lat: Double, lon: Double)
}

class SearchViewController: UIViewController {
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var searchTableView: UITableView!

    weak var delegate: SearchViewControllerDelegate?
    
    var viewModel = SearchViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.title = "Search"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        setupTableView()
    }
    
    private func setupTableView() {
        searchTableView.register(UINib(nibName: "SearchListTVC", bundle: nil), forCellReuseIdentifier: "SearchListTVC")

        searchTableView.delegate = self
        searchTableView.dataSource = self

        searchTableView.backgroundView?.isUserInteractionEnabled = true

        viewModel.reloadUI = { [weak self] in
            DispatchQueue.main.async {
                self?.searchTableView.reloadData()
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.performSearch(text: searchText)
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchTableView.deselectRow(at: indexPath, animated: true)
        if let searchData = viewModel.searchResultList?[indexPath.row] {
            delegate?.getSelectedCity(lat: searchData.lat ?? 0.0, lon: searchData.lon ?? 0.0)
        }
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchResultList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SearchListTVC") as? SearchListTVC {
            if let location = viewModel.searchResultList?[indexPath.row] {
                cell.configure(for: location)
            }
            return cell
        }

        return UITableViewCell()
    }
}
