//
//  WeatherViewController.swift
//  Wather
//
//  Created by Pushpendra on 18/05/23.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    @IBOutlet private weak var weatherView: UIStackView!
    @IBOutlet private weak var lblFetchingData: UILabel!

    @IBOutlet private weak var conditionImage: UIImageView!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var conditionsLabel: UILabel!

    @IBOutlet private weak var windSpeed: UILabel!
    @IBOutlet private weak var humidity: UILabel!

    @IBOutlet private weak var riseLabel: UILabel!
    @IBOutlet private weak var setLabel: UILabel!

    let defaults = UserDefaults.standard
    var locationManager: UserLocationManager?

    var viewModel = WeatherViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setGradientColor(topColor: .blue, bottomColor: .gray)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupWeatherView(isShown: false)

        // Check user last user lat and lon for API call
        if let lat = defaults.object(forKey: "latitude") as? Double, let lon = defaults.object(forKey: "longitude") as? Double {
            viewModel.getWeatherData(lat: lat, lon: lon)
        } else {
            determineUserCurrentLocation()
        }
    }

    // Show data when get from API call
    private func setupWeatherView(isShown: Bool) {
        weatherView.isHidden = !isShown
        lblFetchingData.isHidden = isShown
    }

    // For current locaion
    private func determineUserCurrentLocation() {
        locationManager = UserLocationManager()
        locationManager?.delegate = self
        locationManager?.checkLocationAuthorization()
    }

    private func setGradientColor(topColor: UIColor, bottomColor: UIColor) {
        // Create a new gradient layer
        let gradientLayer = CAGradientLayer()
        // Set the colors and locations for the gradient layer
        gradientLayer.colors = [topColor.withAlphaComponent(0.05).cgColor, bottomColor.withAlphaComponent(0.05).cgColor]
        gradientLayer.locations = [0.0, 1.0]

        // Set the start and end points for the gradient layer
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        // Set the frame to the layer
        gradientLayer.frame = view.frame

        // Add the gradient layer as a sublayer to the background view
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    @IBAction func searchButtonTapped(_ sender: Any) {
        showSearchController()
    }

    private func showSearchController() {
        // Navigate to search screen
        let searchVC = SearchViewController.loadFromNib()
        searchVC.delegate = self
        navigationController?.pushViewController(searchVC, animated: false)
    }

    private func saveLatAndLon(lat: Double, lon: Double) {
        self.defaults.set(lat, forKey: "latitude")
        self.defaults.set(lon, forKey: "longitude")
    }
}

// MARK: - WeatherViewModelDelegate
extension WeatherViewController: WeatherViewModelDelegate {
    func didUpdateWeather(weather: WeatherModel) {
        setupWeatherView(isShown: true)

        self.temperatureLabel.text = weather.temperatureString
        self.windSpeed.text = weather.windSpeedString
        self.humidity.text = weather.humidityString
        self.conditionsLabel.text = weather.description
        self.cityLabel.text = weather.cityName
        self.riseLabel.text = weather.sunRiseString
        self.setLabel.text = weather.sunSetString
        if let icon = weather.icon {
            let iconId = Constants.weather_img_url + "\(icon)@2x.png"
            if let iconURL = URL(string: iconId) {
                self.conditionImage.load(url: iconURL)
            }
        }
    }

    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            self.present(AlertManager.createErrorAlert(title: "Error", error: error), animated: true)
        }
    }
}

// MARK: - SearchViewControllerDelegate
extension WeatherViewController: SearchViewControllerDelegate {
    func getSelectedCity(lat: Double, lon: Double) {
        // Save city lat and lon for next time
        saveLatAndLon(lat: lat, lon: lon)
    }
}

// Getting user curent location from User Location manager
extension WeatherViewController: UserLocationManagerDelegate {
    func getUserLocation(lat: Double, lon: Double) {
        saveLatAndLon(lat: lat, lon: lon)
        viewModel.getWeatherData(lat: lat, lon: lon)
    }

    func getLocationError(error: String) {
        DispatchQueue.main.async {
            self.present(AlertManager.createAlert(title: "Error", message: error), animated: true)
        }
    }
}
