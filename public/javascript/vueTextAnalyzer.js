var app = new Vue({
  el: '#app',
  data: {
    text_to_analyze: '',
    analysis_separator: 'none',
    analyzing: 'Analyze',
    results: [],
    isDisabled: true,
    disabledError: 'Input text.',
    textCounter: 0,
    textCounterError: {
      'counter-error': false,
    },
  },
  watch: {
    results: function() {
      this.analyzing = 'Analyze';
    },
    text_to_analyze: function() {
      let text = this.text_to_analyze.length;
      this.adjustTextCounter(text);
      if (text >= 1 && text <= 2000) {
        this.isDisabled = false;
        this.disabledError = '';
      } else if (text > 2000) {
        this.isDisabled = true;
        this.disabledError = 'Text cannot exceed 2000 characters.';
      } else if (text < 1 ){
        this.isDisabled = true;
        this.disabledError = 'Input text.';
      }
    },
    textCounter: function() {
      if (this.textCounter > 2000) {
        this.textCounterError["counter-error"] = true;
      } else {
        this.textCounterError["counter-error"] = false;
      }
    },
  },
  methods: {
    analyze: function () {
      let self = this;
      self.analyzing = "Analyzing...";
      let formData = new FormData();
      formData.append('text_to_analyze', self.text_to_analyze);
      formData.append('analysis_separator', self.analysis_separator);
      headers = { headers: { 'Content-Type': 'multipart/form-data' } };
      axios.post('/api', formData, headers)
      .then(function(response) {
        if (response.data.error) {
          self.results.unshift([response.data]);
        } else {
          self.results.unshift(response.data);
        }
      }).catch(function(error) {
        self.results.unshift(self.formatError(error.message));
      })
    },
    formatResult: function(resultArr) {
      let result = '';
      if (resultArr[0].error) {
        // Formats error message
        result += this.listError(resultArr[0]);
      } else {
        // Formats analyzed text
        for (let i = 0; i < resultArr.length; i += 1) {
          result += this.listResult(resultArr[i]);
          if (i != resultArr.length - 1) {
            result += " ";
          }
        }
      }
      return result;
    },
    listResult: function(resultItem) {
      let result = '';
      result += "<span ";
      result += "class=\"" + resultItem.css_result + "\"";
      result += "title=\"" + resultItem.positive_percent + " positive, ";
      result += resultItem.negative_percent + " negative\">";
      result += resultItem.text;
      result += "</span>";
      return result;
    },
    listError: function(error) {
      let result = '';
      result += "<span ";
      result += "class=\"error\">";
      result += error.error;
      result += "</span>";
      return result;
    },
    formatError: function(message) {
      let result = [];
      result.push({ "error": message });
      return result;
    },
    clearEntries: function() {
      this.results.splice(0);
    },
    adjustTextCounter(textLength) {
      this.textCounter = textLength;
    },
  },
})
