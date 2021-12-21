!<template>
    <div class="alert alert-primary d-flex align-items-center alert-dismissible fade show" role="alert" v-if="message != ''">
        <img src="/img/bootstrap-icons/check-circle.svg" alt="Check circle">&nbsp;&nbsp;
        <div>
            {{message}}
            <button type="button" class="btn-close" v-on:click="message = ''" aria-label="Close"></button>
        </div>
    </div>
    <p class="my-3"></p>
    
    
    <div class="row">
        <div class="col">
            <h1>Earth</h1>
            <ul class="list-group">
                <li class="list-group-item">Year: {{gameData.currentYear}}</li>
                <li class="list-group-item">Temperature: {{gameData.currentTemperature}}</li>
            </ul>
        </div>
        <div class="col">
            <h1>{{gameData.countryName}}</h1>
            <ul class="list-group">
                <li class="list-group-item">Net GDP: {{gameData.netGDP}} * 1000USD</li>
                <li class="list-group-item">Yearly emissions: {{gameData.yearlyEmissions.toPrecision(4)}} Giga Tonnes</li>
                <li class="list-group-item">Population: {{gameData.population}}</li>
                <li class="list-group-item">Country points: {{gameData.countryPoints}} (+ {{gameData.countryPointsPerTick}})</li>
            </ul>
        </div>
        <div class="col">
            <h1>Per capita</h1>
            <ul class="list-group">
                <li class="list-group-item">Net GDP: {{(1000 * gameData.netGDP / gameData.population).toFixed(0)}} USD</li>
                <li class="list-group-item">Yearly emissions: {{(1000000000 * gameData.yearlyEmissions / gameData.population).toPrecision(4)}} tonnes</li>
            </ul>
        </div> 
        <div class="col">
            <h1>Forecast</h1>
            <ul class="list-group">
                <li class="list-group-item">Net GDP: {{gameData.forecastNetGDP}} * 1000USD</li>
                <li class="list-group-item">Yearly emissions: {{gameData.forecastYearlyEmissions.toPrecision(4)}} Giga Tonnes</li>
                <li class="list-group-item">Population: {{gameData.forecastPopulation}}</li>
            </ul>
        </div>
    </div>

    <p class="my-3"></p>
    
    
    <p class="my-3"></p>
        <ActivePolicies v-bind:activePolicies="policies.activePolicies" @revokePolicy="revokePolicy" @levelUpPolicy="levelUpPolicy"></ActivePolicies>
    <p class="my-3"></p>
        <InactivePolicies v-bind:inactivePolicies="policies.availablePolicies" @enactPolicy="enactPolicy"></InactivePolicies>    
    <p class="my-3"></p>
    <Commands v-bind:commands="commands" @executeCommand="executeCommand"></Commands>
    <p class="my-3"></p>
    <button class="btn btn-primary" v-on:click="refresh">Refresh</button>
</template>

<script>
const axios = require('axios');

import ActivePolicies from './ActivePolicies.vue';
import InactivePolicies from './InactivePolicies.vue';
import Commands from './Commands.vue';

export default {
    name: "CountryComponent",
    components: {
        ActivePolicies,
        InactivePolicies,
        Commands
    },
    emits: [
        "revokePolicy",
        "enactPolicy",
        "levelUpPolicy",
        "executeCommand"
    ],
    data() {
        return {
            gameData: {
                netGDP: 0,
                yearlyEmissions: 0,
                currentYear: 0,
                currentTemperature: 0,
                population: 0,
                forecastNetGDP: 0,
                forecastYearlyEmissions: 0,
                forecastPopulation: 0
            },
            commands: [
                {
                    command: {
                        name: ""
                    },
                    "effectDescription": { }
                }
            ],
            policies: {
                activePolicies: [
                    {
                        "policy": {
                            name: "",
                            baseCost: 0,
                        },
                        "effectDescription": "",
                        "upgradeCost": 0
                    }
                ],
                availablePolicies: [
                    {
                        "policy": {
                            name: "",
                            baseCost: 0,
                        },
                        "effectDescription": "",
                        "upgradeCost": 0
                    }
                ]
            },
            message: ""
        }
    },
    props: {
        countryID: String
    },
    methods: {
        refresh() {
            axios.get(`${this.STW_API_ENDPOINT}/game/${this.countryID}/`)
            .then(response => {
                // JSON responses are automatically parsed.
                console.log(response.data);
                this.gameData = response.data;
            })
            .catch(e => {
                this.errors.push(e);
            })

            axios.get(`${this.STW_API_ENDPOINT}/game/${this.countryID}/policies/`)
            .then(response => {
                // JSON responses are automatically parsed.
                console.log(response.data);
                this.policies = response.data;
            })
            .catch(e => {
                this.errors.push(e);
            })

            axios.get(`${this.STW_API_ENDPOINT}/game/${this.countryID}/commands/`)
            .then(response => {
                // JSON responses are automatically parsed.
                console.log(response.data);
                this.commands = response.data;
            })
            .catch(e => {
                this.errors.push(e);
            })
        },

        executeCommand(command) {
            console.log(`Attempting to send command: ${command.command}`);
            axios.post(`${this.STW_API_ENDPOINT}/game/${this.countryID}/`, command.command)
            .then(response => {
                // JSON responses are automatically parsed.
                console.log(response.data);
                this.message = response.data;

                this.refresh();
            })
            .catch( e => {
                this.errors.push(e);
            })
        },

        enactPolicy(policy) {
            console.log(`Attempting to send command: ${policy.policy}`);
            axios.post(`${this.STW_API_ENDPOINT}/game/${this.countryID}/policies`, policy.policy)
            .then(response => {
                // JSON responses are automatically parsed.
                console.log(response.data);
                this.message = response.data;

                this.refresh();
            })
            .catch( e => {
                this.errors.push(e);
            })
        },

        revokePolicy(policy) {
            console.log(`Attempting to send command: ${policy.policy}`);
            axios.post(`${this.STW_API_ENDPOINT}/game/${this.countryID}/policies/revoke`, policy.policy)
            .then(response => {
                // JSON responses are automatically parsed.
                console.log(response.data);
                this.message = response.data;

                this.refresh();
            })
            .catch( e => {
                this.errors.push(e);
            })
        },

        levelUpPolicy(policy) {
            console.log(`Attempt to level up policy: ${policy.policy.name}`);
            axios.post(`${this.STW_API_ENDPOINT}/game/${this.countryID}/policies/levelup`, policy.policy)
            .then(response => {
                // JSON responses are automatically parsed.
                console.log(response.data);
                this.message = response.data;

                this.refresh();
            })
            .catch( e => {
                this.errors.push(e);
            })
        }
    },
    // Fetch game data when the component is created
    created() {
        this.refresh();
    }
}
</script>

<style>

</style>