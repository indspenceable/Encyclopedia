require 'YAML'
level_name = ARGV[0]
level_path = "editor/levels/#{ARGV[0]}"
scripts_file = level_path + "/scripts.yaml"
map_file = level_path + "/level.yaml"
target_path = "assets/levels/#{ARGV[0]}"

mod_string = 
"module Levels\n"+
"  module #{ARGV[0].capitalize}\n"
YAML.load_file(scripts_file).values.uniq.each do |script|
  puts "LOOKING AT SCRIPT #{script}"
  File.open(level_path+"/#{script}.rb").each do |line|
    mod_string += "    #{line}"
  end
  mod_string += "\n"
end
mod_string += "  end\nend"

`mkdir #{target_path}` unless File.directory?(target_path)
File.new(target_path+"/script_module.rb", "w") << mod_string
`cp #{scripts_file} #{target_path}/scripts.yaml`
`cp #{map_file} #{target_path}/tiles.yaml`



