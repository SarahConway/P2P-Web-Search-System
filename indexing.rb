require 'ap'

class Indexing

  def initialize
    @indexes = {}
  end


  # Add a new index
  def addIndex(keyword, url)
    if @indexes.has_key?(keyword)                                  # If keyword already in indexes
      if !@indexes[keyword].detect{|x| x[:url] == url}.nil?        # if URL already in indexes
        @indexes[keyword].detect{|x| x[:url] == url}[:rank] += 1   # Increase URL rank
      else
        @indexes[keyword].push({:url => url, :rank => 1})          # Add new URL for this keyword
      end
    else
      @indexes[keyword] = [{:url => url, :rank => 1}]              # Add new keyword
    end
    puts('INDEX')
    ap @indexes, :index => false
  end


  # Get all indexes for a given keyword
  def getKeywordIndexes(keyword)
    return @indexes[keyword]
  end
end