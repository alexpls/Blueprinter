Blueprinter
===========

Helps set up new projects based on a reusable directory structure.

Example usage:

```ruby
require 'blueprinter'

Blueprinter::Project.new(
  projects_path: "F:/Video Projects/",
  blueprint_path: "F:/_BLUEPRINT/",
  blueprint_prefix: "_BLUEPRINT",
  processors: [:erb_template]
).init_project_interactive
```

Defining custom processors
--------------------------

Blueprinter allows you to define your own custom processors through the *add_processor* method. This method takes a regex match object as an argument, as well as a block. The block passed in will be invoked with a filepath for each file that matches the regex argument.

Example usage:
```ruby
require 'blueprinter'

proj = Blueprinter::Project.new(
  projects_path: "F:/Video Projects/",
  blueprint_path: "F:/_BLUEPRINT/",
  blueprint_prefix: "_BLUEPRINT",
)
proj.add_processor(/.txt$/) do |filepath|
  # Adds a timestamp marker to the end of each text file.
  File.open(filepath, 'a') do |f|
    f.write "\nTimestamp: #{Time.now}"
  end
end
proj.init_interactive
```