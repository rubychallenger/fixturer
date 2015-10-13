task :import do
  Dir.glob('fixtures/*').select {|f| f =~ /.(json|ini)$/}.each do |file|
    if File.extname(file) == '.ini'
      Fixture.new(File.basename(file,'.*'),IniFactory).save_to_db
    else
      Fixture.new(File.basename(file,'.*'),JsonFactory).save_to_db
    end
  end
end