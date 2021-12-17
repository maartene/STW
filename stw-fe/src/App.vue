<template>
  <div class="container">
    <transition name="fade">
      <p v-if="!loggedIn()">
        <LoginComponent @login="doLogin"></LoginComponent>
      </p>
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
    LoginComponent
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
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5 ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
