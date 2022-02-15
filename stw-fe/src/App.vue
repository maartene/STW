<template>
  <div>
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
    <div class="container-fluid">
      <a href="/"><img src="/img/logo_small_400px.png" alt="Save the World logo" width="200"/></a>
    </div>
  </nav>
  <div class="container-flex m-3 p-3">
    <div class="alert alert-dismissible alert-secondary mx-1 p-3">
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      <h4 class="alert-heading">Simulation reset on March 1st</h4>
      <ul>
        <li>On March 1, the simulation will reset to the year 2015.</li>
        <li>All country and earth progress will be lost.</li>
        <li>Your account will remain, although you will need to choose a new country.</li>
      </ul>
    </div>

    <transition name="fade">
      <div v-if="!loggedIn()">
        <LoginComponent @login="doLogin"></LoginComponent>
      </div>
      <p v-else>
        <GameComponent v-bind:token="token"></GameComponent>
      </p>
    </transition>
  </div>
  <footer>
    <div class="container-flex p-3 m-3 border-top">
      <a href="https://www.thedreamweb.eu" target="_blank"><img src="/img/dreamweblogo.png" width="32"/></a>&nbsp;&nbsp;&copy; <a href="https://www.thedreamweb.eu" target="_blank">thedreamweb.eu</a>, 2022. Support: <span class="text-muted">support @ letssavetheworld.club</span>
    </div>
  </footer>
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
      token: "",
    }
  },
  emits: ['login'],
  methods: {
    doLogin(token) {
      this.token = token.token;
    },
    loggedIn() {
      return this.token != ""
    }
  },
  mounted() {
    document.title = "Let's save the World (letssavetheworld.club)"
  }
}
</script>

<style>
</style>
