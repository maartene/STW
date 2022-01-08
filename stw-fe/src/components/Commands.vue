<template>
    <h3>Commands:
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-info-circle-fill text-info" viewBox="0 0 16 16"
            data-bs-toggle="tooltip" data-bs-html="true" data-bs-placement="bottom" title="Commands are one-off actions. Note: these will be added in a later version.">
            <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm.93-9.412-1 4.705c-.07.34.029.533.304.533.194 0 .487-.07.686-.246l-.088.416c-.287.346-.92.598-1.465.598-.703 0-1.002-.422-.808-1.319l.738-3.468c.064-.293.006-.399-.287-.47l-.451-.081.082-.381 2.29-.287zM8 5.5a1 1 0 1 1 0-2 1 1 0 0 1 0 2z"/>
        </svg>
    </h3>
    <table class="table">
        <thead>
            <tr>
                <th>&nbsp;</th>
                <th>Command</th>
                <th>Effect</th>
                <th>Cost</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="(command, index) in commands" :key="index">
                <td>{{index + 1}}</td>
                <td>{{command.command.name}}</td>
                <td>{{command.effectDescription}}</td>
                <td>{{command.command.cost}}</td>
                <td>
                    <button class="btn btn-sm btn-success" v-on:click="executeCommand(command.command)">Execute</button>
                </td>
            </tr>
        </tbody>
    </table>
</template>

<script>
const bootstrap = require('bootstrap');

export default {
    name: "ActivePolicies",
    props: {
        commands: Array 
    },
    emits: [
        "executeCommand"
    ],
    methods: {
        executeCommand(command) {
            this.$emit('executeCommand', {
                "command": command
            });
        }
    }, 
    created() {
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
        //var tooltipList = 
        tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl)
        })
        //console.log(tooltipList.length)
    }
}
</script>

<style>

</style>