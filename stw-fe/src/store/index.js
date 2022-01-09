import Vuex from 'vuex';
//import Vue from 'vue';
import gameData from './modules/gameData';

//Vue.use(Vuex);

export default new Vuex.Store({
    modules: {
        gameData
    }
});