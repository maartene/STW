# STW
MongoDB+Dev hackathon entry: a game where we - dare I say it - Save The World!

## Project setup
The application consists of two parts:
* API backend: written in Swift using the Vapor framework;
* Web frontend: written in JavaScript using the Vue framework.

### Running the API backend
#### Pre-requisites
* You need the Swift toolchain. If you are on macOS, just make sure you have the latest version of Xcode installed. On Linux, you can download Swift from swift.org.
* You need a MongoDB, either local or on a cloud service like Mongo Atlas. Mongo Atlas has a free tier that works quite well for (testing) this project.
* Setting the environment variable `STW_BACKEND_DB_URL` to your MongoDB connection string.
* By default, the API backend listens on port 8000. If you want to change this, you can do so by setting the environment variable: `STW_BACKEND_PORT`.

#### Linux:
```
export STW_BACKEND_DB_URL="..."  // connection string to your MongoDB server.
cd stw-be
swift run
```

#### MacOS:
```
cd stw-be
open Package.swift
```

This opens XCode. Before running, please consider:
* Setting a custom working directory to the stw-be folder (otherwise `Data/*.json` cannot be found)

Now you can run the server using Command-R.

#### Docker
Coming soon.

### Running the front-end
To run the front-end locally, you need `node.js` and `npm` installed.
```
# cd stw-fe
# npm install
# npm run serve
```
* By default, the front-end server listens on port 8080. If you want to change the port, change environment variable `PORT`.
* Set the hostname and port where the backend API is running using environment variable `VUE_APP_STW_API_URL` (default: `http://localhost:8000`). 

## API endpoints
* `/earthModels/` : lists all `EarthModels`. For debugging/testing purposes only
* `/earthModels/[earthModel UUID]` : retrieves a specific `EarthModel` by it's ID (UUID)
* `/countryModels/` : lists all CountryModels. For debugging/testing purposes only
* `/countryModels/[countryModel UUID]` : retrieves a specific `CountryModel` by it's ID (UUID)
* `/game/[countryModel UUID]` : retrieves all relevant data to display in the game.

## Playing the game
Coming soon.

## Copyright & License
(c) 2021 Maarten Engels, thedreamweb.eu
Apache 2.0 license.

### Known issues
* As of December 17, 2021. The Xcode 13.2 version from the App Store has a bug in it that prevents it from working with Swift Package Manager projects. The version you download directly from Apples website works though.  

### Licensed assets:
* vue.js framework (https://v3.vuejs.org)
* Vapor framework (https://vapor.codes)
* Bootstrap (https://getbootstrap.com)
