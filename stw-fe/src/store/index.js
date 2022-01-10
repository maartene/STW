import Vuex from 'vuex';
//import Vue from 'vue';
import gameData from './modules/gameData';
import diplomacy from './modules/diplomacy';

//Vue.use(Vuex);

export default new Vuex.Store({
    modules: {
        gameData,
        diplomacy
    }
});