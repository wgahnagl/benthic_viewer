extends MetaverseSession

var thread : Thread
var is_running : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	is_running = true
	thread = Thread.new()
	connect("debug_message", _on_debug_message)
	thread.start(_check_stream)

func _on_debug_message():
	print("Debug message!!!")

# This function will run in a separate thread.
func _check_stream(user_data):
	while is_running:
		check_stream()
		OS.delay_msec(500)  # Delay for 500 milliseconds

# Called when the node is removed from the scene tree.
func _exit_tree():
	is_running = false
	thread.wait_to_finish()  # Ensure the thread has stopped before exiting
