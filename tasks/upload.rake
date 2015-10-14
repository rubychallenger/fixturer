task :upload, :file_name do |t,args|
  name = args[:file_name].to_s.split('.')
  factory = FixtureFactory.new(name[1])
  file = Fixture.new(name[0],factory)
  file.save_to_db
end