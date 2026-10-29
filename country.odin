package main

Country :: struct {
	id:           int,
	display_name: string,
	short_code:   string,
}

COUNTRIES :: [?]Country {
	{1, "Turkey", "TUR"},
	{2, "Ukraine", "UKR"},
	{3, "United States of America", "USA"},
}
