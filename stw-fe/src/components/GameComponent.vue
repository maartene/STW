!<template>
    <h1>Earth</h1>
    <ul class="list-group">
        <li class="list-group-item">Year: {{gameData.currentYear}}</li>
        <li class="list-group-item">Temperature: {{gameData.currentTemperature}}</li>
    </ul>
    <p class="my-3"></p>
    <h1>{{gameData.countryName}}</h1>
    <ul class="list-group">
        <li class="list-group-item">Net GDP: {{gameData.netGDP}}</li>
        <li class="list-group-item">Yearly emissions: {{gameData.yearlyEmissions}}</li>
    </ul>
</template>

<script>
const axios = require('axios');


export default {
    name: "CountryComponent",
    data() {
        return {
            gameData: {
                netGDP: 0,
                yearlyEmissions: 0,
                currentYear: 0,
                currentTemperature: 0
            }
        }
    },
    props: {
        countryID: String
    },
    // Fetch game data when the component is created
    created() {
        axios.get(`http://localhost:8080/game/${this.countryID}/`)
        .then(response => {
            // JSON responses are automatically parsed.
            console.log(response.data);
            this.gameData = response.data;
        })
        .catch(e => {
            this.errors.push(e);
        })
    }
}
</script>

<style>

</style>