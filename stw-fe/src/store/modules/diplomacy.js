import axios from "axios";

const STW_API_ENDPOINT = process.env.VUE_APP_STW_API_URL || "http://localhost:8000";

const state = { 
    suggestions: { forYou: [], byYou: []},
    diplomacyOptions: []
};

const getters = {
    suggestions: state => state.suggestions,
    diplomacyOptions: state => state.diplomacyOptions,
};

const actions = { 
    async fetchSuggestions({ commit }, token) {
        const response = await axios.get(`${STW_API_ENDPOINT}/game/country/diplomacy`, {
            headers: {
                "Authorization": `bearer ${token}`
            }
        });
        console.log(response.data);
        commit('setSuggestions', response.data);
    },
    async fetchOptions({ commit }, token) {
        const response = await axios.get(`${STW_API_ENDPOINT}/game/country/diplomacy/options`, {
            headers: {
                "Authorization": `bearer ${token}`
            }
        });
        console.log(response.data);
        commit('setOptions', response.data);
    },
    async makeSuggestion({ commit, dispatch }, {token, targetID, policy} ) {
        const response = await axios.post(`${STW_API_ENDPOINT}/game/country/diplomacy/`, {
            targetID, policy
        },
        {
            headers: {
                "Authorization": `bearer ${token}`
            }
        });
        console.log(response.data);
        dispatch('fetchMessages', token);
        dispatch('fetchSuggestions', token);
        dispatch('fetchOptions', token);
        commit('setMessage', response.data)
    },
    async acceptSuggestion({ commit, dispatch }, {token, suggestionID} ) {
        const response = await axios.post(`${STW_API_ENDPOINT}/game/country/diplomacy/${suggestionID}/accept`, {},
        {
            headers: {
                "Authorization": `bearer ${token}`
            }
        });
        console.log(response.data);
        await dispatch('fetchPolicies', token);
        commit('setMessage', response.data)
    },
    async refuseSuggestion({ commit, dispatch }, {token, suggestionID} ) {
        const response = await axios.post(`${STW_API_ENDPOINT}/game/country/diplomacy/${suggestionID}/refuse`, {},
        {
            headers: {
                "Authorization": `bearer ${token}`
            }
        });
        console.log(response.data);
        await dispatch('fetchSuggestions', token);
        commit('setMessage', response.data)
    },
    async revokeSuggestion({ commit, dispatch }, {token, suggestionID} ) {
        const response = await axios.post(`${STW_API_ENDPOINT}/game/country/diplomacy/${suggestionID}/revoke`, {},
        {
            headers: {
                "Authorization": `bearer ${token}`
            }
        });
        console.log(response.data);
        await dispatch('fetchSuggestions', token);
        await dispatch('fetchOptions', token);
        commit('setMessage', response.data)
    }
};

const mutations = { 
    setSuggestions: (state, suggestions) => (state.suggestions = suggestions),
    setOptions: (state, options) => {
        var result = [];
        options.forEach(option => {
            option.policies.forEach(policy => {
                result.push({ countryModel: option.countryModel, policy })
            });
        });
        state.diplomacyOptions = result;
    },
};

export default {
    state,
    getters,
    actions,
    mutations
};