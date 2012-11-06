class RComp
  module Helper

    ##
    # Pluralizes a number / phrase pair
    #
    # ex: 
    # plural(1, noun) # '1 noun'
    # plural(3, noun) # '3 nouns'
    # plural(3, geese, geese) # '3 geese'

    def plural(n, singular, plural=nil)
      if n == 1
        "1 #{singular}"
      elsif plural
        "#{n} #{plural}"
      else
        "#{n} #{singular}s"
      end
    end
  end
end
