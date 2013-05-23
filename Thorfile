class Dotfiles < Thor
	include Thor::Actions

	DOTFILES = Dir[File.join(File.dirname(__FILE__), '*')].delete_if{|file| file =~ /(README.md|Thorfile)$/ }

	desc 'merge', 'Merge dotfiles into home dir'
	method_option :force, :type => :boolean, :default => false, :aliases => '-f'
	method_option :in, :type => :string, :default => '.', :aliases => '-i', :banner => 'IN_DIRECTORY'
	method_option :out, :type => :string, :default => '~', :aliases => '-o', :banner => 'OUT_DIRECTORY'
	def merge
		DOTFILES.each do |file|
		  base = "~/.#{File.basename(file)}"
		  expanded_base = File.expand_path(base)
			say "Syncing #{base}", :yellow
			if File.exist?(expanded_base)
  			diff = `diff #{file} #{base}`
  			if diff.empty?
  				say 'No change', :green
  			else
  				say "diff [A] #{file} [B] #{base}", :blue
  				say diff
  				case ask("Pick the winner: [abs]").upcase.strip
  				when 'A' then

  				  FileUtils.rm(expanded_base)
  				  FileUtils.copy(file, expanded_base)
  				when 'B' then
  				  FileUtils.rm(file)
  				  FileUtils.copy(expanded_base, file)
  				else
  				  say "Skipping merge for file #{base}", :red
  				end
  			end
			else
			  if File.directory?(file)
  			  say "Creating directory #{base}", :yellow
			    FileUtils.cp_r(file, expanded_base)
		    else
		      say "Creating file #{base}", :yellow
  			  FileUtils.copy(file, expanded_base)
			  end
		  end
		end
	end
end
