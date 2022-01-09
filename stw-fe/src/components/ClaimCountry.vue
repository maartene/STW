<template>
    <div>
        <h3>Claim your country!</h3>
        <p>In this game you will play as a country. You will set policies that influence your country's economy, population and emissions. And emissions influence the entire world.</p>
        <p>Please claim a country to play as.</p>
        <p class="text-info">Hint: a country with higher yearly emissions has more impact op global warming.</p>
        <p v-if="message != ''">{{message}}</p>
        <table class="table">
            <thead>
                    <tr>
                        <th>Country</th>
                        <th>Yearly emissions (Giga Tonnes Carbon)</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="country in countries" :key="country.id">
                        <td>{{country.country.name}}</td>
                        <td>{{country.country.yearlyEmissions.toPrecision(4)}}</td>
                        <td><button class="btn btn-sm btn-danger" v-on:click="claimCountry(country)">Claim</button></td>
                    </tr>
                </tbody>
        </table>
    </div>
</template>

<script>
const axios = require('axios');

export default {
    name: "ClaimCountry",
    data() {
        return {
            countries: [],
            message: ""
        }
    },
    props: {
        token: String
    },
    emits: [
        "countryClaimed"
    ],
    methods: {
        claimCountry(country) {
            console.log(this.STW_API_ENDPOINT);
            axios.post(`${this.STW_API_ENDPOINT}/game/country/claim/`, country, {
                headers: {
                    "Authorization": `bearer ${this.token}`
                }
            })
            .then(response => {
                console.log(response.data);
                if (response.data == "success") {
                    this.message = `Succesfully claimed ${country.name}.`
                    this.$emit('countryClaimed', {})
                }
            })
            .catch(e => {
                console.log(e)
                this.errors.push(e)
            })
        }
    },
    created() {
        axios.get(`${this.STW_API_ENDPOINT}/game/country/claim/`, {
            headers: {
                "Authorization": `bearer ${this.token}`
            }
        })
        .then(response => {
            console.log(response.data)
            this.countries = response.data
        })
        .catch(e => {
            console.log(e)
            this.errors.push(e)
        })
    }
}
</script>

<style>

</style>