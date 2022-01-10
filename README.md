# STW
MongoDB+Dev hackathon entry: a game where we - dare I say it - Save The World!

## You can play a live build at [https://www.letssavetheworld.club](https://www.letssavetheworld.club)

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
# export STW_BACKEND_DB_URL="..."  // connection string to your MongoDB server.
# cd stw-be
# swift run
```

#### MacOS:
```
% cd stw-be
% open Package.swift
```

This opens XCode. Before running, please consider:
* Setting a custom working directory to the stw-be folder (otherwise `Data/*.json` cannot be found)
* You need to set the `STW_BACKEND_DB_URL` environment variable to the MongoDB commection string in the Run scheme settings. 

Now you can run the server using Command-R.

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
* `GET /earthModels/` : lists all `EarthModels`. For debugging/testing purposes only
* `GET /earthModels/[earthModel UUID]` : retrieves a specific `EarthModel` by it's ID (UUID)
* `GET /countryModels/` : lists all CountryModels. For debugging/testing purposes only
* `GET /countryModels/[countryModel UUID]` : retrieves a specific `CountryModel` by it's ID (UUID)
* `POST /players/` : creates a new player and assigns a random country.
* `POST /players/login` : tries to log in using basic authentication and retrieves a bearer token.

The following endpoints are protected by bearer token authentication:
* `GET /game/country/` : retrieves all relevant data to display in the game.
* `GET /game/country/commands` : retrieves all commands the country can execute (at this time).
* `POST /game/country/` : sends a command to execute. Returns a message (string) indicating what happened.
* `GET /game/country/policies` : retrieves all policies the country can envoke (at this time) and has active.
* `GET /game/country/policies/all` : retrieves all policies known in the game.
* `POST /game/country/policies` : sends a policy to enact (in the payload of the request as JSON). Returns a message (string) indicating what happened.
* `POST /game/country/policies/revoke` : sends a policy to revoke (in the payload of the request as JSON). Returns a message (string) indicating what happened.
* `POST /game/country/policies/levelup` : sends a policy to levelup (in the payload of the request as JSON). Returns a message (string) indicating what happened.
* `GET game/country/forecast/` : retrieves forecasted versions of the current earth and country in JSON format. 
* `GET game/country/claim/` : retrieves a list of (max) 20 random unclaimed countries, for the player to select from.
* `POST game/country/claim/` : pass an unclaimed country to link it to the player.
* `GET game/country/diplomacy/` : retrieve the suggestions associated with your country.
* `GET game/country/diplomacy/options` : retrieves the suggestions this country can make to other countries to commit to enact a policy.
* `POST game/country/diplomacy/` : suggest a diplomacy option to another country.
* `POST game/country/diplomacy/:suggestionID/accept` : accept the suggestion with id `suggestionID` if you are the target of the suggestion.
* `POST game/country/diplomacy/:suggestionID/refuse` : refuse the suggestion with id `suggestionID` if you are the target of the suggestion.
* `POST game/country/diplomacy/:suggestionID/revoke` : revoke the suggestion with id `suggestionID` if you own the suggestion.

## Playing the game
### Basics
* Start out by registering an account on the front page. Then login.
* As a new player, you will get a list of countries that are available to claim. Claim one (note: you can't change later).
* Interact with your country by enacting, revoking and improving (level up) policies. The effects of the various policies are shown both on the 'Policies' tab, as well as in the 'Forecast' tab (to see their effect over time).
* Enacting and leveling up policies requires 'Country Points'. Your Country receives country points at each update, which happens every real world hour. You can see how many you receive during the next update in the 'Overview' tab.
* The Earth updates every day at 12:00. During this update all the emissions of all countries are tallied and affect how much warmer (or cooler!) the Earth gets.

### Advanced
#### Diplomacy
* You can suggest to other countries to enact a policy together. This has the added benefit that you receive extra country point for each policy you enacted together;
* However, enacting a policy is a long term commitment: you can't revoke policies from accepted suggestions;
* You can both send and receive suggestions. But you can only send out at most 3 suggestions;
* _More diplomacy options to come._

#### Commands
_Coming soon._

### Hints
* Try claming a country with a large carbon emission first, to have more impact on the world as a whole;
* The policies available to your country depend on the ranking of your country on various aspects: wealth/GDP (per capita), current yearly emissions, education level, budget surpluss and equality. Try improving your ranking if you don't find the policies you need;
* All policies improve certain aspects of your countries, but most also have drawbacks. Balance is key;
* More impactful policies as well as leveling up gets progressively more expensive. Country points become more important as time goes on.
* Setting an emission target is a good start.

## Copyright & License
(c) 2021, 2022 Maarten Engels, thedreamweb.eu
Apache 2.0 license.

### Known issues
* As of December 17, 2021. The Xcode 13.2 version from the App Store has a bug in it that prevents it from working with Swift Package Manager projects. The version you download directly from Apples website works though.  

### Licensed assets:
* vue.js framework (https://v3.vuejs.org) and vuex (https://next.vuex.vuejs.org)
* Vapor framework (https://vapor.codes)
* Bootstrap (https://getbootstrap.com)
* Various data sources. These are defined in the source code.
