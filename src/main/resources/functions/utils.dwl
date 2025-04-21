%dw 2.6

import mask from dw::util::Values

// Converts a date to numeric string. ex: 18-JAN-2024 -> 20240118 
fun convertDateToNumber(inDate, format="dd-MMM-yyyy") = if(!isEmpty(inDate)) inDate as Date {format: format} as String {format: "yyyyMMdd"} as Number default 0 else 0

fun translate(domain, code) =
	if (code != null and mapIt(domain, code as String) != null) mapIt(domain, code as String) else code

fun mapIt(domain, code) =
	if (domain ~= 'BOOLEAN')
		codes_1[upper(code)][0]
	else
		code

var codes_1 = [
	{"NO": false},
	{"YES": true}
]

/*
 * Takes an input obj and array of strings that represent the names of fields in the obj, masks specified key values and returns the obj 
 */
fun maskData(obj: Object, keys: Array=[]) : Object | Null = if(isEmpty(obj)) obj else keys reduce ((i, a = obj) -> a mask i with "****")