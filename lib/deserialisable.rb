module Deserialisable
  def root(selector)
    @__root = selector
    @__elements = {}
  end

  def element(name, selector, type=String)
    @__elements[name] = [selector, type]
  end

  def from_xml(data)
    doc = Nokogiri::XML(data).css(@__root)

    attrs = @__elements.map {|name, (selector, type)|
      value = doc.css(selector).children.to_s

      if type.respond_to?(:parse)
        value = type.parse(value)
      end

      [name, value]
    }
    attrs = Hash[attrs]

    attrs.each do |key, value|
      define_method key do
        instance_variable_get(:@attrs)[key]
      end
    end

    obj = new
    obj.instance_variable_set(:@attrs, attrs)
    obj
  end
end
