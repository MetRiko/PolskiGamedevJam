tool
extends Trigger

enum DetectionType { RisingEdge,FallingEdge,BothEdge }

export var source: NodePath
export var initial_state:bool  = false
export(DetectionType) var detectedEdge = DetectionType.RisingEdge

var node  = null
var state = null
var selfstate = null

func _ready():
	if Engine.editor_hint == false:
		self.node  = get_node(source)
		self.state = node.is_on()
		self.selfstate = initial_state


func _draw():
	if self.debug_hints and OS.is_debug_build():
		if node != null:
			var dv = node.global_position-global_position
			draw_line(Vector2.ZERO,dv,Color.green,1.0,true)
		draw_arc(Vector2.ZERO,32.0,0,deg2rad(360),32,Color.white,1.0,true)
		var label = Label.new()
		var font = label.get_font("")
		draw_string(font,Vector2.ZERO,"FlFp",Color.white)
		label.free()
	

func is_on():
	return selfstate
	

func risingEdge():
	if detectedEdge in [DetectionType.RisingEdge, DetectionType.BothEdge]:
		selfstate = not selfstate
	
func fallingEdge():
	if detectedEdge in [DetectionType.FallingEdge, DetectionType.BothEdge]:
		selfstate = not selfstate
	
func _process(delta):
	var curr
	if self.node != null:
		 curr =self.node.is_on()
	else:
		curr = false

	if curr and not state:
		risingEdge()
	if not curr and state:
		fallingEdge()	
	self.state = curr
	
