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
        self.results.unshift(response.data);
      });
    },
    formatResult: function(resultArr) {
      let result = '';
      for (let i = 0; i < resultArr.length; i += 1) {
        result += "<span ";
        result += "class=\"" + resultArr[i].css_result + "\"";
        result += "title=\"" + resultArr[i].positive_percent + " positive, ";
        result += resultArr[i].negative_percent + " negative\">";
        result += resultArr[i].text
        result += "</span>"
        if (i != resultArr.length - 1) {
          result += " "
        }
      }
      return result;
    },
    clearEntries: function() {
      this.results.splice(0);
    },
  },
})
