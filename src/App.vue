<template>
  <Calculator/>
</template>

<script>
import Calculator from './components/Calculator.vue'

export default {
  name: 'App',
  components: {
    Calculator
  }
}
</script>

<style lang="scss">
* {
  box-sizing: border-box;
}

html {
  background-color: #f6ede1;
  min-height: 100vh;

  @media (min-width: 992px) {
    background: #f6ede1 url('assets/v60.webp') no-repeat right center;
  }
}

body {
  margin: 0;
  padding: 0;
}

#app {
  font-family: Roboto, Helvetica, Arial, sans-serif;
  font-size: 15px;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
</style>
