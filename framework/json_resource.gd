@tool
class_name JsonResource
extends RefCounted

const SCRIPT_PROPERTY_NAME = &"script"

var json_resource_path: String

static func stringify(obj: Object, indent: String = "") -> String:
	var packed = {}
	for p in obj.get_property_list():
		if p.name == SCRIPT_PROPERTY_NAME:
			continue
		if not p.usage & PROPERTY_USAGE_STORAGE:
			continue
		packed[p.name] = obj[p.name]
	return JSON.stringify(packed, indent)

static func parse(str: String, type: Object) -> Object:
	if not (type is Script or type.get_class() == "GDScriptNativeClass"):
		push_error("Invalid parse type")
		return null
	var packed = JSON.parse_string(str)
	if packed == null:
		return null
	var obj = type.new()
	for p in obj.get_property_list():
		if p.name == SCRIPT_PROPERTY_NAME:
			continue
		if not p.usage & PROPERTY_USAGE_STORAGE:
			continue
		if p.name not in packed:
			continue
		if p.type == TYPE_ARRAY and p.hint == PROPERTY_HINT_TYPE_STRING:
			var p_arr_type = int(p.hint_string.split(":")[0])
			obj[p.name] = Array(packed[p.name], p_arr_type, "", null)
		else:
			obj[p.name] = packed[p.name]
	return obj

static func save_json(obj: Object, path: String = "") -> Error:
	if obj is JsonResource:
		if not path:
			path = obj.json_resource_path
		if not path:
			push_error("A path must be provided if json_resource_path is empty.")
			return ERR_INVALID_PARAMETER
	else:
		if not path:
			push_error("A path must be provided for non-JsonResource objects.")
			return ERR_INVALID_PARAMETER
	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return FileAccess.get_open_error()
	var str = stringify(obj, "\t")
	file.store_string(str)
	return OK

static func load_json(path: String, type: Object) -> Object:
	var str = FileAccess.get_file_as_string(path)
	if not str:
		var err = FileAccess.get_open_error()
		if err != OK:
			push_error("Failed to open file %s: %s" % [path, error_string(err)])
		else:
			push_error("File is empty: ", path)
		return null
	var obj = parse(str, type)
	if obj is JsonResource:
		obj.json_resource_path = path
	return obj

func save(path: String = "") -> Error:
	return JsonResource.save_json(self, path)
