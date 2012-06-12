require 'fileutils'

module Blueprinter
  class Project
    attr_reader :readme_filepath

    def initialize(options = {})
      raise ArgumentError, "projects_path must be specified" unless options[:projects_path]
      raise ArgumentError, "blueprint_path must be specified" unless options[:blueprint_path]
      raise ArgumentError, "blueprint_prefix must be specified" unless options[:blueprint_prefix]

      @projects_path = options[:projects_path]
      @blueprint_path = options[:blueprint_path]
      @blueprint_prefix = options[:blueprint_prefix]

      raise NotDirectoryError unless File.directory? @projects_path
      raise NotDirectoryError unless File.directory? @blueprint_path
    end

    def init_project_interactive
      proj_path = nil
      while proj_path == nil
        puts "What's your new project going to be called?"
        proj_name = gets.chomp

        formatted_date = Time.now.strftime "%d-%m-%y"

        begin
          proj_path = File.join(@projects_path, "#{proj_name} #{formatted_date}")
        rescue # TODO: Rescue what?
          proj_path = nil
          puts "A project by that name already exists"
        end
      end
      
      init_project(proj_name, proj_path)
      create_readme

      puts "\nYour new project has been built!"
      puts "Would you like to open its readme? [y/n]"
      input = gets.chomp
      if input.match(/^y/)
        # TODO: This seems to hang the script until notepad is closed.
        system('notepad', @readme_filepath)
      end
    end

    def init_project(proj_name, proj_path)
      @name = proj_name
      @path = proj_path
      @name_computer_friendly = @name.downcase.gsub(/[ ]+/, "_")

      FileUtils.mkdir(@path)
      FileUtils.cp_r(File.join(@blueprint_path, '.'), @path)

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

        if file.match(/^#{@blueprint_prefix}/)
          File.rename filepath, filepath.gsub(/#{@blueprint_prefix}/, @name_computer_friendly)
        end
      end
    end

    def create_readme
      @readme_filepath = File.join @path, 'readme.md'
      
      File.open(@readme_filepath, 'w') do |f|
        f.puts <<txt
#{@name}
#{"=" * @name.length}

Project created at: #{Time.now}
txt
      end
    end
  end

  class NotDirectoryError < StandardError; end
end