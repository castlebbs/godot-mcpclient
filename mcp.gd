extends Node

var json_result = null
var thread: Thread
var output_array = []
var exit_code = -1

func _ready():
	execute_mcptools_command()

func execute_mcptools_command():
	var script_path: String
	
	# Detect platform and use appropriate script
	if OS.get_name() == "Windows":
		script_path = ProjectSettings.globalize_path("res://mcp.bat")
	else:
		script_path = ProjectSettings.globalize_path("res://mcp.sh")
	
	var arguments = PackedStringArray([
		"Love sports",
		"4"  # Number of assets to generate
	])
	
	# Create and start thread for non-blocking execution
	thread = Thread.new()
	thread.start(_execute_in_thread.bind(script_path, arguments))
	print("Command started in background thread using: ", script_path)

func _execute_in_thread(path: String, arguments: PackedStringArray):
	# Execute command and capture both stdout and stderr
	exit_code = OS.execute(path, arguments, output_array, true)
	
	# Call deferred to handle results on main thread
	call_deferred("_on_command_finished")

func _on_command_finished():
	print("Command finished with exit code: ", exit_code)
	
	# Wait for thread to complete and clean up
	if thread:
		thread.wait_to_finish()	
		thread = null
	
	# Process the results
	finalize_output()

func finalize_output():
	var output_text = ""
	
	# OS.execute appends all output to the array as strings
	if output_array.size() > 0:
		output_text = output_array[0]
		print("Command output length: ", output_text.length(), " characters")
	
	# If we captured stderr (when read_stderr was true), it might be mixed with stdout
	# or in some cases might be separate - this depends on the OS implementation
	
	if output_text.length() > 0:
		print("Parsing JSON output...")
		save_output_to_file(output_text)
		parse_json_output(output_text)
	else:
		print("No output received")
		if exit_code != 0:
			print("Command failed with exit code: ", exit_code)

func save_output_to_file(output: String):
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "user://mcp_output_" + timestamp + ".txt"
	
	var file = FileAccess.open(filename, FileAccess.WRITE)
	if file:
		file.store_string(output)
		file.close()
		print("Output saved to: ", filename)
	else:
		print("Failed to save output to file")

func parse_json_output(output: String):
	var cleaned_output = output.strip_edges()
	
	var json = JSON.new()
	var parse_result = json.parse(cleaned_output)
	
	if parse_result == OK:
		json_result = json.data
		print("JSON parsed successfully! Result type: ", typeof(json_result))
		handle_json_result(json_result)
	else:
		print("Failed to parse JSON: ", json.get_error_message())
		print("Output preview (first 500 chars): ", cleaned_output.substr(0, min(500, cleaned_output.length())))

func handle_json_result(data):
	# Handle your JSON result here
	print("Processing JSON data...")
	# Your JSON result is now available in the 'data' variable
	# Example usage:
	if data is Dictionary:	
		print("Keys available: ", data.keys())

func _exit_tree():
	if thread:
		thread.wait_to_finish()
		thread = null
