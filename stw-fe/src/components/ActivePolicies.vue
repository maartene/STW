<template>
    <h3>Active policies
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-info-circle-fill text-info" viewBox="0 0 16 16"
                        data-bs-toggle="tooltip" data-bs-html="true" data-bs-placement="bottom" 
                        title="Policies have continuous effects. These  are the policies that are currently enacted by your country. You can revoke them (free) or increase their effectiveness by upgrading them (level up).">
                        <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm.93-9.412-1 4.705c-.07.34.029.533.304.533.194 0 .487-.07.686-.246l-.088.416c-.287.346-.92.598-1.465.598-.703 0-1.002-.422-.808-1.319l.738-3.468c.064-.293.006-.399-.287-.47l-.451-.081.082-.381 2.29-.287zM8 5.5a1 1 0 1 1 0-2 1 1 0 0 1 0 2z"/>
                    </svg>
                    </h3>
    <table class="table">
        <thead>
            <tr>
                <th>Category</th>
                <th>Policy</th>
                <th>Upgrade cost</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="(policy, index) in activePolicies" :key="index">
                <td><span class="badge bg-secondary">{{policy.policy.category}}</span></td>
                <td>{{policy.policy.name}}</td>
                <td>{{policy.effectDescription}}</td>
                <td>{{policy.upgradeCost}}</td>
                <td>
                    <button class="btn btn-sm btn-danger" v-on:click="revokePolicy({ token, policy })">Revoke</button>&nbsp;
                    <button class="btn btn-sm btn-success" v-on:click="levelupPolicy({ token, policy })">Improve</button>
                </td>
            </tr>
        </tbody>
    </table>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';

export default {
    name: "ActivePolicies",
    props: {
        token: String
    },
    computed: mapGetters(['activePolicies']),
    methods: mapActions(['revokePolicy', 'levelupPolicy'])
}
</script>

<style>

</style>