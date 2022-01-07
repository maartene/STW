<template>
  <h3>Claim your country!</h3>
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
</template>

<script>
const axios = require('axios');

export default {
    name: "ClaimCountry",
    data() {
        return {
            countries: [
                { country: {
                        name: "China",
                        yearlyEmissions: 3
                    }, 
                    id: "1234" 
                },
                { country: {
                        name: "Netherlands",
                        yearlyEmissions: 3
                    }, 
                    id: "12332" 
                }
            ],
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