BLUEPRINT_PATH   = "F:/Video Projects/_BLUEPRINT/"
BLUEPRINT_PREFIX = "_BLUEPRINT"
PROJECTS_PATH    = "F:/Video Projects/"

require 'fileutils'

module Blueprinter
	class Project
		attr_reader :readme_filepath

		def init_project_interactive
			proj_path = nil
			while proj_path == nil
				puts "What's your new project going to be called?"
				proj_name = gets.chomp

				formatted_date = Time.now.strftime "%d-%m-%y"

				begin
					proj_path = File.join(PROJECTS_PATH, "#{proj_name} #{formatted_date}")
				rescue # TODO: Rescue what?
					proj_path = nil
					puts "A project by that name already exists"
				end
			end
			init_project(proj_name, proj_path)
		end

		def init_project(proj_name, proj_path)
			@name = proj_name
			@path = proj_path
			@name_computer_friendly = @name.downcase.gsub(/[ ]+/, "_")

			FileUtils.mkdir(@path)
			FileUtils.cp_r(File.join(BOOTSTRAP_PATH, '.'), @path)

			puts "Starting new project:   #{@name}"
			puts "You'll find it at:      #{@path}"

			process_copied_files(@path)
		end

		def process_copied_files(path)
			Dir.chdir(path)

			files = Dir.glob('*')
			files.each do |file|
				filepath = File.join(path, file)

				if File.directory? filepath
					process_copied_files(filepath)
				end

				if file.match(/^#{BOOTSTRAP_PREFIX}/)
					File.rename filepath, filepath.gsub(/#{BOOTSTRAP_PREFIX}/, @name_computer_friendly)
				end
			end
		end

		def create_readme
			@readme_filepath = File.join @path, 'readme.md'
			
			File.open(@readme_filepath, 'w') do |f|
				f.puts <<txt
#{@name}
#{md_title_underline(@name)}

Project created at: #{Time.now}
by Alex Plescan
txt
			end
		end

		private
		def md_title_underline(str)
			result = String.new
			str.length.times { result << "=" }
			result
		end
	end

	class NotDirectoryError < StandardError; end
end

# Executed if script is called from command line.
# This method begins an interactive session for creating your new project.
def run!
	raise NotDirectoryError unless File.directory? BOOTSTRAP_PATH
	raise NotDirectoryError unless File.directory? PROJECTS_PATH

	a = Blueprinter::Project.new
	a.init_project_interactive
	a.create_readme

	puts "\nYour new project has been built!"
	puts "Would you like to open its readme? [y/n]"
	
	input = gets.chomp
	if input.match(/^y/)
		puts a.readme_filepath
		# TODO: This seems to hang the script until notepad is closed.
		system('notepad', a.readme_filepath)
	end
end

run! if __FILE__ == $0