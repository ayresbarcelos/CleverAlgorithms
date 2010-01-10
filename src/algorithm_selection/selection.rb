# selection.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. All Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

# Description:
# Enumerate a listing of algorithms (list.txt) and locate the approximate number of results
# from a number of different search engines and search domains (google). Rank the listing of 
# algorithms and order the list by the ranking and by the algorithms allocated kingdom. Output
# the results into a file (results.txt).


# sources:
# Screen Scraping Google with Hpricot and Watir: http://refactormycode.com/codes/673-screen-scraping-google-with-hpricot-and-watir
# Scraping with style: scrAPI toolkit for Ruby: http://labnotes.org/2006/07/11/scraping-with-style-scrapi-toolkit-for-ruby/
# How to get the number of results found for a keyword in google: http://stackoverflow.com/questions/1809976/how-to-get-the-number-of-results-found-for-a-keyword-in-google
# Google AJAX Search API + Ruby: http://chris.mowforth.com/post/146052675/google-ajax-search-api-ruby
# Exploring the Google AJAX Search API: http://sophsec.com/research/exploring_ajax_search.html
# Flash and other Non-Javascript Environments (search API): http://code.google.com/apis/ajaxsearch/documentation/#fonje
# Flash and other Non-Javascript Environments (search docs): http://code.google.com/apis/ajaxsearch/documentation/reference.html#_intro_fonje
# Net::HTTP http://ruby-doc.org/stdlib/libdoc/net/http/rdoc/classes/Net/HTTP.html
# Sample code.Python. Perl. Language Ajax api. Post method. 5000. api limit http://osdir.com/ml/GoogleAJAXAPIs/2009-05/msg00118.html
# Hpricot Basics: http://wiki.github.com/whymirror/hpricot/hpricot-basics



require 'rubygems'
module JSON
  VARIANT_BINARY = false # hack - god knows why i need it
end
require 'json'
require 'net/http'
require 'hpricot'


def get_approx_google_web_results(keyword)
  http = Net::HTTP.new('ajax.googleapis.com', 80)
  header = {'content-type'=>'application/x-www-form-urlencoded', 'charset'=>'UTF-8'}
  path = "/ajax/services/search/web?v=1.0&q=#{keyword}&rsz=small"
  resp, data = http.request_get(path, header)
  rs = JSON.parse(data)
  # TODO handle no results
  return rs['responseData']['cursor']['estimatedResultCount']
end

def get_approx_google_book_results(keyword)
  http = Net::HTTP.new('ajax.googleapis.com', 80)
  header = {'content-type'=>'application/x-www-form-urlencoded', 'charset'=>'UTF-8'}
  path = "/ajax/services/search/books?v=1.0&q=#{keyword}&rsz=small"
  resp, data = http.request_get(path, header)
  rs = JSON.parse(data)
  # TODO handle no results
  return rs['responseData']['cursor']['estimatedResultCount']
end

# http://springerlink.com/home/main.mpx
# http://springerlink.com/content/?k=%22genetic+algorithm%22
def get_approx_springer_results(keyword)
  http = Net::HTTP.new('springerlink.com', 80)
  header = {}
  path = "/content/?k=#{keyword}"
  resp, data = http.request_get(path, header)
  doc = Hpricot(data)
  rs = doc.search("//span[@id='ctl00_PageSidebar_ctl01_Sidebarplaceholder1_StartsWith_ResultsCountLabel']")
  return 0 if rs.nil? # no results
  rs = rs.first.inner_html
  rs = rs.split(' ').first.gsub(',', '') # strip comma
  return rs
end

# http://www.scirus.com/
# http://www.scirus.com/srsapp/search?q=%22genetic+algorithm%22&t=all&sort=0&g=s
def get_approx_scirus_results(keyword)
  http = Net::HTTP.new('scirus.com', 80)
  header = {'User-Agent'=>'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1'}
  path = "/srsapp/search?q=#{keyword}&t=all&sort=0&g=s"
  resp, data = http.request_get(path, header)
  doc = Hpricot(data)
  rs = doc.search("//div[@class='headerAllText']")
  return 0 if rs.nil? # no results
  rs = rs.first.inner_html
  rs = rs.split(' ')[2].gsub(',', '') # strip comma
  return rs
end

def get_results(algorithm_name)  
  
  keyword = algorithm_name.gsub(/ /, "+")  #covert spaces to a plus
  keyword = "%22#{keyword}%22" # quote the results
  scores = {}

  # Google Web Search
  scores['google_web'] = get_approx_google_web_results(keyword)
  # Google Book Search
  scores['google_book'] = get_approx_google_book_results(keyword)
  # Google Scholar Search
  scores['google_scholar'] = 0
  # Springer Article Search
  scores['springer'] = get_approx_springer_results(keyword)
  # Scirus Search
  scores['scirus'] = get_approx_scirus_results(keyword)
  
  return scores
end


def rank_algorithm(name)
  # score algorithm
  scores = get_results(name)
  # rank algorithm
  rank = 0 # TODO
  
  puts(" >processed: #{name} - #{scores.inspect}")
  return rank
end

# testing
rank_algorithm("genetic algorithm")