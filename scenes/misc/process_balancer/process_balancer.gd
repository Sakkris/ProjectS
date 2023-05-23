extends Node
class_name ProcessBalancer

@export_range(1, 10) var number_of_rows: int = 5
@export_range(1, 10) var row_item_limit: int = 3

var balancing_rows = {}
var smallest_row: int = 0
var frame_count = 0


func _ready():
	for i in range(number_of_rows):
		balancing_rows[i] = []
		
		for j in range(row_item_limit):
			balancing_rows[i].push_back(null)


func _physics_process(_delta):
	var current_row = balancing_rows[frame_count]

	for pair in current_row:
		if pair != null:
			pair.get_second().call()

	frame_count += 1
	if frame_count == number_of_rows:
		frame_count = 0


func add_to_queue(new_item, callable: Callable):
	var process_pair: Pair = Pair.new(new_item, callable)
	var row: Array = balancing_rows[smallest_row]
	
	for i in range(row_item_limit):
		if row[i] == null:
			row[i] = process_pair
			break
	
	update_smallest_row()


func remove_from_queue(item):
	for row_index in balancing_rows:
		var row: Array = balancing_rows[row_index]
		
		for i in range(row_item_limit):
			if row[i] != null && row[i].get_first() == item:
				row[i] = null
				update_smallest_row()
				return


func update_smallest_row():
	var current_smallest = 0
	var current_size = row_item_limit + 1
	var size_count = 0
	
	for row_index in balancing_rows:
		var row = balancing_rows[row_index]
		
		for pair in row:
			if pair != null:
				size_count += 1
		
		if size_count < current_size:
			current_size = size_count
			current_smallest = row_index
		
		size_count = 0
	
	smallest_row = current_smallest
