# Naive Bayes Text Analyzer

Using the [nbayes gem](https://github.com/oasic/nbayes) to train and classify text input, this text analyzer processes input against a lexicon containing positive and negative opinion words and *Rotten Tomatoes* movie reviews.

## To setup locally
First: 
`git clone https://github.com/kmeyerhofer/text-analyzer.git && cd text-analyzer`

Then:
`bundle install`

Then:
`bundle exec rake lexicon` to create the full lexicon .yml file.

Then: 
`ruby analyzer.rb`

Direct your browser to `localhost:4567` and input any phrase you'd like to analyze.
