require 'rexml/document'

class REXML::Elements
  def to_hash
    hash = Hash.new

    self.map{|e| e.name}.uniq.each do |name|
      if self[name].text
        hash[name] = self[name].text
        hash.define_singleton_method(name.to_sym){self[name]}
      else
        unless hash[name]
          hash[name] = []
          hash.define_singleton_method(name.to_sym){self[name]}
        end
        self.each(name) { |e|
          hash[name] << e.elements.to_hash
        }
      end
    end
    
    hash
  end
end

