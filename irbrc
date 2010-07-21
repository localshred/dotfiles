require 'rubygems'
require 'wirble'
require 'pp'
Wirble.init
Wirble.colorize

class Object  
  def methods_with_sort(filter = nil)  
    methods = methods_without_sort  
    if filter  
      filter  = Regexp.new(filter.to_s, true) unless filter.is_a? Regexp  
      methods = methods.select { |method| method =~ filter }  
    end  
    methods.sort  
  end  
  alias_method :methods_without_sort, :methods  
  alias_method :methods, :methods_with_sort  
  
	def local_methods
	 (methods - Object.instance_methods).sort
	end

end

IRB.conf[:PROMPT_MODE] = :SIMPLE
