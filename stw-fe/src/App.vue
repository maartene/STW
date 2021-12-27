<template>
  <div class="container-flex m-3 p-3">
    <h1>Save the World</h1>
        <transition name="fade">
        <div v-if="!loggedIn()">
          <LoginComponent @login="doLogin"></LoginComponent>
        </div>
        <p v-else>
          <GameComponent v-bind:countryID="countryID"></GameComponent>
        </p>
      </transition>
  </div>
</template>

<script>
import GameComponent from './components/GameComponent.vue'
import LoginComponent from './components/LoginComponent.vue'

export default {
  name: 'App',
  components: {
    GameComponent,
    LoginComponent,
  },
  data() {
    return {
      earthID: "",
      countryID: ""
    }
  },
  emits: ['login'],
  methods: {
    doLogin(data) {
      this.earthID = data.earthID;
      this.countryID = data.countryID;
    },
    loggedIn() {
      return this.earthID != "" && this.countryID != ""
    }
  },
  mounted() {
    document.title = "Let's save the World"
  }
}
</script>

<style>
</style>
