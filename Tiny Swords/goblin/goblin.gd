extends CharacterBody2D


const AUDIO_TEMPLATE: PackedScene = preload("res://management/audio_template.tscn")
const ATTACK_AREA: PackedScene = preload("res://goblin/enemy_attack_area.tscn")
const OFFSET: Vector2 = Vector2(0, 29.5)

@onready var texture: Sprite2D = get_node("Texture")
@onready var animation: AnimationPlayer = get_node("Animation")
@onready var aux_animation_play: AnimationPlayer = get_node("AuxAnimationPlayer")
@onready var transition_screen: CanvasLayer = get_node("/root/trasition_screen")

#Detecta se o personagem entrou na área de perseguição
var player_ref: CharacterBody2D = null
#Detecta se a vida zerou e o inimigo pode morrer
var can_die: bool = false

#Velocidade do inimigo
@export var move_speed: float = 192.0
#Limite da distância
@export var distance_threshold: float = 60.0
#Vida do inimigo
@export var health: int = 3
#Score
@export var score: int = 10


func _physics_process(_delta: float) -> void:
	#Verifica a morte do inimigo
	if can_die:
		return
	
	if player_ref == null or player_ref.can_die:
		velocity = Vector2.ZERO #Garante que a animação de idle rode
		animate() #Garante que as animações estão funcionando
		return
	
	#Pega a direção do personagem e faz com que o inimigo o siga
	var direction: Vector2 = global_position.direction_to(player_ref.global_position)
	#Checa a distancia do inimigo ao personagem
	var distance: float = global_position.distance_to(player_ref.global_position)
	
	#Faz com que o inimigo ataque caso esteja a uma certa distância do personagem
	if distance < distance_threshold:
		animation.play("attack")
		return
		
	
	velocity = direction * move_speed
	move_and_slide()
	animate()


#Ataque ao personagem
func spawn_attack_area() -> void:
	var attack_area = ATTACK_AREA.instantiate()
	attack_area.position = OFFSET #Posição do Collision
	add_child(attack_area)


func animate() -> void:
		#Checa a direção do personagem para alterar a direção da sprite
	if velocity.x > 0:
		texture.flip_h = false
	if velocity.x < 0:
		texture.flip_h = true
	
	if velocity != Vector2.ZERO:
		animation.play("move")
		return
	
	animation.play("idle")

#Atualiza vida do inimigo
func update_health(value: int) -> void:
	health -= value
	if health <= 0:
		can_die = true
		animation.play("death")
		return
	aux_animation_play.play("hit")


#Detecta se o persoangem entrou na área de ataque
func on_detection_area_body_entered(body):
	player_ref = body

#Detecta se o persoangem saiu da área de ataque
func on_detection_area_body_exited(body):
	player_ref = null

#Finaliza a animação do inimigo quando ele morre
func on_animation_animation_finished(anim_name: String) -> void:
	if anim_name == "death":
		transition_screen.player_score += score
		
		get_tree().call_group("level", "increase_kill_count")
		get_tree().call_group("level", "update_score", transition_screen.player_score)
		queue_free()


#Efeito sonoro
func spawn_sfx(sfx_path: String) -> void:
	var sfx = AUDIO_TEMPLATE.instantiate()
	sfx.sfx_to_play = sfx_path
	add_child(sfx)
