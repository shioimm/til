class Dictionary
  def initialize
    @container = {}
    @incremental_count = 0
  end

  def insert(element)
    hash = voiding_collision(to_hash(element))
    container[hash] = element
  end

  def find(element)
    container.keys.include?(to_hash(element)) ? 'yes' : 'no'
  end

  private

    attr_reader :container, :size

    def to_hash(element)
      element.chars.map do |char|
        case char
        when 'A' then 1
        when 'C' then 2
        when 'G' then 3
        when 'T' then 4
        end
      end.sum
    end

    def voiding_collision(hash)
      if container.keys.include?(hash)
        while container.keys.include? hash
          @incremental_count += 1
          hash = @incremental_count + hash
        end
      else
        hash
      end
    end
end

dictionary = Dictionary.new

dictionary.insert('AAA')
dictionary.insert('AAC')
pp dictionary.find('AAA')
pp dictionary.find('CCC')
dictionary.insert('CCC')
pp dictionary.find('CCC')
