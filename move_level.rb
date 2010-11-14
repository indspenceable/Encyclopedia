module Gen
  def self.setup
    @level_name = ARGV[0]
    @indent = 0
    @level_text = ""
    @level_file = ""
    @script_file = "" 

    # GET THE TEXT FOR SCRIPTS AND FOR 
    require 'YAML'
    File.new("editor/levels/#{ARGV[0]}/level.yaml").each_line do |text|
      @level_file += text.strip
    end
    File.new("editor/levels/#{ARGV[0]}/scripts.yaml").each_line do |text|
      @script_file += text.strip
    end
  end

  def self.line text
    @level_text += " " * @indent
    @level_text += text
    @level_text += "\n"
    if block_given?
      @indent += 2
      yield
      @indent -= 2
      line "end"
    end 
  end 

  def self.generate
    line 'require "YAML"'
    line '' 
    line "class #{ARGV[0]}" do
      line "def initialize" do
        line "@scripts = YAML.load(#{@script_file})"
        line "@tiles = YAML.load(#{@level_file})"
      end
    end

    File.open("output.rb","w") do |f|
      f << @level_text
    end
  end
end

Gen::setup
Gen::generate
