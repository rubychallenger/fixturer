task :upload do
  factory = FixtureFactory.new('ini')
  file = Fixture.new('User',factory)
  file.save_to_db
end