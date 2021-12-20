<template>
    <h3>Enact policies</h3>
    <table class="table">
        <thead>
            <tr>
                <th>&nbsp;</th>
                <th>Policies</th>
                <th>Effect</th>
                <th>Cost</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="(policy, index) in inactivePolicies" :key="index">
                <td>{{index + 1}}</td>
                <td>{{policy.policy.name}}</td>
                <td>{{policy.effectDescription}}</td>
                <td>{{policy.policy.baseCost}}</td>
                <td>
                    <button class="btn btn-sm btn-success" v-on:click="enactPolicy(policy.policy)">Activate</button>
                </td>
            </tr>
        </tbody>
    </table>
</template>

<script>
export default {
    name: "InactivePolicies",
    props: {
        inactivePolicies: Array 
    },
    emits: [
        "enactPolicy"
    ],
    methods: {
        enactPolicy(policy) {
            this.$emit('enactPolicy', {
                "policy": policy
            });
        }
    }
}
</script>

<style>

</style>