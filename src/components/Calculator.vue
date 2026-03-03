<template>
  <div class="calculator">
    <div class="language-float" :aria-label="t('language.label')" role="group">
      <button
        type="button"
        class="language-link"
        :class="{ 'is-active': locale === 'en' }"
        @click="locale = 'en'"
      >
        EN
      </button>
      <span class="language-divider">|</span>
      <button
        type="button"
        class="language-link"
        :class="{ 'is-active': locale === 'uk' }"
        @click="locale = 'uk'"
      >
        UA
      </button>
    </div>

    <div class="well">
      <h2 class="title">{{t('title.parameters')}}</h2>
      <label for="coffee">{{t('label.coffeeWeight')}}</label>
      <input type="number" v-model="coffee" id="coffee" class="form-control" min="10" max="60">
      <div class="taste-controls">
        <label>{{t('label.tasteControls')}}</label>
        <div class="slider-row">
          <div class="slider-title">
            <span>{{t('taste.brighter')}}</span>
            <span>{{t('taste.sweeter')}}</span>
          </div>
          <input
            type="range"
            class="slider-slider"
            min="0.4166666667"
            max="0.5833333333"
            step="any"
            v-model.number="taste"
          >
        </div>
        <div class="slider-row">
          <div class="slider-title">
            <span>{{t('strength.light')}}</span>
            <span>{{t('strength.medium')}}</span>
            <span>{{t('strength.strong')}}</span>
          </div>
          <input
            class="slider-slider"
            type="range"
            id="strength-slider"
            min="1"
            max="3"
            step="1"
            v-model.number="strength"
          >
        </div>
      </div>
    </div>

    <div class="well">
      <h2 class="title">{{t('title.data')}}</h2>
      <table>
        <tr>
          <td>{{t('data.coffee')}}</td>
          <td>{{coffee}}{{t('unit.g')}}</td>
        </tr>
        <tr>
          <td>{{t('data.water')}}</td>
          <td>{{water}}{{t('unit.ml')}}</td>
        </tr>
        <tr>
          <td>{{t('data.temperature')}}</td>
          <td>93°C</td>
        </tr>
      </table>
    </div>

    <div class="well instructions">
      <h2 class="title">{{t('title.instructions')}}</h2>
      <div class="timer-box">
        <div class="timer-clock">{{formattedElapsedClock}}</div>
        <div class="timer-controls">
          <button class="timer-btn" @click="startTimer" :disabled="isTimerRunning">{{t('button.start')}}</button>
          <button class="timer-btn" @click="pauseTimer" :disabled="!isTimerRunning">{{t('button.pause')}}</button>
          <button class="timer-btn" @click="resetTimer">{{t('button.reset')}}</button>
        </div>
        <label class="sound-toggle">
          <input v-model="soundEnabled" type="checkbox">
          {{t('label.enableSound')}}
        </label>
        <p class="timer-status" :class="{ 'is-cue': activePourCue || isRemoveStepActive }">{{timerStatusMessage}}</p>
      </div>
      <table>
        <thead>
          <tr>
            <th>{{t('table.totalTime')}}</th>
            <th>{{t('table.waterPerPour')}}</th>
            <th>{{t('table.totalWater')}}</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(pour, index) in pourPlan"
            :key="`pour-${index}`"
            :class="{ 'is-active': activePourIndex === index }"
          >
            <td>{{formatInstructionTime(pour.timeSeconds)}}</td>
            <td>{{pour.amount}}{{t('unit.ml')}}</td>
            <td>{{pour.cumulative}}{{t('unit.ml')}}</td>
          </tr>
          <tr :class="{ 'is-active': isRemoveStepActive }">
            <td>{{removeDripperTimeLabel}}</td>
            <td></td>
            <td>{{t('action.removeDripper')}}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="description">
      <h1>{{t('desc.title')}}</h1>
      <h2>{{t('desc.subtitle')}}</h2>

      <ol>
        <li>{{t('desc.step.rinse')}}</li>
        <li>{{t('desc.step.divide')}}</li>
      </ol>

      <h2>{{t('desc.tipsTitle')}}</h2>
      <ul>
        <li>{{t('desc.tip.grind')}}</li>
        <li>{{t('desc.tip.firstPour')}}</li>
        <li>{{t('desc.tip.wait')}}</li>
      </ul>
    </div>
  </div>
</template>

<script>
import TRANSLATIONS from '../i18n/translations';

