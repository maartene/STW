<template>
    <div class="row">
        <div class="col mx-3 border">
            <h2>Please login</h2>
            <div class="mb-3">
                <label for="countryID" class="form-label">Country ID:</label>
                <input type="text" v-model="countryID" class="form-control" id="countryID" aria-describedby="countryHelp">
                <div class="form-text" id="countryHelp">You should have written this down...</div>
            </div>
            <div class="mb-3">
                <label for="earthID" class="form-label">Earth ID:</label>
                <input type="text" v-model="earthID" class="form-control" id="earthID" aria-describedby="earthHelp">
                <div class="form-text" id="earthHelp">You should have written this down...</div>
            </div>

            <button type="submit" v-on:click="login" class="btn btn-primary mb-3">Submit</button>

            <button v-on:click="fill" class="btn btn-danger mb-3">Let me in!</button>
        </div>
        <div class="col mx-3 border">
            <h2>Don't have a country?</h2>
            <div class="mb-3"></div>
            <button v-if="claimMessage.message == ''" v-on:click="claim" class="btn btn-warning btn-lg">Claim a country!</button>
            <div v-if="claimMessage.message">
                <p>{{claimMessage.message}}</p>
                <h5 class="text-primary"><strong>Please write the following data down:</strong></h5>
                <ul class="list-group">
                    <li class="list-group-item"><strong>Country ID:</strong> <br><pre>{{claimMessage.countryID}}</pre></li>
                    <li class="list-group-item"><strong>Earth ID:</strong> <br><pre>{{claimMessage.earthID}}</pre></li>
                </ul>
                <button class="btn btn-primary my-3" v-on:click="copy">Copy</button>
            </div>
            
        </div>
    </div>
    
</template>

<script>
const axios = require('axios');

export default {
    name: "LoginComponent",
    data() {
        return {
            earthID: "",
            countryID: "",
            claimMessage: {
                message: "",
                earthID: "",
                countryID: ""
            }
        }
    },
    emits: ['login'],
    methods: {
        fill() {
            this.earthID = "F4612A66-C66D-4988-A1C8-8466FBBA3BCD";
            this.countryID = "DE5B394F-7253-44A8-AB90-9A6E88F3EE5F";
            this.login();
        },
        claim() {
            axios.post(`${this.STW_API_ENDPOINT}/game/claim`, {})
            .then(response => {
                console.log(response.data);

                this.claimMessage = response.data;
            })
            .catch(e => {
                this.errors.push(e);
            })
        },
        copy() {
            this.countryID = this.claimMessage.countryID
            this.earthID = this.claimMessage.earthID
        },
        login() {
            // to see wether we have valid data, we try to get the earth...
            axios.get(`${this.STW_API_ENDPOINT}/earthModels/${this.earthID}/`)
            .then(response => {
                // JSON responses are parsed automatically
                console.log(response.data);

                // and country...
                axios.get(`${this.STW_API_ENDPOINT}/countryModels/${this.countryID}`)
                .then(response2 => {
                    console.log(response2.data);
                    if (response2.data.id == this.countryID && response2.data.playerID) {
                        // and when this is succesfull, we emit the 'login' event.
                        this.$emit('login', {
                            "earthID": this.earthID,
                            "countryID": this.countryID
                        });
                    }
                })
                .catch(e2 => {
                    this.errors.push(e2);
                })
            })
            .catch(e => {
                this.errors.push(e);
            })
        }
    }
}
</script>

<style>

</style>