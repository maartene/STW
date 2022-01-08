!<template>
    <div class="alert alert-primary d-flex align-items-center alert-dismissible fade show" role="alert" v-if="message != ''">
        <img src="/img/bootstrap-icons/check-circle.svg" alt="Check circle">&nbsp;&nbsp;
        <div>
            {{message}}
            <button type="button" class="btn-close" v-on:click="message = ''" aria-label="Close"></button>
        </div>
    </div>
    <div class="alert alert-warning d-flex align-items-center alert-dismissible fade show" role="alert" v-if="warningMessage != ''">
        <img src="/img/bootstrap-icons/exclamation-circle.svg" alt="Exclamation circle">&nbsp;&nbsp;
        <div>
            {{warningMessage}}
            <button type="button" class="btn-close" v-on:click="warningMessage = ''" aria-label="Close"></button>
        </div>
    </div>
    <div v-if="shouldClaimCountry">
        <ClaimCountry v-bind:token="token" @countryClaimed="countryClaimed"/>
    </div>
    <div class="border" v-else>
    
        <div class="m-3">
            <h1>
                {{isoCountryCodeToFlagEmoji(gameData.countryCode)}} {{gameData.countryName}} 
                <button class="btn btn-primary btn-sm"  v-on:click="refresh">Refresh</button>
            </h1>
        </div>
        <TabWrapper>
        <Tab title="Overview">
            <Overview v-bind:gameData="gameData" />
        </Tab>
        <Tab title="Policies">
            <p class="my-3"></p>
                <ActivePolicies v-bind:activePolicies="policies.activePolicies" @revokePolicy="revokePolicy" @levelUpPolicy="levelUpPolicy"></ActivePolicies>
            <p class="my-3"></p>
            <InactivePolicies v-bind:inactivePolicies="policies.availablePolicies" @enactPolicy="enactPolicy"></InactivePolicies>    
        </Tab>
        <Tab title="Commands"><Commands v-bind:commands="commands" @executeCommand="executeCommand"></Commands></Tab>
        <Tab title="Forecast"><Forecast v-bind:token="token"></Forecast></Tab>
        </TabWrapper>
    </div>
</template>

<script>
const axios = require('axios');

import TabWrapper from './TabWrapper.vue'
import Tab from './Tab.vue'

import ActivePolicies from './ActivePolicies.vue';
import InactivePolicies from './InactivePolicies.vue';
import Commands from './Commands.vue';
import Forecast from './Forecast.vue';
import Overview from './Overview.vue';
import ClaimCountry from './ClaimCountry.vue'


