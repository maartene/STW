<template>
    <div>
        <h3>Current suggestions
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-info-circle-fill text-info" viewBox="0 0 16 16"
                data-bs-toggle="tooltip" data-bs-html="true" data-bs-placement="bottom" title="Your country has the following active suggestions. Ones you sent out yourself, you can choose to 'revoke'. The ones you received, you can either 'accept' or 'refuse'.">
                <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm.93-9.412-1 4.705c-.07.34.029.533.304.533.194 0 .487-.07.686-.246l-.088.416c-.287.346-.92.598-1.465.598-.703 0-1.002-.422-.808-1.319l.738-3.468c.064-.293.006-.399-.287-.47l-.451-.081.082-.381 2.29-.287zM8 5.5a1 1 0 1 1 0-2 1 1 0 0 1 0 2z"/>
            </svg>
        </h3>
        <p class="text-muted">Note that accepting a suggestion contains a commitment: policies enacted by accepting suggestions cannot be revoked. But they do bring extra country points.</p>
        <div class="row">
            <div class="col">
                <h5>For you</h5>
                <ul class="list-group">
                    <li class="list-group-item" v-for="suggestion in suggestions.forYou" :key="suggestion.id"><b>{{suggestion.ownerName}}</b> suggested you to enact policy <b>{{suggestion.policy.name}}</b> <br/>
                        <button class="btn btn-sm btn-success" v-on:click="acceptSuggestion({token, suggestionID: suggestion.id})">Accept</button> &nbsp;
                        <button class="btn btn-sm btn-danger" v-on:click="refuseSuggestion({token, suggestionID: suggestion.id})">Refuse</button>
                    </li>
                    <li class="list-group-item" v-if="suggestions.forYou.length == 0">No suggestions</li>
                </ul>
            </div>
            <div class="col">
                <h5>By you</h5>
                <ul class="list-group">
                    <li class="list-group-item" v-for="suggestion in suggestions.byYou" :key="suggestion.id">You suggested <b>{{suggestion.targetName}}</b> to enact policy <b>{{suggestion.policy.name}}</b> <br/>
                        <button class="btn btn-sm btn-danger" v-on:click="revokeSuggestion({token, suggestionID: suggestion.id })">Revoke</button>
                    </li>
                </ul>
            </div>
        </div>
        <p></p>
        <h3>Possible suggestions</h3>
        <p class="text-muted">You can have a maximum of 3 outstanding suggestions.</p>
        <table class="table">
            <thead>
                <th>Target country</th>
                <th>Policy to enact</th>
                <th>Category</th>
                <th>Cost</th>
                <th>Action</th>
            </thead>
            <tbody>
                <tr v-for="(option, index) in diplomacyOptions" :key="index">
                    <td>{{option.countryModel.country.name}}</td>
                    <td>{{option.policy.name}}</td>
                    <td><span class="badge bg-secondary">{{option.policy.category}}</span></td>
                    <td>{{option.policy.baseCost}}</td>
                    <td><button class="btn btn-sm btn-warning" v-on:click="makeSuggestion({token, targetID: option.countryModel.id, policy: option.policy })">Suggest</button></td>
                </tr>
                <tr v-if="diplomacyOptions.length == 0">
                    <td colspan="3">No available suggestions.</td>
                </tr>
            </tbody>
        </table>
    </div>
    
</template>

<script>
import { mapGetters, mapActions } from 'vuex';

export default {
    name: "Diplomacy",
    props: {
        token: String
    },
    methods: {
        ...mapActions(['fetchSuggestions', 'fetchOptions', 'makeSuggestion', 'acceptSuggestion', 'refuseSuggestion', 'revokeSuggestion', 'dismissMessage'])
    },
    computed: mapGetters(['suggestions', 'diplomacyOptions', 'message']),
    created() {
        this.fetchSuggestions(this.token);
        this.fetchOptions(this.token);
    }
}
</script>

<style>

</style>