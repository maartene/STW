<template>
    <h3>Commands:</h3>
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
    }
}
</script>

<style>

</style>