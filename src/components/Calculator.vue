<template>
  <div class="calculator">
    <div class="well">
      <h2 class="title">Parameters</h2>
      <label for="coffee">Coffee weight:</label>
      <input type="number" v-model="coffee" id="coffee" class="form-control" min="10" max="60">
      <div class="taste-controls">
        <label>Taste controls:</label>
        <div class="slider-row">
          <div class="slider-title">
            <span>Brighter</span>
            <span>Sweeter</span>
          </div>
          <input
            type="range"
            class="slider-slider"
            min="0.3"
            max="0.7"
            step="any"
            v-model.number="taste"
          >
        </div>
        <div class="slider-row">
          <div class="slider-title">
            <span>Light</span>
            <span>Medium</span>
            <span>Strong</span>
          </div>
          <input
            class="slider-slider"
            type="range"
            id="strength-slider"
            min="1"
            max="3"
            step="1"
            v-model="strength"
          >
        </div>
      </div>
    </div>

    <div class="well">
      <h2 class="title">Data</h2>
      <table>
        <tr>
          <td>Coffee</td>
          <td>{{coffee}}g</td>
        </tr>
        <tr>
          <td>Water</td>
          <td>{{water}}ml</td>
        </tr>
        <tr>
          <td>Temperature</td>
          <td>93°c</td>
        </tr>
      </table>
    </div>

    <div class="well instructions">
      <h2 class="title">Instructions</h2>
      <table>
        <thead>
          <tr>
            <th>Total time</th>
            <th>Water amount pound</th>
            <th>Total Water amount</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>0s</td>
            <td>{{step1}}ml</td>
            <td>{{step1}}ml</td>
          </tr>
          <tr>
            <td>45s</td>
            <td>{{step2}}ml</td>
            <td>{{step1 + step2}}ml</td>
          </tr>
          <tr>
            <td>1m30s</td>
            <td>{{step3}}ml</td>
            <td>{{step1 + step2 + step3}}ml</td>
          </tr>
          <tr v-if="step4 > 0">
            <td>2m15s</td>
            <td>{{step4}}ml</td>
            <td>{{step1 + step2 + step3 + step4}}ml</td>
          </tr>
          <tr v-if="step5 > 0">
            <td>3m00s</td>
            <td>{{step5}}ml</td>
            <td>{{step1 + step2 + step3 + step4 + step5}}ml</td>
          </tr>
          <tr>
            <td v-if="strength == 3">3m45s</td>
            <td v-if="strength == 2">3m00s</td>
            <td v-if="strength == 1">2m15s</td>
            <td></td>
            <td>Remove the dripper</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="description">
      <h1>4:6 brewing method</h1>
      <h2>How to brew with the “4:6 method”</h2>

      <ol>
        <li>Rinse the paper filter with hot water.</li>
        <li>Divide the total amount of water to be poured into <strong>40%</strong> and <strong>60%</strong></li>
      </ol>

      <h2>Tips</h2>
      <ul>
        <li>Choose your preferred grind size. (Adjust the coarseness so that water atmost completely drips within this total time.)</li>
        <li>The role of the first pour is to moisten the grounds.</li>
        <li>Do not make the next pour untit the water completely drips through.</li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Calculator',
  data() {
    return {
      coffee: 20,
      taste: 5/12,
      strength: 3,
    }
  },
  watch: {
    taste: {
      immediate: true,
      handler() {
        // Force a re-render of the slider to fix positioning issue
        this.$nextTick(() => {
          this.$forceUpdate();
        });
      }
    }
  },
  computed: {
    water() {
      return this.coffee * 15;
    },

    firstPartWater() {
      return Math.round(this.water * 0.4);
    },
    secondPartWater() {
      return this.water - this.firstPartWater;
    },

    // 4:6 method: first 40% of water is for first two pours:
    step1() {
      return Math.round(this.firstPartWater * this.taste);
    },
    step2() {
      return this.firstPartWater - this.step1;
    },

    // 4:6 method: rest 60% of water is distributed between 1-3 pours depending on desired strength:
    step3() {
      return Math.round(this.secondPartWater / this.strength);
    },
    step4() {
      return this.strength > 1 ? Math.round(this.secondPartWater / this.strength) : 0;
    },
    step5() {
      return this.secondPartWater - this.step3 - this.step4;
    },
  }
}
</script>

<style scoped lang="scss">
.text-center {
  text-align: center;
}

.calculator {
  display: grid;
  grid-gap: 20px;
  grid-template-columns: minmax(0, 1fr);
  max-width: 550px;
  padding: 10px;

  @media (min-width: 992px) {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    margin-left: 60px;
    margin-top: 60px;
  }
}

.well {
  background-color: #fff;
  border-radius: 5px;
  padding: 20px;
}

.instructions {
  @media (min-width: 992px) {
    grid-column: 1 / 3;
  }
}

.description {
  @media (min-width: 992px) {
    grid-column: 1 / 3;
  }
}

table {
  text-align: right;
  width: 100%;
}

td, th {
  border-bottom: 1px solid #eee;
  padding: 4px 20px;
}

.title {
  font-size: 16px;
  margin-top: 0;
  text-transform: uppercase;
}

label {
  display: inline-block;
  font-weight: 700;
  margin-bottom: 5px;
}

.form-control {
  border: 1px solid #ccc;
  border-radius: 3px;
  display: inline-block;
  padding: 8px 12px;
  width: 100%;
}

.taste-controls {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.slider-title {
  display: flex;
  justify-content: space-between;
}

.slider-slider {
  width: 100%;
}

.taste-controls {
  padding-top: 20px;
}

</style>
