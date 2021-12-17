# STW
MongoDB+Dev hackathon entry: a game where we - dare I say it - Save The World!

## Project setup
The application consists of two parts:
* API backend: written in Swift using the Vapor framework;
* Web frontend: written in JavaScript using the Vue framework.

### Running the API backend
Note: you need a Swift toolchain installed.

#### Linux:
```
export DATABASE_URL="..."  // connection string to your MongoDB server.
cd stw-be
swift run
```

#### MacOS:
```
cd stw-be
open Package.swift
```

This opens XCode. Before running, please consider:
1. Setting a custom working directory to the stw-be folder (otherwise `Data/*.json` cannot be found)
2. Setting the environment variable `DATABASE_URL` to your MongoDB in the Run scheme environment variables.

Now you can run the server using Command-R.

#### Docker
Coming soon.

### Running the front-end
Coming soon.

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