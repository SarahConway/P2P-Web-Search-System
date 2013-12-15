class Indexing

  def initialize
    @indexes = {}
  end

  # Add a new index
  def addIndex(keyword, url)
    if @indexes.has_key?(keyword)                                  # If keyword already in indexes
      #puts('KEYWORD EXISTS')
      if !@indexes[keyword].detect{|x| x[:url] == url}.nil?        # if URL already in indexes
        #puts('URL EXISTS')
        @indexes[keyword].detect{|x| x[:url] == url}[:rank] += 1   # Increase URL rank
      else
        #puts('ADDING NEW URL')
        @indexes[keyword].push({:url => url, :rank => 1})          # Add new URL for this keyword
      end
    else
      #puts('ADDING NEW KEYWORD')
      @indexes[keyword] = [{:url => url, :rank => 1}]              # Add new keyword
    end
    #puts('INDEX')
    #puts(@indexes)
  end

  # Get all indexes for a given keyword
  def getKeywordIndexes(keyword)
    puts('GETTING INDEXES')
    puts(keyword)
    puts(@indexes)
    puts(@indexes[keyword])
    return @indexes[keyword]
  end

  # Delete an index
  def removeIndex(url)

  end

  # Find a specific index
  def findIndex(url)

  end

  # Update the rank of an index
  def updateRank(url, rank)

  end
end