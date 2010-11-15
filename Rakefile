task :import_levels => [:clean_levels] do
  targets = FileList['editor/levels/*'].map{ |f| /\Aeditor\/levels\/(.*)\z/.match(f)[1] }.each do |f|
    `ruby compile_level.rb #{f}`
  end
end

task :clean_levels do
  `rm -rf assets/levels/*`
end
