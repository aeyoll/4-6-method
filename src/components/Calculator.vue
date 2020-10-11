<template>
  <div class="calculator">
    <div class="well">
      <h2 class="title">Parameters</h2>
      <label for="coffee">Coffee weight:</label>
      <input type="number" v-model="coffee" id="coffee" class="form-control" min="10" max="60">
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
          <tr>
            <td>2m10s</td>
            <td>{{step4}}ml</td>
            <td>{{step1 + step2 + step3 + step4}}ml</td>
          </tr>
          <tr>
            <td>2m45s</td>
            <td>{{step5}}ml</td>
            <td>{{step1 + step2 + step3 + step4 + step5}}ml</td>
          </tr>
          <tr>
            <td>3m30s</td>
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
      coffee: 20
    }
  },
  computed: {
    water() {
      return this.coffee * 15;
    },
    step1() {
      return this.water / 6;
    },
    step2() {
      return this.water / (300 / 70);
    },
    step3() {
      return this.water / 5;
    },
    step4() {
      return this.water / 5;
    },
    step5() {
      return this.water / 5;
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
</style>
