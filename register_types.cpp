#include "core/class_db.h"
#include "register_types.h"
#include "wayland_display.h"
#include "wlr_backend.h"
#include "wlr_compositor.h"
#include "wlr_data_device_manager.h"
#include "wlr_keyboard.h"
#include "wlr_output.h"
#include "wlr_seat.h"
#include "wlr_surface.h"
#include "wlr_xdg_shell.h"

void register_gdwlroots_types() {
	ClassDB::register_class<WaylandDisplay>();
	ClassDB::register_class<WlrBackend>();
	ClassDB::register_class<WlrCompositor>();
	ClassDB::register_class<WlrDataDeviceManager>();
	ClassDB::register_class<WlrKeyboard>();
	ClassDB::register_class<WlrOutput>();
	ClassDB::register_class<WlrSeat>();
	ClassDB::register_class<WlrSurface>();
	ClassDB::register_class<WlrSurfaceAtResult>();
	ClassDB::register_class<WlrSurfaceState>();
	ClassDB::register_class<WlrXdgShell>();
	ClassDB::register_class<WlrXdgSurface>();
	ClassDB::register_class<WlrXdgToplevel>();
	ClassDB::register_class<WlrXdgToplevelState>();
	ClassDB::register_class<WlrXdgPopup>();
}

void unregister_gdwlroots_types() {
	/* this space deliberately left blank */
}
