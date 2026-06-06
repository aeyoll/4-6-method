<template>
  <div class="calculator">
    <div class="well">
      <h2 class="title">Parameters</h2>
      <label for="coffee">Coffee weight:</label>
      <input type="number" v-model.number="coffee" id="coffee" class="form-control" min="10" max="60" step="0.1">
      <label for="ratio" style="margin-top: 10px;">Water ratio:</label>
      <input type="number" v-model.number="ratio" id="ratio" class="form-control" min="1" max="30" step="0.1">
      <div class="taste-controls">
        <label>Taste controls:</label>
        <div class="slider-row">
          <div class="slider-title">
            <span>Brighter</span>
            <span>Sweeter</span>
          </div>
          <div class="slider-with-input">
            <input
              type="range"
              class="slider-slider"
              min="0.4166666667"
              max="0.5833333333"
              step="0.0001"
              v-model.number="taste"
            >
          </div>
          <div class="pour-split">
            <span>First split:</span>
            <input
              type="number"
              class="taste-number"
              :value="pour1Pct"
              @change="onPour1Input"
              min="41.7"
              max="58.3"
              step="0.1"
            >
            <span>%</span>
          </div>
        </div>
        <div class="slider-row">
          <label>Strength:</label>
          <div class="button-group">
            <button
              v-for="s in strengthOptions"
              :key="s.value"
              :class="['strength-btn', { active: strength === s.value }]"
              @click="strength = s.value"
            >{{ s.label }}</button>
          </div>
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
        <tr>
          <td>Water ratio</td>
          <td>1:{{ratio}}</td>
        </tr>
        <tr>
          <td>First split</td>
          <td>{{pour1Pct}}%</td>
        </tr>
        <tr>
          <td>Strength</td>
          <td>{{strengthLabel}}</td>
        </tr>
      </table>
    </div>

    <div class="well instructions">
      <h2 class="title">Instructions</h2>
      <table>
        <thead>
          <tr>
            <th>Total time</th>
            <th>Water amount pour</th>
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
            <td>{{r(step1 + step2)}}ml</td>
          </tr>
          <tr>
            <td>1m30s</td>
            <td>{{step3}}ml</td>
            <td>{{r(step1 + step2 + step3)}}ml</td>
          </tr>
          <tr v-if="step4 > 0">
            <td>2m15s</td>
            <td>{{step4}}ml</td>
            <td>{{r(step1 + step2 + step3 + step4)}}ml</td>
          </tr>
          <tr v-if="step5 > 0">
            <td>3m00s</td>
            <td>{{step5}}ml</td>
            <td>{{r(step1 + step2 + step3 + step4 + step5)}}ml</td>
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
        <li>Choose your preferred grind size. (Adjust the coarseness so that water almost completely drips within this total time.)</li>
        <li>The role of the first pour is to moisten the grounds.</li>
        <li>Do not make the next pour until the water completely drips through.</li>
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
      ratio: 15.0,
      taste: 0.4166666667,
      strength: 3,
      strengthOptions: [
        { label: 'Light', value: 1 },
        { label: 'Medium', value: 2 },
        { label: 'Strong', value: 3 },
      ],
    }
  },
  methods: {
    r(val) {
      return Math.round(val * 10) / 10;
    },
    onPour1Input(e) {
      const pct = parseFloat(e.target.value);
      if (!isNaN(pct)) {
        const p1 = Math.min(58.3, Math.max(41.7, pct));
        this.taste = (100 - p1) / 100;
      }
    },
  },
  computed: {
    strengthLabel() {
      return { 1: 'Light', 2: 'Medium', 3: 'Strong' }[this.strength];
    },
    pour1Pct() {
      return Math.round((1 - this.taste) * 1000) / 10;
    },
    pour2Pct() {
      return Math.round((100 - this.pour1Pct) * 10) / 10;
    },

    water() {
      return this.r(this.coffee * this.ratio);
    },

    firstPartWater() {
      return this.r(this.water * 0.4);
    },
    secondPartWater() {
      return this.r(this.water - this.firstPartWater);
    },

    step1() {
      return this.r(this.firstPartWater * (1 - this.taste));
    },
    step2() {
      return this.r(this.firstPartWater - this.step1);
    },

    step3() {
      return this.r(this.secondPartWater / this.strength);
    },
    step4() {
      return this.strength > 1 ? this.r(this.secondPartWater / this.strength) : 0;
    },
    step5() {
      return this.r(this.secondPartWater - this.step3 - this.step4);
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
  width: 100%;
  table-layout: fixed;
}

td, th {
  border-bottom: 1px solid #eee;
  padding: 4px 20px;
}

td:first-child, th:first-child {
  text-align: left;
  white-space: nowrap;
}

td:last-child, th:last-child {
  text-align: right;
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
  box-sizing: border-box;
}

.taste-controls {
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding-top: 20px;
}

.slider-title {
  display: flex;
  justify-content: space-between;
}

.slider-with-input {
  display: flex;
  align-items: center;
  gap: 8px;
}

.slider-slider {
  flex: 1;
}

.pour-split {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  margin-top: 4px;
}

.taste-number {
  border: 1px solid #ccc;
  border-radius: 3px;
  padding: 4px 6px;
  width: 70px;
  text-align: center;
  font-size: 14px;
}

.pour2-display {
  font-weight: 600;
}

.button-group {
  display: flex;
  gap: 8px;
  margin-top: 6px;
}

.strength-btn {
  flex: 1;
  padding: 8px 0;
  border: 1px solid #ccc;
  border-radius: 3px;
  background: #f5f5f5;
  cursor: pointer;
  font-size: 14px;
  transition: background 0.15s, border-color 0.15s;

  &:hover {
    background: #e8e8e8;
  }

  &.active {
    background: #333;
    color: #fff;
    border-color: #333;
  }
}
</style>
