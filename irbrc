require 'rubygems'
require 'pp'
begin
  require 'wirble'
  require 'hirb'
rescue LoadError
  puts 'ignoring wirble and hirb, load error'
end

if defined? Wirble
  Wirble.init
  Wirble.colorize
end

if defined? Hirb
  Hirb::View.enable
end

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
IRB.conf[:AUTO_INDENT] = true
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:EVAL_HISTORY] = 200

if defined? Rails
  Rails.logger = Logger.new(STDOUT)
  Rails.logger.level = Logger::DEBUG
end
