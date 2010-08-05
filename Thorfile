class Dotfiles < Thor
	include Thor::Actions
	
	DOTFILES = Dir[File.join(File.dirname(__FILE__), '*')].delete_if{|file| file =~ /(README.md|Thorfile)$/ }
	
	desc 'merge', 'Merge dotfiles into home dir'
	method_option :force, :type => :boolean, :default => false, :aliases => '-f'
	method_option :in, :type => :string, :default => '.', :aliases => '-i', :banner => 'IN_DIRECTORY'
	method_option :out, :type => :string, :default => '~', :aliases => '-o', :banner => 'OUT_DIRECTORY'
	def merge
		DOTFILES.each do |file|
			say "Syncing #{File.basename(file)}", Thor::Shell::Color::YELLOW
			diff = `diff #{file} ~/.#{File.basename(file)}`
			if diff.empty?
				say 'No change', Thor::Shell::Color::GREEN
			else
				say "diff #{file} (A) ~/.#{File.basename(file)} (B)", Thor::Shell::Color::BLUE
				say diff
				case ask?("Pick the winner: [abn]").upcase.trim
					when 'A' then FileUtils.copy(file, "~/.#{File.basename(file)}")
					when 'B' then FileUtils.copy("~/.#{File.basename(file)}", file)
					else say "Skipping merge for file #{File.basename(file)}", Thor::Shell::Color::RED
				end
			end
		end
	end
end