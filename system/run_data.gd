extends Resource
class_name RunData

enum RunOutcome { SUCCESS, FAILED, ABORTED, NOT_LOGGED }

var time_elapsed : float = 0.00
var run_outcome : RunOutcome = RunOutcome.NOT_LOGGED

var aetherium_ore : float = 0
var promethium_shards : float = 0
var exotic_alloy : float = 0
var salvage : float = 0
