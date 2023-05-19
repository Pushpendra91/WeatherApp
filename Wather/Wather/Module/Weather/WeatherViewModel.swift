//
//  WeatherViewModel.swift
//  Wather
//
//  Created by Pushpendra on 18/05/23.
//

import Foundation
import Combine

// this protocol send weather data result or error to view controllet
protocol WeatherViewModelDelegate: AnyObject {
    func didUpdateWeather(weather: WeatherModel)
    func didFailWithError(error: Error)
}

class WeatherViewModel {
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: WeatherViewModelDelegate?

    // For getting weather data based on lat and lng
    func getWeatherData(lat: Double, lon: Double) {

        let weatherURL = Constants.base_url + WeatherAPI.weatherFor(lat: lat, long: lon).path + WeatherAPI.weatherFor(lat: lat, long: lon).queryParams

        CombineNetworkService.shared.getPublisherForResponse(request: weatherURL)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] compltion in
                guard let self = self else { return }
                switch compltion {
                case .failure(let error):
                    debugPrint("API errro \(error)")
                    self.delegate?.didFailWithError(error: error)

                case .finished:
                    debugPrint("Finished")
                }
            } receiveValue: { [weak self] (weatherData: WeatherData) in
                guard let self = self else { return }
                if let weatherInfo = self.getWeatherInfo(weatherData: weatherData) {
                    self.delegate?.didUpdateWeather(weather: weatherInfo)
                }
            }
            .store(in: &cancellables)
    }

    // Convert weather API data in representable model
    private func getWeatherInfo(weatherData: WeatherData) -> WeatherModel? {
        let weather = WeatherModel(sunRiseSeconds: TimeInterval(weatherData.sys.sunrise), sunSetSeconds: TimeInterval(weatherData.sys.sunset), description: weatherData.weather[0].description, cityName: weatherData.name, conditionID: weatherData
            .weather[0].id, icon: weatherData.weather[0].icon, temperature: weatherData.main.temp, humidity: weatherData.main.humidity, wind: weatherData.wind.speed)
        return weather
    }
}
