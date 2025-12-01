extends Room
class_name ArenaRoom

@onready var room_exits: Node3D = $RoomExits

func _ready() -> void:
	for exit in room_exits.get_children():
		if exit is Area3D:
			exit.area_entered.connect(on_exit_trigger_entered.bind(exit))

func on_exit_trigger_entered(object_area, trigger_area) -> void:
	#first - if we're NOT in this room - then we're not "exiting"
	#so this is essentially an "entry trigger" - we can use that later
	#for now, we'll just early return
	if GameManager.current_level.room_manager.current_room != self:
		return
		
	if object_area.is_in_group("player"):
		if object_area.get_parent() is PlayerRoot:
			var player : PlayerRoot = object_area.get_parent()
			player.free_flight_controller.ArenaRoomEnded(trigger_area)
