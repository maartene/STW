<template>
    <div class="row">
        <div class="col">
            <div class="card border-primary mb-3">
                <div class="card-header">Earth
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-info-circle-fill text-info" viewBox="0 0 16 16"
                        data-bs-toggle="tooltip" data-bs-html="true" data-bs-placement="bottom" 
                        title="Earth updates every 24 hours (at 12:00 UTC).">
                        <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm.93-9.412-1 4.705c-.07.34.029.533.304.533.194 0 .487-.07.686-.246l-.088.416c-.287.346-.92.598-1.465.598-.703 0-1.002-.422-.808-1.319l.738-3.468c.064-.293.006-.399-.287-.47l-.451-.081.082-.381 2.29-.287zM8 5.5a1 1 0 1 1 0-2 1 1 0 0 1 0 2z"/>
                    </svg>
                </div>
                <div class="card-body">
                    <ul class="list-group">
                        <li class="list-group-item">Year: {{gameData.currentYear}}</li>
                        <li class="list-group-item">Temperature: {{gameData.currentTemperature}}</li>
                    </ul>
                </div>
            </div>  
        </div>
        <div class="col">
            <div class="card border-primary mb-3">
                <div class="card-header">{{gameData.countryName}} 
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-info-circle-fill text-info" viewBox="0 0 16 16"
                        data-bs-toggle="tooltip" data-bs-html="true" data-bs-placement="bottom" 
                        title="Country updates every hour.">
                        <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm.93-9.412-1 4.705c-.07.34.029.533.304.533.194 0 .487-.07.686-.246l-.088.416c-.287.346-.92.598-1.465.598-.703 0-1.002-.422-.808-1.319l.738-3.468c.064-.293.006-.399-.287-.47l-.451-.081.082-.381 2.29-.287zM8 5.5a1 1 0 1 1 0-2 1 1 0 0 1 0 2z"/>
                    </svg></div>
                <div class="card-body">
                    <ul class="list-group">
                        <li class="list-group-item">Net GDP: {{gameData.netGDP.toFixed(0)}} * 1000USD</li>
                        <li class="list-group-item">Budget surpluss: {{gameData.budgetSurplus.toFixed(0)}} %GDP (Ranking: {{gameData.budgetSurplusRating}})</li>
                        <li class="list-group-item">Yearly emissions: {{gameData.yearlyEmissions.toPrecision(4)}} Giga Tonnes</li>
                        <li class="list-group-item">Population: {{gameData.population}}</li>
                        <li class="list-group-item">Country points: {{gameData.countryPoints}} (+ {{gameData.countryPointsPerTick}} per update)</li>
                    </ul>
                </div>
            </div>                    
        </div>
        <div class="col">
            <div class="card border-primary mb-3">
                <div class="card-header">Per capita</div>
                <div class="card-body">
                    <ul class="list-group">
                        <li class="list-group-item">Net GDP: {{(1000 * gameData.netGDP / gameData.population).toFixed(0)}} USD (Ranking: {{gameData.wealthRating}})</li>
                        <li class="list-group-item">Yearly emissions: {{(1000000000 * gameData.yearlyEmissions / gameData.population).toPrecision(4)}} tonnes (Ranking: {{gameData.emissionPerCapitaRating}})</li>
                        <li class="list-group-item">Inequality: {{gameData.giniRating.toFixed(1)}} (Ranking: {{gameData.giniRatingRating}})</li>
                        <li class="list-group-item">Education index: {{gameData.educationDevelopmentIndex.toFixed(3)}} (Ranking: {{gameData.educationDevelopmentIndexRating}})</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <h5>Current effects of global warming</h5>
    <p class="text-danger">{{gameData.earthEffectsDescription}}</p>
    <h5>Messages from around the Earth</h5>
    <ul class="list-group">
        <li class="list-group-item" v-for="message in gameData.messages" :key="message">{{message}}</li>
    </ul>
</template>

<script>
const bootstrap = require('bootstrap');

export default {
    name: "Overview",
    props: {
        gameData: {
            messages: [""]
        }
    }, 
    created() {
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
                    //var tooltipList = 
        tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl)
        })
                    //console.log(tooltipList.length)
    }
    
}
</script>

<style>

</style>