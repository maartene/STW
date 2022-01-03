<template>
  <nav class="navbar navbar-expand-lg navbar-light bg-light">
    <div class="container-fluid">
      <a href="/"><img src="/img/logo_small_400px.png" alt="Save the World logo" width="200"/></a>
    </div>
  </nav>
  <div class="container-flex m-3 p-3">
    
    <div class="alert alert-secondary mx-1 p-3">
      <h4 class="alert-heading">This is pre-release software!</h4>
      <ul>
        <li>This software can go down to push a new version at any time, you may lose your progress at any time.</li>
        <li>Please file any bugs as a <a class="alert-link" href="https://github.com/maartene/STW/issues">GitHub issue</a>.</li>
      </ul>
      <p class="mb-0">Most up-to-date source code can be found on <a href="https://github.com/maartene/STW" class="alert-link">https://github.com/maartene/STW</a>.</p>
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
