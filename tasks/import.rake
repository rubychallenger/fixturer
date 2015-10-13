task :import do
  Dir.glob('fixtures/*').select {|f| f =~ /.(json|ini)$/}.each do |file|
    if File.extname(file) == '.ini'
      Fixture.new(File.basename(file,'.*'),IniFactory).save_to_db
    elsif File.extname(file) == '.json'
      Fixture.new(File.basename(file,'.*'),JsonFactory).save_to_db
    else
      puts "Unsupported extension"
    end
  end
end