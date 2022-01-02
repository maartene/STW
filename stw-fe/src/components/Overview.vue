<template>
    <div class="row">
        <div class="col">
            <div class="card border-primary mb-3">
                <div class="card-header">Earth</div>
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
                <div class="card-header">{{gameData.countryName}}</div>
                <div class="card-body">
                    <ul class="list-group">
                        <li class="list-group-item">Net GDP: {{gameData.netGDP.toFixed(0)}} * 1000USD</li>
                        <li class="list-group-item">Budget surpluss: {{gameData.budgetSurplus.toFixed(0)}} %GDP (Ranking: {{gameData.budgetSurplusRating}})</li>
                        <li class="list-group-item">Yearly emissions: {{gameData.yearlyEmissions.toPrecision(4)}} Giga Tonnes</li>
                        <li class="list-group-item">Population: {{gameData.population}}</li>
                        <li class="list-group-item">Country points: {{gameData.countryPoints}} (+ {{gameData.countryPointsPerTick}})</li>
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
    <p>{{gameData.earthEffectsDescription}}</p>
    <h5>Messages</h5>
    <ul class="list-group">
        <li class="list-group-item" v-for="message in gameData.messages" :key="message">{{message}}</li>
    </ul>
</template>

<script>
export default {
    name: "Overview",
    props: {
        gameData: {
            messages: []
        }
    }
}
</script>

<style>

</style>