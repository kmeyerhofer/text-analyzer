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

## Sources

The data used to create the lexicon came from:
* [http://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html](http://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html)
* [http://www.cs.cornell.edu/people/pabo/movie-review-data](http://www.cs.cornell.edu/people/pabo/movie-review-data)

Some of the Randomized sentence options come from Launch School:
* "Introduction to Programming with Ruby". Written by Launch School, Copyright © 2018 Launch School 

## Citations

* Minqing Hu and Bing Liu. "Mining and Summarizing Customer Reviews." Proceedings of the ACM SIGKDD International Conference on Knowledge Discovery and Data Mining (KDD-2004), Aug 22-25, 2004, Seattle, Washington, USA
* Bo Pang and Lillian Lee, "Seeing stars: Exploiting class relationships for sentiment categorization with respect to rating scales.", Proceedings of the ACL, 2005.
