module server

go 1.24.2

replace server/functions => ./functions

require (
	server/data v0.0.0-00010101000000-000000000000
	server/functions v0.0.0-00010101000000-000000000000
)

replace server/data => ./data
