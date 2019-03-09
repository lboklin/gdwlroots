extends RigidBody2D

export var xdg_surface: WlrXdgSurface = null setget _xdg_surface_set
var toplevel: WlrXdgToplevel
var surface: WlrSurface
var geometry: Rect2
var process_input: bool
var seat: WlrSeat

enum {
	INTERACTIVE_PASSTHROUGH,
	INTERACTIVE_MOVE,
	INTERACTIVE_RESIZE,
}

signal map(surface)
signal unmap(surface)

func get_size():
	return xdg_surface.get_geometry().size

func set_seat(_seat):
	seat = _seat

func focus():
	if toplevel != null:
		process_input = true
		toplevel.set_activated(true)

func _handle_destroy(xdg_surface):
	queue_free()
	set_process(false)
	
func _handle_map(xdg_surface):
	set_process(true)
	emit_signal("map", self)

func _handle_unmap(xdg_surface):
	set_process(false)
	emit_signal("unmap", self)

func _xdg_surface_set(val):
	xdg_surface = val
	surface = xdg_surface.get_wlr_surface()
	xdg_surface.connect("destroy", self, "_handle_destroy")
	xdg_surface.connect("map", self, "_handle_map")
	xdg_surface.connect("unmap", self, "_handle_unmap")
	if xdg_surface.get_role() == WlrXdgSurface.XDG_SURFACE_ROLE_TOPLEVEL:
		toplevel = xdg_surface.get_xdg_toplevel()

func _draw():
	if surface == null:
		return
	var texture = surface.get_texture()
	if texture == null:
		return
	var state = surface.get_current_state()
	# TODO: Draw all subsurfaces/popups/etc
	var position = Vector2(-state.get_buffer_width() / 2, -state.get_buffer_height() / 2)
	draw_texture(texture, position)
	surface.send_frame_done()

func _process(delta):
	var collisionShape = get_node("CollisionShape2D")
	var state = surface.get_current_state()
	geometry = xdg_surface.get_geometry()
	var extents = collisionShape.shape.get_extents()
	var desiredExtents = geometry.size / Vector2(2, 2)
	if geometry.size.x == 0 or geometry.size.y == 0:
		desiredExtents = Vector2(state.get_width() / 2, state.get_height() / 2)
	if desiredExtents.x != 0 and desiredExtents.y != 0 \
			and extents != desiredExtents:
		collisionShape.shape = RectangleShape2D.new()
		collisionShape.shape.set_extents(desiredExtents)
		print("Set surface extents to ", desiredExtents)
	update()

func get_surface_coords(position):
	return position + geometry.size / Vector2(2, 2) + geometry.position

func _on_RigidBody2D_input_event(viewport, event, shape_idx):
	var notify_frame = false
	if event is InputEventMouseMotion:
		var position = get_surface_coords(to_local(event.position))
		seat.pointer_notify_motion(position.x, position.y)
		notify_frame = true
	if event is InputEventMouseButton:
		seat.pointer_notify_button(event.button_index, event.pressed)
		notify_frame = true
	if notify_frame:
		seat.pointer_notify_frame()

func _on_RigidBody2D_mouse_entered():
	var position = get_surface_coords(to_local(get_viewport().get_mouse_position()))
	seat.pointer_notify_enter(surface, position.x, position.y)