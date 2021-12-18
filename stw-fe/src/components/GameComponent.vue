!<template>
    <div class="alert alert-primary d-flex align-items-center alert-dismissible fade show" role="alert" v-if="message != ''">
        <img src="/img/bootstrap-icons/check-circle.svg" alt="Check circle">&nbsp;&nbsp;
        <div>
            {{message}}
            <button type="button" class="btn-close" v-on:click="message = ''" aria-label="Close"></button>
        </div>
    </div>
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
    <p class="my-3"></p>
    <h1>Your command?</h1>
    <table class="table">
        <thead>
            <tr>
                <th>&nbsp;</th>
                <th>Command</th>
                <th>Effect</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="(command, index) in commands" :key="index">
                <td>{{index + 1}}</td>
                <td>{{command.name}}&nbsp;
                    <span class="badge bg-success" v-if="command.isActive">Active</span>
                </td>
                <td>{{command.commandEffectDescription}}</td>
                <td>
                    <button class="btn btn-sm btn-success" v-if="command.isActive == false" v-on:click="sendCommand(command.command)">Activate</button>
                    <button class="btn btn-sm btn-danger" v-if="command.isActive" v-on:click="reverseCommand(command.command)">Deactivate</button>
                </td>
            </tr>
        </tbody>
    </table>
    <p class="my-3"></p>
    <button class="btn btn-primary" v-on:click="refresh">Refresh</button>
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
            },
            commands: [
                { name: "Foo" }
            ],
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

        sendCommand(command) {
            console.log(`Attempting to send command: ${command}`);
            axios.post(`${this.STW_API_ENDPOINT}/game/${this.countryID}/`, command)
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

        reverseCommand(command) {
            console.log(`Attempting to reverse command: ${command}`);
            axios.post(`${this.STW_API_ENDPOINT}/game/${this.countryID}/reverse`, command)
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