extends Node


@export var coin_scene : PackedScene
@export var powerup_scene : PackedScene
@export var playtime = 30
@export var level_time_bonus : int
@export var powerup_time_bonus : int

var level = 1
var score = 0
var timeleft = 0
var screensize = Vector2.ZERO
var playing = false


func _ready() :
	screensize = get_viewport().get_visible_rect().size
	$player.screensize = screensize
	$player.hide()


func _process( _delta ) :
	if playing and get_tree().get_nodes_in_group( "coins" ).size() == 0 :
		level += 1
		timeleft += level_time_bonus
		spawn_coins()
		$LevelSound.play()
		$PowerupTimer.start( randf_range( 4, 8 ) )


func init_game() :  # new_game
	playing = true
	level = 1
	score = 0
	timeleft = playtime
	$player.start()
	$player.show()
	$GameTimer.start()
	spawn_coins()
	
	$hud.update_score( score )
	$hud.update_timer( timeleft )


func spawn_coins() :
	for i in level + 4 :
		var c = coin_scene.instantiate()
		
		add_child( c )
		
		c.screensize = screensize
		c.position = Vector2( randi_range( 0, screensize.x ), randi_range( 0, screensize.y ) )


func game_over() :
	playing = false
	$GameTimer.stop()
	get_tree().call_group( "coins", "queue_free" )
	$hud.show_game_over()
	$player.die()
	$EndSound.play()


func _on_game_timer_timeout() -> void:
	timeleft -= 1
	$hud.update_timer( timeleft )
	
	if timeleft <= 0 :
		game_over()


func _on_player_hurt() -> void:
	game_over()


func _on_player_pickup( type ) -> void:
	match type :
		"coin" :
			$CoinSound.play()
			score += 1
			$hud.update_score( score )
		"powerup" :
			$PowerupSound.play()
			timeleft += powerup_time_bonus
			$hud.update_timer( timeleft )


func _on_hud_start_game() -> void:
	init_game()


func _on_powerup_timer_timeout() -> void:
	var p = powerup_scene.instantiate()
	add_child( p )
	
	p.screensize = screensize
	p.position = Vector2( randi_range( 0, screensize.x ), randi_range( 0, screensize.y ) )
