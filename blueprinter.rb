require 'fileutils'
require 'erb'

module Blueprinter
  class Project
    def initialize(options = {})
      raise ArgumentError, "projects_path must be specified" unless options[:projects_path]
      raise ArgumentError, "blueprint_path must be specified" unless options[:blueprint_path]
      raise ArgumentError, "blueprint_prefix must be specified" unless options[:blueprint_prefix]

      @projects_path = options[:projects_path]
      @blueprint_path = options[:blueprint_path]
      @blueprint_prefix = options[:blueprint_prefix]

      @processors = Hash.new

      if options[:processors]
        available_processors = Blueprinter::Processors.instance_methods
        extend Blueprinter::Processors

        options[:processors].each do |processor|
          if available_processors.include? processor
            eval(processor.to_s)
          else
            raise InvalidProcessor, "#{method_name} is not defined."
          end
        end
      end

      raise NotDirectoryError unless File.directory? @projects_path
      raise NotDirectoryError unless File.directory? @blueprint_path
    end

    def init_interactive
      proj_path = nil
      while proj_path == nil
        puts "What's your new project going to be called?"
        proj_name = gets.chomp

        formatted_date = Time.now.strftime "%d-%m-%y"

        proj_path = File.join(@projects_path, "#{proj_name} #{formatted_date}")
        if File.exists? proj_path
          proj_path = nil
          puts "A project by that name already exists"
        end
      end
      
      puts "Starting new project: #{proj_name}"
      init_project(proj_name, proj_path)
      puts "\nBlueprinter has finished!"
      puts "You'll find your new project at: #{proj_path}"
    end

    def init_project(proj_name, proj_path)
      @name = proj_name
      @path = proj_path
      @name_computer_friendly = @name.downcase.gsub(/[ ]+/, "_")

      FileUtils.mkdir(@path)
      FileUtils.cp_r(File.join(@blueprint_path, '.'), @path)
      
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
          prefix_replaced = filepath.gsub(/#{@blueprint_prefix}/, @name_computer_friendly)
          File.rename filepath, prefix_replaced
          filepath = prefix_replaced
        end
        
        # Run post processors
        @processors.each do |pattern, block|
          if filepath.match pattern
            block.call(filepath)
          end
        end
      end
    end
    
    def add_processor(pattern, &block)
      @processors[pattern] = block
    end
  end

  module Processors
    def erb_template
      add_processor(/.erb$/) do |filepath|
        template = nil
        File.open(filepath, 'r') do |file|
          template = ERB.new file.read
        end

        File.open(filepath, 'w') do |file|
          file.truncate(0)
          file.write(template.result(binding))
        end

        new_filepath = filepath.gsub(/.erb$/, '')
        File.rename filepath, new_filepath
      end
    end
  end
  
  class NotDirectoryError < StandardError; end
  class InvalidProcessor < ArgumentError; end
end