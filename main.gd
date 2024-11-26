extends Node2D

@onready var cellf: Control = $Field/Cells
@onready var wayf: Control = $Field/Ways

var radius: float = 256
var diameter: float = radius * 2
var cells: int = 50
var max_cs: float = 128
var min_cs: float = 16
var max_i: int = 100
var way_width: float = 3

var cells_arr: Array[Cell]
var check_step: float = 3

var rnd: RandomNumberGenerator = RandomNumberGenerator.new()


class Cell:
	var cell: ColorRect
	var up_node: ColorRect
	var left_node: ColorRect
	var right_node: ColorRect
	var down_node: ColorRect
	
	func _init(cell: ColorRect, up_node: ColorRect, left_node: ColorRect, right_node: ColorRect, down_node: ColorRect) -> void:
		self.cell = cell
		self.up_node = up_node
		self.left_node = left_node
		self.right_node = right_node
		self.down_node = down_node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Cells.text = str(cells)
	$VBoxContainer/Max.text = str(max_cs)
	$VBoxContainer/Min.text = str(min_cs)
	$VBoxContainer/MaxI.text = str(max_i)
	$VBoxContainer/WayW.text = str(way_width)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func generate() -> void:
	for child in cellf.get_children():
		cellf.remove_child(child)
	for child in wayf.get_children():
		wayf.remove_child(child)
	
	var tr: float = way_width * 2
	
	for i in cells:
		var cell: ColorRect = ColorRect.new()
		cell.size = Vector2(rnd.randf_range(min_cs, max_cs), rnd.randf_range(min_cs, max_cs))
		cell.position = Vector2(rnd.randf_range(-radius, radius) + radius, rnd.randf_range(-radius, radius) + radius)
		var good_rect: Rect2 = Rect2(Vector2(cell.position.x - tr, cell.position.y - tr), Vector2(cell.size.x + tr * 2, cell.size.y + tr * 2))
		
		var iters: int = 0
		var goden: bool = false
		while not goden:
			if iters >= max_i:
				break
			
			iters += 1
			goden = true
			
			for child: ColorRect in cellf.get_children():
				if child.get_rect().intersects(good_rect):
					goden = false
					
					cell.size = Vector2(rnd.randf_range(min_cs, max_cs), rnd.randf_range(min_cs, max_cs))
					cell.position = Vector2(rnd.randf_range(-radius, radius) + radius, rnd.randf_range(-radius, radius) + radius)
					good_rect = Rect2(Vector2(cell.position.x - tr, cell.position.y - tr), Vector2(cell.size.x + tr * 2, cell.size.y + tr * 2))
					break
		
		if iters >= max_i:
			continue
		cell.color = Color(randf(), randf(), randf())
		cellf.add_child(cell)


func collect_cells() -> void:
	cells_arr.clear()
	
	for cell: ColorRect in cellf.get_children():
		var up_node: ColorRect = null
		var left_node: ColorRect = null
		var right_node: ColorRect = null
		var down_node: ColorRect = null
		
		# find UP node
		var exrect: Rect2 = cell.get_rect()
		for expanded_on in diameter:
			for cell_target: ColorRect in cellf.get_children():
				if cell_target.get_index() != cell.get_index():
					if exrect.intersects(cell_target.get_rect()):
						up_node = cell_target
						break
			if up_node:
				break
			exrect.position.y -= check_step
		# find DOWN node
		exrect = cell.get_rect()
		for expanded_on in diameter:
			for cell_target: ColorRect in cellf.get_children():
				if cell_target.get_index() != cell.get_index():
					if exrect.intersects(cell_target.get_rect()):
						down_node = cell_target
						break
			if down_node:
				break
			exrect.size.y += check_step
		# find LEFT node
		exrect = cell.get_rect()
		for expanded_on in diameter:
			for cell_target: ColorRect in cellf.get_children():
				if cell_target.get_index() != cell.get_index():
					if exrect.intersects(cell_target.get_rect()):
						left_node = cell_target
						break
			if left_node:
				break
			exrect.position.x -= check_step
		# find RIGHT node
		exrect = cell.get_rect()
		for expanded_on in diameter:
			for cell_target: ColorRect in cellf.get_children():
				if cell_target.get_index() != cell.get_index():
					if exrect.intersects(cell_target.get_rect()):
						right_node = cell_target
						break
			if right_node:
				break
			exrect.size.x += check_step
		
		cells_arr.append(Cell.new(cell, up_node, left_node, right_node, down_node))


func gi(node: Node) -> String:
	if node:
		return str(node.get_index())
	return '#'


