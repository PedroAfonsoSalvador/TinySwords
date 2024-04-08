extends Node2D


@onready var interface: CanvasLayer = get_node("Interface")
@onready var health_label: Label = get_node("Interface/Health")
@onready var score_label: Label = get_node("Interface/Score")

#Conta o número de inimigos mortos
var kill_count: int = 0

#Quantidade de inimigos que precisa matar na fase
@export var target_kill_count: int
#Referência ao próximo nivel
@export var next_level_scene_path: String
#Referência ao nível atual
@export var current_level_scene_path: String


func _ready() -> void:
	trasition_screen.scene_path = current_level_scene_path
	update_health(trasition_screen.player_health)
	update_score(trasition_screen.player_score)

func update_health(new_health: int) -> void:
	health_label.text = "HP: " + str(new_health)


func update_score(new_score: int) -> void:
	score_label.text = "Score: " + str(new_score)


func increase_kill_count() -> void:
	kill_count += 1
	
	if kill_count == target_kill_count:
		trasition_screen.scene_path = next_level_scene_path
		trasition_screen.fade_in(true)
