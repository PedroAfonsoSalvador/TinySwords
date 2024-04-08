extends Node2D

const FOAM: PackedScene = preload("res://management/foam.tscn")


@onready var grass_tilemap: TileMap = get_node("Grass")
@onready var water_tilemap: TileMap = get_node("Water")

var grass_used_cells: Array
var water_used_cells: Array

func _ready() -> void:
	var used_grass_rect: Rect2 = grass_tilemap.get_used_rect()
	grass_used_cells = grass_tilemap.get_used_cells(0)
	generate_water_tiles(used_grass_rect)
	generate_foam_tiles()

#Cria os tiles de água aonde os de grama terminam
func generate_water_tiles(used_rect: Rect2) -> void:
	for x in range(used_rect.position.x - 10, used_rect.size.x + 10):
		for y in range(used_rect.position.y - 10, used_rect.size.y + 10):
			#Impede que os tiles de água sejam criado em cima dos de grama já existentes
			if(grass_used_cells.has(Vector2i(x,y))):
				continue
			
			water_tilemap.set_cell(0,Vector2i(x, y),0,Vector2i(0, 0))
			
	water_used_cells = water_tilemap.get_used_cells(0)

#Cria as bordas da maré entre água e a grama
func generate_foam_tiles() -> void:
	for cell in grass_used_cells:
		if check_grass_neighboors(cell):
			spawn_foam(cell)


#Checa se os vizinhos da célula de grama são de água
func check_grass_neighboors(cell: Vector2i) -> bool:
	var left_neighboor: Vector2i = Vector2i(cell.x - 1, cell.y)
	var right_neighboor: Vector2i = Vector2i(cell.x + 1, cell.y)
	var up_neighboor: Vector2i = Vector2i(cell.x, cell.y - 1)
	var bottom_neighboor: Vector2i = Vector2i(cell.x, cell.y + 1)
	
	var neighboors_list: Array = [left_neighboor, right_neighboor, up_neighboor, bottom_neighboor]
	
	for neighboor in neighboors_list:
		if water_used_cells.has(neighboor):
			return true
	return false


#Cria a espuma em si
func spawn_foam(foam_cell: Vector2) -> void:
	var foam = FOAM.instantiate()
	add_child(foam)
	foam.position = (foam_cell * 64.0) + Vector2(32, 32)
