//import axios from 'axios';

import axios from "axios";

const STW_API_ENDPOINT = process.env.VUE_APP_STW_API_URL || "http://localhost:8000"

const state = {
    gameData: {
        netGDP: 0,
        earthID: "",
        countryCode: "nl",
        yearlyEmissions: 0,
        currentYear: 0,
        currentTemperature: 0,
        population: 0,
        forecastNetGDP: 0,
        forecastYearlyEmissions: 0,
        forecastPopulation: 0,
        emissionPerCapitaRating: "",
        wealthRating: "",
        giniRating: 0,
        giniRatingRating: "",
        educationDevelopmentIndexRating: "",
        educationDevelopmentIndex: 0,
        budgetSurplus: 0,
        budgetSurplusRating: "",
        earthEffectsDescription: "",
    },
    messages: [{
        id: "",
        message: ""
    }],
    commands: [],
    message: "",
    inactivePolicies: [],
    activePolicies: []
};

const getters = {
    gameData: state => state.gameData,
    messages: state => state.messages,
    commands: state => state.commands,
    message: state => state.message,
    inactivePolicies: state => state.inactivePolicies,
    activePolicies: state => state.activePolicies
};

const actions = {
    dismissMessage({ commit }) {
        commit('setMessage', "");
    },

    // MARK: Gamedata
    async fetchGameData({ commit }, token) {
        const response = await axios.get(`${STW_API_ENDPOINT}/game/country/`, {
            headers: {
                "Authorization": `bearer ${token}`
            }
        });
        console.log(response.data);
        commit('setGameData', response.data);
    },

    async fetchMessages( { commit } ) {
        const response = await axios.get(`${STW_API_ENDPOINT}/logs/${state.gameData.earthID}/`)
        //console.log(response.data)
        commit('setMessages', response.data);
    },

    // MARK: Commands
    async fetchCommands( { commit }, token) {
        const response = await axios.get(`${STW_API_ENDPOINT}/game/country/commands`, {
            headers: {
                "Authorization": `bearer ${token}`
            }
        });

        console.log(response.data);
        commit('setCommands', response.data);
    },

    async executeCommand( { dispatch, commit }, { token, command }) {
        //console.log(command.command);
        console.log(`Attempting to send command: ${command.command}`);
        const response = await axios.post(`${STW_API_ENDPOINT}/game/country/`, command.command, {
            headers: {
                "Authorization": `bearer ${token}`
            }
        });
        await dispatch('fetchGameData', token);
        await dispatch('fetchMessages', token);
        console.log(response.data);
        commit('setMessage', response.data)

    },

    // MARK: Policies
    async fetchPolicies( { commit }, token) {
        const response = await axios.get(`${STW_API_ENDPOINT}/game/country/policies`, {
            headers: {
                "Authorization": `bearer ${token}`
            }
        });

        console.log(response.data);
        commit('setInactivePolicies', response.data.availablePolicies);
        commit('setActivePolicies', response.data.activePolicies);
    },

    async enactPolicy( { dispatch, commit }, { token, policy }) {
        console.log(`Attempting to enact policy: ${policy.policy.name}`);
        const response = await axios.post(`${STW_API_ENDPOINT}/game/country/policies`, policy.policy, {
            headers: {
                "Authorization": `bearer ${token}`
            }
        });
        await dispatch('fetchPolicies', token);
        await dispatch('fetchGameData', token);
        await dispatch('fetchMessages', token);
        commit('setMessage', response.data);
    },

    async revokePolicy( {dispatch, commit }, { token, policy }) {
        console.log(`Attempting to revoke policy: ${policy.policy.name}`);

        const response = await axios.post(`${STW_API_ENDPOINT}/game/country/policies/revoke`, policy.policy, {
            headers: {
                "Authorization": `bearer ${token}`
            }
        });

        await dispatch('fetchPolicies', token);
        await dispatch('fetchGameData', token);
        await dispatch('fetchMessages', token);
        commit('setMessage', response.data);
    },

    async levelupPolicy( { dispatch, commit }, {token, policy }) {
        console.log(`Attempting to levelup policy: ${policy.policy.name}`);

        const response = await axios.post(`${STW_API_ENDPOINT}/game/country/policies/levelup`, policy.policy, {
            headers: {
                "Authorization": `bearer ${token}`
            }
        });

        console.log(response.data);

        await dispatch('fetchPolicies', token);
        await dispatch('fetchGameData', token);
        await dispatch('fetchMessages', token);
        commit('setMessage', response.data);
    }
};

const mutations = {
    setGameData: (state, gameData) => (state.gameData = gameData),
    setMessages: (state, messages) => (state.messages = messages),
    setCommands: (state, commands) => (state.commands = commands),
    setMessage: (state, message) => (state.message = message),
    setInactivePolicies: (state, policies) => (state.inactivePolicies = policies),
    setActivePolicies: (state, policies) => (state.activePolicies = policies)
};

export default {
    state,
    getters,
    actions,
    mutations
};