export default {
  name: 'Calculator',
  data() {
    return {
      coffee: 20,
      taste: 6/12,
      strength: 3,
      locale: 'en',
      elapsedSeconds: 0,
      timerInterval: null,
      soundEnabled: false,
      audioContext: null,
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
    },
    removeDripperTimeSeconds(newLimit) {
      if (this.elapsedSeconds > newLimit) {
        this.elapsedSeconds = newLimit;
      }
      if (this.isTimerRunning && this.elapsedSeconds >= newLimit) {
        this.pauseTimer();
      }
    },
    locale: {
      immediate: true,
      handler(newLocale) {
        if (typeof window === 'undefined') {
          return;
        }

        const normalizedLocale = TRANSLATIONS[newLocale] ? newLocale : 'en';
        window.localStorage.setItem('locale', normalizedLocale);
        document.documentElement.lang = normalizedLocale;
      },
    },
    elapsedSeconds(newSeconds, previousSeconds) {
      this.handleCueNotifications(previousSeconds, newSeconds);
    }
  },
  created() {
    if (typeof window === 'undefined') {
      return;
    }

    const storedLocale = window.localStorage.getItem('locale');
    if (storedLocale && TRANSLATIONS[storedLocale]) {
      this.locale = storedLocale;
      return;
    }

    const browserLocale = (window.navigator.language || '').toLowerCase();
    if (browserLocale.startsWith('uk')) {
      this.locale = 'uk';
    }
  },
  beforeUnmount() {
    this.pauseTimer();
    if (this.audioContext && typeof this.audioContext.close === 'function') {
      this.audioContext.close();
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
      return Math.round(this.firstPartWater * (1 - this.taste));
    },
    step2() {
      return this.firstPartWater - this.step1;
    },

    // 4:6 method: rest 60% of water is distributed between 1-3 pours depending on desired strength:
    secondPartPours() {
      const pours = Number(this.strength);
      const total = this.secondPartWater;
      const base = Math.floor(total / pours);
      const remainder = total % pours;

      return Array.from({ length: pours }, (_, index) => {
        return index < remainder ? base + 1 : base;
      });
    },
    step3() {
      return this.secondPartPours[0] || 0;
    },
    step4() {
      return this.secondPartPours[1] || 0;
    },
    step5() {
      return this.secondPartPours[2] || 0;
    },
    pourPlan() {
      const amounts = [this.step1, this.step2, this.step3, this.step4, this.step5];
      const times = [0, 45, 90, 135, 180];

      let cumulative = 0;
      return amounts
        .filter((amount) => amount > 0)
        .map((amount, index) => {
          cumulative += amount;
          return {
            amount,
            cumulative,
            timeSeconds: times[index],
          };
        });
    },
    removeDripperTimeSeconds() {
      return 90 + (Number(this.strength) * 45);
    },
    removeDripperTimeLabel() {
      return this.formatInstructionTime(this.removeDripperTimeSeconds);
    },
    isTimerRunning() {
      return this.timerInterval !== null;
    },
    formattedElapsedClock() {
      const minutes = Math.floor(this.elapsedSeconds / 60);
      const seconds = this.elapsedSeconds % 60;

      return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
    },
    activePourIndex() {
      for (let index = 0; index < this.pourPlan.length; index += 1) {
        const currentTime = this.pourPlan[index].timeSeconds;
        const nextTime = index === this.pourPlan.length - 1
          ? this.removeDripperTimeSeconds
          : this.pourPlan[index + 1].timeSeconds;

        if (this.elapsedSeconds >= currentTime && this.elapsedSeconds < nextTime) {
          return index;
        }
      }

      return -1;
    },
    isRemoveStepActive() {
      return this.elapsedSeconds >= this.removeDripperTimeSeconds;
    },
    activePourCue() {
      const cueDurationSeconds = 3;

      for (let index = 0; index < this.pourPlan.length; index += 1) {
        const pour = this.pourPlan[index];
        if (
          this.elapsedSeconds >= pour.timeSeconds &&
          this.elapsedSeconds < pour.timeSeconds + cueDurationSeconds
        ) {
          return {
            index,
            ...pour,
          };
        }
      }

      return null;
    },
    timerStatusMessage() {
      if (this.elapsedSeconds >= this.removeDripperTimeSeconds) {
        return this.t('status.removeNow');
      }

      if (this.activePourCue) {
        return this.t('status.pourNow', {
          index: this.activePourCue.index + 1,
          amount: this.activePourCue.amount,
          unit: this.t('unit.ml'),
        });
      }

      if (!this.isTimerRunning && this.elapsedSeconds === 0) {
        return this.t('status.pressStart');
      }

      if (!this.isTimerRunning && this.elapsedSeconds < this.removeDripperTimeSeconds) {
        return this.t('status.paused');
      }

      const nextPour = this.pourPlan.find((pour) => pour.timeSeconds > this.elapsedSeconds);
      if (nextPour) {
        return this.t('status.nextPourIn', {
          seconds: nextPour.timeSeconds - this.elapsedSeconds,
          unit: this.t('time.secondShort'),
        });
      }

      return this.t('status.removeIn', {
        seconds: this.removeDripperTimeSeconds - this.elapsedSeconds,
        unit: this.t('time.secondShort'),
      });
    },
  },
  methods: {
    t(key, params = {}) {
      const localeMessages = TRANSLATIONS[this.locale] || TRANSLATIONS.en;
      const template = localeMessages[key] || TRANSLATIONS.en[key] || key;

      return template.replace(/\{(\w+)\}/g, (full, token) => {
        if (Object.prototype.hasOwnProperty.call(params, token)) {
          return String(params[token]);
        }
        return full;
      });
    },
    formatInstructionTime(totalSeconds) {
      if (totalSeconds < 60) {
        return `${totalSeconds}${this.t('time.secondShort')}`;
      }

      const minutes = Math.floor(totalSeconds / 60);
      const seconds = totalSeconds % 60;

      return `${minutes}${this.t('time.minuteShort')}${String(seconds).padStart(2, '0')}${this.t('time.secondShort')}`;
    },
    startTimer() {
      if (this.isTimerRunning) {
        return;
      }

      this.ensureAudioContext();
      this.handleCueNotifications(this.elapsedSeconds - 1, this.elapsedSeconds);

      this.timerInterval = setInterval(() => {
        const nextValue = this.elapsedSeconds + 1;
        if (nextValue >= this.removeDripperTimeSeconds) {
          this.elapsedSeconds = this.removeDripperTimeSeconds;
          this.pauseTimer();
          return;
        }
        this.elapsedSeconds = nextValue;
      }, 1000);
    },
    pauseTimer() {
      if (!this.timerInterval) {
        return;
      }

      clearInterval(this.timerInterval);
      this.timerInterval = null;
    },
    resetTimer() {
      this.pauseTimer();
      this.elapsedSeconds = 0;
    },
    handleCueNotifications(previousSeconds, newSeconds) {
      if (!this.soundEnabled) {
        return;
      }

      const lastSeconds = typeof previousSeconds === 'number' ? previousSeconds : newSeconds - 1;
      const notifications = this.pourPlan.map((pour) => ({
        timeSeconds: pour.timeSeconds,
        type: 'pour',
      }));
      notifications.push({
        timeSeconds: this.removeDripperTimeSeconds,
        type: 'finish',
      });

      notifications.forEach((notification) => {
        if (lastSeconds < notification.timeSeconds && newSeconds >= notification.timeSeconds) {
          this.playNotificationTone(notification.type);
        }
      });
    },
    ensureAudioContext() {
      if (this.audioContext) {
        if (this.audioContext.state === 'suspended') {
          this.audioContext.resume();
        }
        return;
      }

      const AudioContextClass = window.AudioContext || window.webkitAudioContext;
      if (AudioContextClass) {
        this.audioContext = new AudioContextClass();
      }
    },
    playNotificationTone(type) {
      if (!this.audioContext) {
        return;
      }

      const now = this.audioContext.currentTime;
      const oscillator = this.audioContext.createOscillator();
      const gain = this.audioContext.createGain();
      const baseFrequency = type === 'finish' ? 640 : 880;

      oscillator.type = 'sine';
      oscillator.frequency.setValueAtTime(baseFrequency, now);
      gain.gain.setValueAtTime(0.0001, now);
      gain.gain.exponentialRampToValueAtTime(0.2, now + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.0001, now + 0.18);

      oscillator.connect(gain);
      gain.connect(this.audioContext.destination);

      oscillator.start(now);
      oscillator.stop(now + 0.2);
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

.language-float {
  align-items: center;
  display: flex;
  gap: 6px;
  position: fixed;
  right: 36px;
  top: 36px;
  z-index: 20;
}

.language-link {
  background: none;
  border: 0;
  color: #2c3e50;
  cursor: pointer;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.04em;
  padding: 5px 10px;
}

.language-link.is-active {
  text-decoration: underline;
}

.language-divider {
  color: #7a7a7a;
  font-size: 12px;
}

.timer-box {
  border: 1px solid #eee;
  border-radius: 5px;
  margin-bottom: 16px;
  padding: 12px;
}

.timer-clock {
  font-size: 28px;
  font-weight: 700;
  text-align: center;
}

.timer-controls {
  display: flex;
  gap: 8px;
  justify-content: center;
  margin-top: 10px;
}

.timer-btn {
  background-color: #f5f5f5;
  border: 1px solid #ccc;
  border-radius: 3px;
  cursor: pointer;
  padding: 6px 12px;
}

.timer-btn:disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

.timer-status {
  font-size: 22px;
  font-weight: 700;
  margin: 10px 0 0;
  text-align: center;
}

.timer-status.is-cue {
  color: #1b4f91;
}

.sound-toggle {
  align-items: center;
  display: flex;
  font-size: 13px;
  font-weight: 400;
  gap: 8px;
  justify-content: center;
  margin-top: 10px;
}

.is-active {
  background-color: #f7fbff;
}

</style>
