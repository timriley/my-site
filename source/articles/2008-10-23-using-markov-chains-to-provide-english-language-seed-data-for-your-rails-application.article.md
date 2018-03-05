---
title: Using Markov Chains to provide English language seed data for your Rails application
permalink: 2008/10/23/using-markov-chains-to-provide-english-language-seed-data-for-your-rails-application
published_at: 2008-10-22 14:10:00 +0000
---

I spent a portion of last weekend's Rails Rumble preparing a script that would seed our application's database with test data. Among other things, having a well populated database is useful to fully test all the parts of the application's interface that might not come into play when using a smaller data set. It also gives you the ability to get a true sense of how your app will look and feel after the real users start to pour in content (hopefully!).

For the Rumble project, I used the [faker](http://faker.rubyforge.org/) Ruby gem, which provides methods for generating realistic names, domains and email addresses. It also provides a text generator that pulls random strings from Lorem Ipsum. However, while the app may feel have felt fully populated, seeing the Latin everywhere didn't make it feel _right_.

So for the next project, I will generate random English language strings for the seed data. Rather than pulling words ad hoc from a dictionary or something, we can use [Markov Chains](http://en.wikipedia.org/wiki/Markov_chain) to generate reasonably realistically structured text for us. A bit of searching revealed a [Ruby Quiz page](http://rubyquiz.com/quiz74.html) with an implementation of a text generator using Markov Chains. It explains that the generator:

bq. read[s] some text document(s), making note of which characters commonly follow which characters or which words commonly follow other words (it works for either scale). Then, when generating text, you just select a character or word to output, based on the characters or words that came before it.

I took implementation provided on this page, and added a couple of convenience methods to easily fetch sequences of words or whole sentences:

```
# Courtesy of http://rubyquiz.com/quiz74.html

class MarkovChain
  def initialize(text)
    @words = Hash.new
    wordlist = text.split
    wordlist.each_with_index do |word, index|
    add(word, wordlist[index + 1]) if index <= wordlist.size - 2
   end
  end

  def add(word, next_word)
    @words[word] = Hash.new(0) if !@words[word]
    @words[word][next_word] += 1
  end

  def get(word)
    return "" if !@words[word]
    followers = @words[word]
    sum = followers.inject(0) {|sum,kv| sum += kv[1]}
    random = rand(sum)+1
    partial_sum = 0
    next_word = followers.find do |word, count|
      partial_sum += count
      partial_sum >= random
    end.first
    next_word
  end

  # Convenience methods to easily access words and sentences

  def random_word
    @words.keys.rand
  end

  def words(count = 1, start_word = nil)
    sentence = ''
    word = start_word || random_word
    count.times do
      sentence << word << ' '
      word = get(word)
    end
    sentence.strip.gsub(/[^A-Za-z\s]/, '')
  end

  def sentences(count = 1, start_word = nil)
    word = start_word || random_word
    sentences = ''
    until sentences.count('.') == count
      sentences << word << ' '
      word = get(word)
    end
    sentences
  end
end
```

Then, in my seed data script, I prime a MarkovChain instance with some good literature (I chose Sir Arthur Conan Doyle's _[The Lost World](http://gutenberg.org/etext/139)_ from Project Gutenburg), and then use it to populate my records:

```
mc = MarkovChain.new(File.read("#{RAILS_ROOT}/db/populate_source.txt"))

# create_or_update method taken from http://railspikes.com/2008/2/1/loading-seed-data

1.upto(100) do |comment_id|
  Comment.create_or_update(
    :id => comment_id,
    :title => mc.words(3).titleize,
    :body => mc.sentences(3)
  )
end
```

Done! While the text isn't the kind of fluent prose you'd expect from the real-life internet commenters, it does look much more realistic than Lorem Ipsum, and often provides cause for a bit of a chuckle. An example of the kind of stuff you'll get from The Lost World is below. Feel free to choose your favourite text as the source :)

> Luxurious voyage I had a solemnity as one would no sneer would have just after two surviving Indians in a precipice, and were accompanying to his thumb over his shoulders, the effort.

For some background on how to load seed data into your Rails app, see [this page](http://railspikes.com/2008/2/1/loading-seed-data) on the Rail Spikes blog for a good introduction.

