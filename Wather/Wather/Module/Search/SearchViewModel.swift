//
//  SearchVM.swift
//  Weather
//
//  Created by Pushpendra on on 19/05/23.
//

import Foundation
import Combine

class SearchViewModel {
    private var cancellables = Set<AnyCancellable>()

    var searchResultList: [SearchResultModel]?

    var reloadUI: () -> Void = { }
    var requests: [Cancellable]?
    var isLoading: Bool = false {
        didSet {
            self.reloadUI()
        }
    }

    func performSearch(text: String) {
        guard !text.isEmpty else {
            self.searchResultList?.removeAll()
            self.reloadUI()
            return
        }
        isLoading = true

        let cityURL = Constants.base_url + WeatherAPI.seachText(text: text).path + WeatherAPI.seachText(text: text).queryParams

        CombineNetworkService.shared.getPublisherForResponse(request: cityURL)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] compltion in
                guard let self = self else { return }
                switch compltion {
                case .failure(let error):
                    debugPrint("API errro \(error)")
                    self.isLoading = false

                case .finished:
                    debugPrint("Finished")
                }
            } receiveValue: { [weak self] (searchData: [SearchResultModel]) in
                guard let self = self else { return }
                self.searchResultList = searchData.filter { $0.country == "US" }
                self.isLoading = false
            }
            .store(in: &cancellables)
    }
}
