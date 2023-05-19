//
//  Constants.swift
//  Wather
//
//  Created by Pushpendra on 19/05/23.
//

import Foundation

struct Constants{

    //API and Key Variables
    static let weather_api_key = "5052a10d9a282cc28a1adbec8b98da15"
    static let base_url = "https://api.openweathermap.org/"
    static let weather_img_url = "http://openweathermap.org/img/wn/"
}

enum WeatherAPI {
    case seachText(text: String)
    case weatherFor(lat: Double, long: Double)

    var path: String {
        switch self {
        case .seachText:
            return "geo/1.0/direct?"
        case .weatherFor:
            return "data/2.5/weather?"
        }
    }

    var method: String {
        switch self {
        case .seachText, .weatherFor:
            return "Get"
        }
    }

    var queryParams: String {
        switch self {
        case let .weatherFor(lat, long):
            let payload = [
                "lat": "\(lat)",
                "lon": "\(long)",
                "appid": Constants.weather_api_key
            ]
            return payload.queryString
    
        case let .seachText(locationText):
            let payload = [
                "q": locationText.replacingOccurrences(of: " ", with: ""),
                "limit": "9",
                "appid": Constants.weather_api_key
            ]
            return payload.queryString
        }
    }
}

extension Dictionary {
    var queryString: String {
        var output: String = ""
        forEach({ output += "\($0.key)=\($0.value)&" })
        output = String(output.dropLast())
        return output
    }
}