export default {
    name: "CountryComponent",
    components: {
        TabWrapper,
        Tab,

        ActivePolicies,
        InactivePolicies,
        Commands,
        Forecast,
        Overview,

        ClaimCountry

    },
    emits: [
        "revokePolicy",
        "enactPolicy",
        "levelUpPolicy",
        "executeCommand",
        "countryClaimed"
    ],
    data() {
        return {
            gameData: {
                netGDP: 0,
                earthID: "",
                countryCode: "nl",
                yearlyEmissions: 0,
                currentYear: 0,
                currentTemperature: 0,
                population: 0,
                forecastNetGDP: 0,
                forecastYearlyEmissions: 0,
                forecastPopulation: 0,
                emissionPerCapitaRating: "",
                wealthRating: "",   
                giniRating: 0,
                giniRatingRating: "",
                educationDevelopmentIndexRating: "",
                educationDevelopmentIndex: 0,
                budgetSurplus: 0,
                budgetSurplusRating: "",
                earthEffectsDescription: "",
                messages: [
                    {
                        id: "",
                        message: ""
                    }
                ]
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
                        "upgradeCost": 0,
                        "conditionDescription": ""
                    }
                ]
            },
            message: "",
            warningMessage: "",
            shouldClaimCountry: false
        }
    },
    props: {
        token: String
    },
    methods: {
        hasCountry() {
            axios.get(`${this.STW_API_ENDPOINT}/game/country/hasCountry`, {
                headers: {
                    "Authorization": `bearer ${this.token}`
                }
            })
            .then(response => {
                if (response.data == true) {
                    this.refresh();
                } else {
                    this.shouldClaimCountry = true;
                }
            })
            .catch(e => {
                //console.log(e);
                this.warningMessage = `An error occured while determining if player already has a country: ${e}`
                //this.errors.push(e);
            })  
        },
        refresh() {
            axios.get(`${this.STW_API_ENDPOINT}/game/country/`, {
                headers: {
                    "Authorization": `bearer ${this.token}`
                }
            })
            .then(response => {
                // JSON responses are automatically parsed.
                console.log(response.data);
                this.gameData = response.data;

                axios.get(`${this.STW_API_ENDPOINT}/logs/${this.gameData.earthID}/`)
                .then(response => {
                    // JSON responses are automatically parsed.
                    //console.log(response.data)
                    this.gameData.messages = response.data;
                    this.shouldClaimCountry = false;
                })
                .catch(e => {
                    this.warningMessage = `An error occured while retrieving Earth logs: ${e}`
                    //this.errors.push(e);
                })
            })
            .catch(e => {
                this.warningMessage = `An error occured while retrieving game data: ${e}`
                //this.errors.push(e);
            })

            axios.get(`${this.STW_API_ENDPOINT}/game/country/policies/`, {
                headers: {
                    "Authorization": `bearer ${this.token}`
                }
            })
            .then(response => {
                // JSON responses are automatically parsed.
                //console.log(response.data);
                this.policies = response.data;
            })
            .catch(e => {
                this.warningMessage = `An error occured while retrieving policies: ${e}`
                //this.errors.push(e);
            })

            axios.get(`${this.STW_API_ENDPOINT}/game/country/commands/`, {
                headers: {
                    "Authorization": `bearer ${this.token}`
                }
            })
            .then(response => {
                // JSON responses are automatically parsed.
                //console.log(response.data);
                this.commands = response.data;
            })
            .catch(e => {
                this.warningMessage = `An error occured while retrieving commands: ${e}`
                //this.errors.push(e);
            })

        },

        executeCommand(command) {
            console.log(`Attempting to send command: ${command.command}`);
            axios.post(`${this.STW_API_ENDPOINT}/game/country/`, command.command, {
                headers: {
                    "Authorization": `bearer ${this.token}`
                }
            })
            .then(response => {
                // JSON responses are automatically parsed.
                console.log(response.data);
                this.message = response.data;

                this.refresh();
            })
            .catch( e => {
                this.warningMessage = `An error occured while executing command: ${e}`
                //this.errors.push(e);
            })
        },

        enactPolicy(policy) {
            console.log(`Attempting to send command: ${policy.policy}`);
            axios.post(`${this.STW_API_ENDPOINT}/game/country/policies`, policy.policy, {
                headers: {
                    "Authorization": `bearer ${this.token}`
                }
            })
            .then(response => {
                // JSON responses are automatically parsed.
                console.log(response.data);
                this.message = response.data;

                this.refresh();
            })
            .catch( e => {
                this.warningMessage = `An error occured while enacting policy: ${e}`
                //this.errors.push(e);
            })
        },

        revokePolicy(policy) {
            console.log(`Attempting to send command: ${policy.policy}`);
            axios.post(`${this.STW_API_ENDPOINT}/game/country/policies/revoke`, policy.policy, {
                headers: {
                    "Authorization": `bearer ${this.token}`
                }
            })
            .then(response => {
                // JSON responses are automatically parsed.
                console.log(response.data);
                this.message = response.data;

                this.refresh();
            })
            .catch( e => {
                this.warningMessage = `An error occured while revoking policy: ${e}`
                // this.errors.push(e);
            })
        },

        levelUpPolicy(policy) {
            console.log(`Attempt to level up policy: ${policy.policy.name}`);
            axios.post(`${this.STW_API_ENDPOINT}/game/country/policies/levelup`, policy.policy, {
                headers: {
                    "Authorization": `bearer ${this.token}`
                }
            })
            .then(response => {
                // JSON responses are automatically parsed.
                console.log(response.data);
                this.message = response.data;

                this.refresh();
            })
            .catch( e => {
                this.warningMessage = `An error occured while leveling up policy: ${e}`
                //this.errors.push(e);
            })
        },
        countryClaimed() {
            this.shouldClaimCountry = false
            this.refresh()
        },
        // Source: https://alanedwardes.com/blog/posts/country-code-to-flag-emoji-csharp/
        isoCountryCodeToFlagEmoji(country)
        {
            return String.fromCodePoint(...[...country.toUpperCase()].map(c => c.charCodeAt() + 0x1F1A5));
        }
    },
    // Fetch game data when the component is created
    created() {
        this.hasCountry();
    }
}
</script>

<style>

</style>