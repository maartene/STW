<template>
    <h3>Active policies</h3>
    <table class="table">
        <thead>
            <tr>
                <th>Category</th>
                <th>Policies</th>
                <th>Effect</th>
                <th>Upgrade cost</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="(policy, index) in activePolicies" :key="index">
                <td><span class="badge bg-info">{{policy.policy.category}}</span></td>
                <td>{{index + 1}}</td>
                <td>{{policy.policy.name}}</td>
                <td>{{policy.effectDescription}}</td>
                <td>{{policy.upgradeCost}}</td>
                <td>
                    <button class="btn btn-sm btn-danger" v-on:click="revokePolicy(policy.policy)">Revoke</button>&nbsp;
                    <button class="btn btn-sm btn-success" v-on:click="levelUpPolicy(policy.policy)">Improve</button>
                </td>
            </tr>
        </tbody>
    </table>
</template>

<script>
export default {
    name: "ActivePolicies",
    props: {
        activePolicies: Array 
    },
    emits: [
        "revokePolicy",
        "levelUpPolicy"
    ],
    methods: {
        revokePolicy(policy) {
            this.$emit('revokePolicy', {
                "policy": policy
            });
        },
        levelUpPolicy(policy) {
            this.$emit('levelUpPolicy', {
                "policy": policy
            });
        }
    }
}
</script>

<style>

</style>