func draw_info() -> void:
	for cell: Cell in cells_arr:
		var label: Label = Label.new()
		label.text = 'i:' + gi(cell.cell) + '.u:' + gi(cell.up_node) + '.l:' + gi(cell.left_node) + '.r:' + gi(cell.right_node) + '.d:' + gi(cell.down_node)
		cell.cell.add_child(label)


func draw_color_rect(rect: Rect2, color: Color) -> void:
	var cr: ColorRect = ColorRect.new()
	cr.position = rect.position
	cr.size = rect.size
	cr.color = color
	wayf.add_child(cr)


func draw_way_from_to(from: ColorRect, to: ColorRect, direction: String) -> void:
	var from_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)
	var center_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)
	var to_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)
	#print(from.get_index(), ' ', to.get_index(), ' ', direction)
	
	var dot0: Vector2
	var dot1: Vector2
	
	if direction == 'up':
		if from.position.x < to.position.x:
			dot0 = Vector2(from.position.x + from.size.x / 2 - way_width, lerp(to.get_rect().end.y, from.position.y, 0.5) - way_width)
			dot1 = Vector2(to.position.x + to.size.x / 2 + way_width, dot0.y + way_width * 2)
			
			from_rect.position = dot0
			from_rect.end = Vector2(from.position.x + from.size.x / 2 + way_width, from.position.y)
			
			center_rect.position = dot0
			center_rect.end = dot1
			
			to_rect.position = Vector2(to.position.x + to.size.x / 2 - way_width, to.get_rect().end.y)
			to_rect.end = dot1
		else:
			from_rect.position = Vector2(from.position.x + from.size.x / 2 - way_width, to.get_rect().end.y + (from.position.y - to.get_rect().end.y) / 2 - way_width)
			from_rect.end = Vector2(from.position.x + from.size.x / 2 + way_width, from.position.y)
			
			to_rect.position = Vector2(to.position.x + to.size.x / 2 - way_width, to.get_rect().end.y)
			to_rect.size = Vector2(way_width * 2, from_rect.size.y - way_width / 2)
			
			center_rect.position = Vector2(to_rect.position.x, to_rect.end.y - way_width * 2)
			center_rect.end = Vector2(from_rect.position.x + way_width * 2, from_rect.position.y + way_width * 2)

	elif direction == 'left':
		dot0 = Vector2(lerp(to.get_rect().end.x, from.position.x, 0.5) - way_width, from.position.y + from.size.y / 2 - way_width)
		dot1 = Vector2(dot0.x + way_width * 2, to.position.y + to.size.y / 2 + way_width)
		
		from_rect.position = dot0
		from_rect.end = Vector2(from.position.x, from.position.y + from.size.y / 2 + way_width)
		
		to_rect.position = Vector2(to.get_rect().end.x, to.position.y + to.size.y / 2 - way_width)
		to_rect.end = dot1
		
		if from.position.y < to.position.y:
			center_rect.position = dot0
			center_rect.end = dot1
		else:
			center_rect.position = Vector2(dot0.x, dot1.y - way_width * 2)
			center_rect.end = Vector2(dot1.x, dot0.y + way_width * 2)
	
	draw_color_rect(from_rect, from.color)
	draw_color_rect(to_rect, to.color)
	draw_color_rect(center_rect, Color((from.color.r + to.color.r) / 2, (from.color.g + to.color.g) / 2, (from.color.b + to.color.b) / 2))


func drow(drawed: Array, c0: ColorRect, c1: ColorRect) -> bool:
	if c0 and c1:
		return (str(c0.get_index()) + str(c1.get_index())) in drawed
	return true


func draw_ways() -> void:
	var drawed: Array
	
	for cell: Cell in cells_arr:
		if not drow(drawed, cell.cell, cell.up_node):
			draw_way_from_to(cell.cell, cell.up_node, 'up')
			drawed.append(str(cell.cell.get_index()) + str(cell.up_node.get_index()))
		
		if not drow(drawed, cell.cell, cell.left_node):
			draw_way_from_to(cell.cell, cell.left_node, 'left')
			drawed.append(str(cell.cell.get_index()) + str(cell.left_node.get_index()))


func _on_button_button_down() -> void:
	cells = int($VBoxContainer/Cells.text)
	max_cs = float($VBoxContainer/Max.text)
	min_cs = float($VBoxContainer/Min.text)
	max_i = int($VBoxContainer/MaxI.text)
	way_width = float($VBoxContainer/WayW.text)
	
	generate()
	collect_cells()
	#draw_info()
	draw_ways()
