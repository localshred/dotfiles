require 'fileutils'

describe "Dotfiles Merge Util" do
	
	let(:thor_dir) { File.expand_path(File.join(File.dirname(__FILE__), '..')) }
	
	let(:default_dir) { File.join(thor_dir, 'spec','data', 'default') }
	let(:default_files) { Dir[File.join(default_dir, '*')] }
	
	let(:in_dir) { File.join(thor_dir, 'spec', 'data', 'in') }
	let(:in_files) { Dir[File.join(in_dir, '*')] }
	
	let(:out_dir) { File.join(thor_dir, 'spec', 'data', 'out') }
	let(:out_files) { Dir[File.join(out_dir, '*')] }
	
	before :each do
		# Clear in dir
		in_files.each do |file|
			File.delete(file)
		end
		
		# Clear out dir
		out_files.each do |file|
			File.delete(file)
		end
		
		# Copy defaults to their location
		default_files.each do |file|
			dest = File.basename(file) == 'test_in' ? in_dir : out_dir
			FileUtils.copy(file, File.join(dest, File.basename(file)))
		end
	end
	
	it "should ignore merges when neither a nor b is chosen" do
		IO.popen("cd #{thor_dir} && thor dotfiles:merge -i #{in_dir} -o #{out_dir}", 'w+') do |io|
			$stdout.puts "\n"
		end
		File.exists?(File.join(out_dir, File.basename(default_files.first))).should_not be_true
	end
	
	it "should allow in to out merge" do
		IO.popen("cd #{thor_dir} && thor dotfiles:merge -i #{in_dir} -o #{out_dir}", 'w+') do |io|
			$stdout.puts "\n"
		end
		File.exists?(File.join(out_dir, File.basename(default_files.first))).should_not be_true
	end
	
end