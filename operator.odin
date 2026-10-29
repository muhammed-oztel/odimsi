package main

import "core:strings"
Operator :: struct {
	name:             string,
	country_id:       int,
	imsi_prefix_code: int,
}

OPERATORS :: [?]Operator {
	{"Turkcell", 1, 28601},
	{"Vodafone TR", 1, 28602},
	{"Turk Telekom", 1, 28603},
	{"AT&T", 2, 310410},
	{"Lifecell", 3, 25506},
}

operators_for_country_id :: proc(
	country_id: int,
	allocator := context.temp_allocator,
) -> []Operator {
	matches := make([dynamic]Operator, allocator)
	for operator in OPERATORS {
		if country_id == operator.country_id {
			append(&matches, operator)
		}
	}

	return matches[:]
}

operators_text_by_country_id :: proc(country_id: int) -> string {
	builder: strings.Builder

	strings.builder_init(&builder, context.temp_allocator)
	i := 0
	for operator in OPERATORS {
		if (country_id == operator.country_id) {
			if i > 0 do strings.write_string(&builder, ";")
			strings.write_string(&builder, operator.name)
			i += 1
		}
	}

	buf := strings.to_string(builder)
	return buf
}

get_operator :: proc(country: Country, index: int) -> Operator {
	i := 0
	for operator in OPERATORS {
		if operator.country_id == country.id {
			if i == index {
				return operator
			}

			i += 1
		}
	}

	return {"Not Found", -1, -1}
}
