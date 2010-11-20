LEVEL_PATH = "./editor/levels/"

#lol tricked you
if ARGV.length == 0 
  puts "you just put in a level name. Thats it. come on!"
else
  if ARGV[0] == "new"
    # NEW LEVEL
  elsif File.directory?(LEVEL_PATH + ARGV[0])
    require './editor/editor.rb'
    Editor.new.edit
  else
    puts "That level doesn't exist."
  end
end

