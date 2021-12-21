<template>
    <h1>Please login</h1>
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

    <button type="submit" v-on:click="login" class="btn btn-primary">Submit</button>

    <button v-on:click="fill" class="btn btn-danger">Let me in!</button>
</template>

<script>
const axios = require('axios');

export default {
    name: "LoginComponent",
    data() {
        return {
            earthID: "",
            countryID: ""
        }
    },
    emits: ['login'],
    methods: {
        fill() {
            this.earthID = "123F831D-35C4-4504-995C-263D3DC8E756";
            this.countryID = "7ADFF7AC-9073-4618-B649-AB0AA1B9075A";
            this.login();
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
                    if (response2.data.id == this.countryID) {
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