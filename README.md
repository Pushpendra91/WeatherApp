# WeatherApp
This is a weather app written in Swift. You can see the weather for your current location on the home screen. You can also search for a city from the Search page. The app is working only for US cities.

- I used Combine for the API calls. Network Manager using publishers to return API response to view model.
- You will also see good use of protocol as delegate to return desired response from view model or manager.
- You can find UserLocationManager class which helps to get user current location. We can also use this class to display the current location of the user in any project.
- XIB is also using for search view controller.
