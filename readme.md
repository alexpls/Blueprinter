Blueprinter
===========

Helps set up new projects based on a reusable directory structure.

Example usage:

```ruby
require 'blueprinter'

Blueprinter::Project.new(
  projects_path: "F:/Video Projects/",
  blueprint_path: "F:/Video Projects/_BLUEPRINT/",
  blueprint_prefix: "_BLUEPRINT"
).init_project_interactive
```