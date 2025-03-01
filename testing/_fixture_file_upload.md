# `fixture_file_upload` (`Rack::Test::UploadedFile`)

```ruby
path = Rails.root.join("spec/fixtures/data/test.csv")
type = "text/csv"
file = fixture_file_upload(path, type)

# => Rack::Test::UploadedFile.new(path, type)

CSV.foreach(file) do |row|
  # ...
end
```
