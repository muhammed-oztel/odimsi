package main

import "core:crypto/hash"
import "core:encoding/base64"
import "core:fmt"
import "core:os"
import "core:strings"

IMSI_LENGTH :: 15

Hash :: enum {
	Sha256,
	Md5,
}

EncodingType :: enum {
	Base64,
}

start_imsi_processing :: proc(
	selected_country: Country,
	operator: Operator,
	selected_hash: Hash,
	encoding_active: EncodingType,
	search_string: string,
	lookup_file_path: string = "lookup.txt",
) {
	lookup_map := read_lookup_file(lookup_file_path)
	if len(lookup_map) == 0 {
		return
	}

	for l in lookup_map {
		fmt.printfln("lookup value: %s", l)
	}

	found_imsi_values := find_imsi(
		selected_country,
		operator,
		selected_hash,
		encoding_active,
		&lookup_map,
	)

	fmt.printfln("found data: %d", len(found_imsi_values))
	for data in found_imsi_values {
		fmt.printfln("imsi: %s --- hash: %s", data, found_imsi_values[data])
		delete(data)
	}

	delete(found_imsi_values)

	for a in lookup_map {
		delete(a)
	}

	delete(lookup_map)
}

read_lookup_file :: proc(lookup_file_path: string) -> map[string]struct{} {
	set := make(map[string]struct{})

	data, err := os.read_entire_file(lookup_file_path, context.temp_allocator)
	if err != nil {
		return set
	}


	defer free_all(context.temp_allocator)

	it := transmute(string)data

	for line in strings.split_lines_iterator(&it) {
		fmt.printfln("read line: %s", line)
		set[strings.clone(line)] = {}
	}

	return set
}

find_imsi :: proc(
	selected_country: Country,
	operator: Operator,
	selected_hash: Hash,
	encoding_active: EncodingType,
	lookup_data: ^map[string]struct{},
) -> map[string]string {
	str_prefix := fmt.aprint(operator.imsi_prefix_code)
	defer delete(str_prefix)
	remaining_digits := IMSI_LENGTH - len(str_prefix)
	fmt.println(remaining_digits)
	upper_bound := 1_000 //(math.pow10(f32(remaining_digits)) - 1)
	fmt.println(upper_bound)
	results := make(map[string]string)
	for i in 0 ..= upper_bound {
		trial := fmt.aprintf(
			"%[0]d%0*[2][1]d",
			operator.imsi_prefix_code,
			i64(i),
			remaining_digits,
			allocator = context.temp_allocator,
		)
		hashed := hash.hash_string(.SHA256, trial, context.temp_allocator)
		encoded := base64.encode(hashed, allocator = context.temp_allocator)
		encoded_str := transmute(string)encoded
		// fmt.printfln(encoded_str)

		if encoded_str in lookup_data {
			delete_key(lookup_data, encoded_str)
			results[strings.clone(trial)] = strings.clone(encoded_str)
		}

		free_all(context.temp_allocator)
	}

	return results
}
