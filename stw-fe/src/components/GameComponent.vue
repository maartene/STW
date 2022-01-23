<template>
    <div>
        <div class="alert alert-primary d-flex align-items-center alert-dismissible fade show" role="alert" v-if="message != ''">
            <img src="/img/bootstrap-icons/check-circle.svg" alt="Check circle">&nbsp;&nbsp;
            <div>
                {{message}}
                <button type="button" class="btn-close" v-on:click="dismissMessage" aria-label="Close"></button>
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
                </h1>
            </div>
            <TabWrapper>
            <Tab title="Overview">
                <Overview />
            </Tab>
            <Tab title="Policies">
                <p class="my-3"></p>
                    <ActivePolicies v-bind:token="token"></ActivePolicies>
                <p class="my-3"></p>
                <InactivePolicies v-bind:token="token"></InactivePolicies>    
            </Tab>
            <Tab title="Commands"><Commands v-bind:token="token"/></Tab>
            <Tab title="Diplomacy"><Diplomacy v-bind:token="token"/></Tab>
            <Tab title="Forecast"><Forecast v-bind:token="token"></Forecast></Tab>
            </TabWrapper>
        </div>
    </div>
</template>

<script>
const axios = require('axios');

import { mapGetters, mapActions } from 'vuex';

import TabWrapper from './TabWrapper.vue'
import Tab from './Tab.vue'

import ActivePolicies from './ActivePolicies.vue';
import InactivePolicies from './InactivePolicies.vue';
import Commands from './Commands.vue';
import Forecast from './Forecast.vue';
import Overview from './Overview.vue';
import ClaimCountry from './ClaimCountry.vue'
import Diplomacy from './Diplomacy.vue';


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
        Diplomacy,

        ClaimCountry,
        

    }, 
    data() {
        return {
            warningMessage: "",
            shouldClaimCountry: false,
            timer: ""
        }
    },
    computed: mapGetters(['gameData', 'message']),
    props: {
        token: String
    },
    methods: {
        // Source: https://alanedwardes.com/blog/posts/country-code-to-flag-emoji-csharp/
        isoCountryCodeToFlagEmoji(country)
        {
            return String.fromCodePoint(...[...country.toUpperCase()].map(c => c.charCodeAt() + 0x1F1A5));
        },
        
        hasCountry() {
            axios.get(`${this.STW_API_ENDPOINT}/game/country/hasCountry`, {
                headers: {
                    "Authorization": `bearer ${this.token}`
                }
            })
            .then(response => {
                if (response.data == true) {
                    this.refresh();
                    this.timer = setInterval(this.refresh, 600000); 
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
        countryClaimed() {
            this.shouldClaimCountry = false
            this.refresh()
        },
        refresh() {
            this.fetchGameData(this.token)
            .then( () => {
                this.fetchMessages(this.token);
            })
            this.fetchCommands(this.token);
            this.fetchPolicies(this.token);
        },
        ...mapActions(['fetchGameData', 'fetchMessages', 'fetchCommands', 'dismissMessage', 'fetchPolicies'])
    },
    // Fetch game data when the component is created
    created() {
        this.hasCountry();
    }
}
</script>

<style>

</style>