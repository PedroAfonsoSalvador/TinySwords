extends CharacterBody2D


#Som
const AUDIO_TEMPLATE: PackedScene = preload("res://management/audio_template.tscn")

#Pega os nodes
@onready var animation: AnimationPlayer = get_node("Animation") 
@onready var texture: Sprite2D = get_node("Texture") 
@onready var attack_area_collision: CollisionShape2D = get_node("AttackArea/CollisionAttack")
@onready var aux_animation_player: AnimationPlayer = get_node("AuxAnimationPlayer")
@onready var transition_screen: CanvasLayer = get_node("/root/trasition_screen")

#Velocidade de movimento
@export var move_speed: float = 256.0
#Dano do personagem
@export var damage: int = 1
#Vida do personagme
@export var health: int = 10

#Checa se pode ou não atacar
var can_attack: bool = true
#Checa se o personagem está vivo ou não
var can_die: bool = false


func _ready() -> void:
	if trasition_screen.player_health != 0:
		health = trasition_screen.player_health
		return
	
	transition_screen.player_health = health



#Cuida das movimentações do personagem
func _physics_process(_delta: float) -> void:
	if can_attack == false or can_die == true: #Não atacar quando estiver se movendo
		return
	move()
	animate()
	attack_handler()


#Cuida da movimentação em si
func move() -> void:
	var direction: Vector2 = get_direction()
	#velocity é uma palavra reservada que indica a força linear aplica no objeto
	velocity = direction * move_speed
	#Move o objeto em si e determina o sistema de colisões com outros objetos
	move_and_slide()


#Calcula o posicionamento do personagem
func get_direction() -> Vector2:
	return Vector2(
		#a primeira ação e considerada negativa e a segunda positiva 
		Input.get_axis("move_left", "move_right"),#Movimentação em x
		Input.get_axis("move_up", "move_down") #Movimentação em y
	).normalized() #Garante que o personagem não ande mais rápido na diagonal


#Roda a movimentação do personagem
func animate() -> void:
	#Checa a direção do personagem para alterar a direção da sprite
	if velocity.x > 0:
		texture.flip_h = false
		attack_area_collision.position.x = 61.5 #Muda a collisionshape para a direita
	if velocity.x < 0:
		texture.flip_h = true
		attack_area_collision.position.x = -61.5 #Muda a collisionshape para a esquerda
	
	#Checa se o personagem tá se movendo para saber qual animação realizar
	if velocity != Vector2.ZERO:
		animation.play("move")
		return
	animation.play("idle")


#Ataca
func attack_handler() -> void:
	if Input.is_action_just_pressed("attack") and can_attack:
		can_attack = false #Porque já está atacando
		animation.play("attack")


#Termina a animação de ataque
func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"attack":
			can_attack = true
		"death":
			trasition_screen.fade_in()
			trasition_screen.player_score = 0
			trasition_screen.player_health = 0
			


#Checa se um objeto com um corpo(CollisionShape) entrou na área do ataque
func _on_attack_area_body_entered(body) -> void:
	body.update_health(damage)


#Atualiza vida do personagem
func update_health(value: int) -> void:
	health -= value
	
	transition_screen.player_health = health
	get_tree().call_group("level", "update_health", health)
	
	if health <= 0:
		can_die = true
		animation.play("death")
		attack_area_collision.set_deferred("disabled", true) # Desativa a hitbox ao morrer
		return
	
	aux_animation_player.play("hit")


#Efeito sonoro
func spawn_sfx(sfx_path: String) -> void:
	var sfx = AUDIO_TEMPLATE.instantiate()
	sfx.sfx_to_play = sfx_path
	add_child(sfx)
