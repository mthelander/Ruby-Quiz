module RubyQuiz
  class GedcomParser
    def parse(gedcom)
      root = XMLItem.new(nil, nil, 'gedcom')
      gedcom.scan /(\d+) +(?:([A-Z]{3,4})|(@\w+@)) +(.+)/ do |m|
        level, tag, id, data = m
        item = XMLItem.new(id, data, tag)

        n = root
        level.to_i.times { n = n.children.last }
        n.children << item
      end

      root.to_s
    end
  end

  class XMLItem
    attr_accessor :children
    def initialize(id, data, tag)
      @id, @data, @tag, @children = id, data, (tag || data).downcase, []
      @data = nil unless @id.nil?
    end

    def to_s
      @sub = @children.empty? ? @data : @children * ?\n
      @attributes = [ @tag ]
      @attributes << %Q{id="#@id"} unless @id.nil?
      @attributes << %Q{value="#@data"} unless @children.empty? || @data.nil?
      @attributes = @attributes * ?\s
      %Q{
<#@attributes>
  #@sub
</#@tag>
      }
    end
  end
end
