var app = new Vue({
  el: '#app',
  data: {
    text_to_analyze: '',
    analysis_separator: 'none',
    analyzing: 'Analyze',
    results: [],
    isDisabled: true,
  },
  watch: {
    results: function() {
      this.analyzing = 'Analyze';
    },
    text_to_analyze: function() {
      let text = this.text_to_analyze.length
      if (text >= 1 && text <= 2000) {
        this.isDisabled = false;
      } else {
        this.isDisabled = true;
      }
    },
  },
  methods: {
    analyze: function () {
      let self = this;
      self.analyzing = "Analyzing...";
      axios({
        method:'post',
        url:'/api',
        params: {
          analysis_separator: self.analysis_separator,
          text_to_analyze: self.text_to_analyze
        },
      }).then(function(response) {
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
        result += this.listError(resultArr[0]);
      } else {
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
      result += "class=\"negative\">";
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
  },
})
