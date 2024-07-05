/* appearance */
static const int sloppyfocus               = 1;  /* focus follows mouse */
static const int smartgaps                 = 1;  /* 1 means no outer gap when there is only one window */
static const int monoclegaps               = 0;  /* 1 means outer gaps in monocle layout */
static const int bypass_surface_visibility = 0;  /* 1 means idle inhibitors will disable idle tracking even if it's surface isn't visible  */
static const int smartborders              = 1;
static const unsigned int borderpx         = 1;  /* border pixel of windows */
static const unsigned int gappih           = 10; /* horiz inner gap between windows */
static const unsigned int gappiv           = 10; /* vert inner gap between windows */
static const unsigned int gappoh           = 20; /* horiz outer gap between windows and screen edge */
static const unsigned int gappov           = 20; /* vert outer gap between windows and screen edge */
static const float bordercolor[]           = {0.5, 0.5, 0.5, 1.0};
static const float focuscolor[]            = {1.0, 0.0, 0.0, 1.0};
/* To conform the xdg-protocol, set the alpha to zero to restore the old behavior */
static const float fullscreen_bg[]         = {0.1, 0.1, 0.1, 1.0};
static bool cursor_warp = true;

/* tagging - tagcount must be no greater than 31 */
#define TAGCOUNT 9
static const int tagcount = 9;

/* Autostart */
static const char *const autostart[] = {
	"dwlstartup", NULL,
	"polkit-gnome-authentication-agent-1", NULL,
	"wallpaper", NULL,
	"ydotoold", NULL,
	"shikane", NULL,
	"wl-paste", "--watch", "cliphist", "store", NULL,
	"discord", NULL,
	"youtube-music", NULL,
	NULL /* terminate */
};

static const Rule rules[] = {
	/* app_id           title       tags mask     isfloating   monitor */
	/* examples:
	{ "Gimp",           NULL,       0,            1,           -1 },
	*/
	{ "discord",        NULL,       1 << 2,       0,           -1 },
	{ "YouTube Music",  NULL,       1 << 1,       0,           -1 },
};

/* layout(s) */
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
	{ "[D]",      deck },
};

/* monitors */
static const MonitorRule monrules[] = {
	/* name       mfact nmaster scale layout       rotate/reflect                x   y   tagset*/
	{ "eDP-1",    0.55, 1,   1.75,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   0,  0,  1 << 3 },
	/* defaults */
	{ NULL,       0.55, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1, -1, 0},
};

/* keyboard */
static const struct xkb_rule_names xkb_rules = {
	/* can specify fields: rules, model, layout, variant, options */
	.options = "caps:escape_shifted_capslock",
};

static const int repeat_rate = 25;
static const int repeat_delay = 600;

/* Trackpad */
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 0;
static const int natural_scrolling = 1;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 1;
/* You can choose between:
LIBINPUT_CONFIG_SCROLL_NO_SCROLL
LIBINPUT_CONFIG_SCROLL_2FG
LIBINPUT_CONFIG_SCROLL_EDGE
LIBINPUT_CONFIG_SCROLL_ON_BUTTON_DOWN
*/
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;

/* You can choose between:
LIBINPUT_CONFIG_CLICK_METHOD_NONE
LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS
LIBINPUT_CONFIG_CLICK_METHOD_CLICKFINGER
*/
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;

/* You can choose between:
LIBINPUT_CONFIG_SEND_EVENTS_ENABLED
LIBINPUT_CONFIG_SEND_EVENTS_DISABLED
LIBINPUT_CONFIG_SEND_EVENTS_DISABLED_ON_EXTERNAL_MOUSE
*/
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;

/* You can choose between:
LIBINPUT_CONFIG_ACCEL_PROFILE_FLAT
LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE
*/
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;
/* You can choose between:
LIBINPUT_CONFIG_TAP_MAP_LRM -- 1/2/3 finger tap maps to left/right/middle
LIBINPUT_CONFIG_TAP_MAP_LMR -- 1/2/3 finger tap maps to left/middle/right
*/
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

/* If you want to use the windows key for MODKEY, use WLR_MODIFIER_LOGO */
#define MODKEY WLR_MODIFIER_LOGO

#define TAGKEYS(KEY,SKEY,TAG) \
	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) spawn, { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *termcmd[] = { "kitty", NULL };
static const char *browcmd[] = { "firefox", NULL };
static const char *menucmd[] = { "rofi", "-show", "drun", NULL };

static const Key keys[] = {
	/* Note that Shift changes certain key codes: c -> C, 2 -> at, etc. */
	/* modifier                  key                 function        argument */
	{ MODKEY,                    XKB_KEY_p,          spawn,          {.v = menucmd} },
	{ MODKEY,                    XKB_KEY_e,          spawn,          {.v = termcmd} },
	{ MODKEY,                    XKB_KEY_r,          spawn,          {.v = browcmd} },
	{ MODKEY,                    XKB_KEY_j,          focusstack,     {.i = +1} },
	{ MODKEY,                    XKB_KEY_k,          focusstack,     {.i = -1} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_J,          movestack,      {.i = +1} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_K,          movestack,      {.i = -1} },
	{ MODKEY,                    XKB_KEY_i,          incnmaster,     {.i = +1} },
	{ MODKEY,                    XKB_KEY_u,          incnmaster,     {.i = -1} },
	{ MODKEY,                    XKB_KEY_h,          setmfact,       {.f = -0.05} },
	{ MODKEY,                    XKB_KEY_l,          setmfact,       {.f = +0.05} },
	{ MODKEY,                    XKB_KEY_Return,     zoom,           {0} },
	{ MODKEY,                    XKB_KEY_Tab,        view,           {0} },
	{ MODKEY,                    XKB_KEY_c,          killclient,     {0} },
	{ MODKEY,                    XKB_KEY_t,          setlayout,      {.v = &layouts[0]} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_BackSpace,  setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                    XKB_KEY_m,          setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                    XKB_KEY_d,          setlayout,      {.v = &layouts[3]} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_F,          togglefloating, {0} },
	{ MODKEY,                    XKB_KEY_f,          togglefullscreen, {0} },
	{ MODKEY,                    XKB_KEY_0,          view,           {.ui = ~0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_parenright, tag,            {.ui = ~0} },
	{ MODKEY,                    XKB_KEY_comma,      focusmon,       {.i = WLR_DIRECTION_LEFT|WLR_DIRECTION_DOWN} },
	{ MODKEY,                    XKB_KEY_period,     focusmon,       {.i = WLR_DIRECTION_RIGHT|WLR_DIRECTION_UP} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_less,       tagmon,         {.i = WLR_DIRECTION_LEFT|WLR_DIRECTION_DOWN} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_greater,    tagmon,         {.i = WLR_DIRECTION_RIGHT|WLR_DIRECTION_UP} },
	{ MODKEY,                    XKB_KEY_Left,       rotatetags,     {.i = -1} },
	{ MODKEY,                    XKB_KEY_Right,      rotatetags,     {.i = +1} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Left,       clientshift,    {.i = -1} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Right,      clientshift,    {.i = +1} },
	TAGKEYS(          XKB_KEY_1, XKB_KEY_exclam,                     0),
	TAGKEYS(          XKB_KEY_2, XKB_KEY_at,                         1),
	TAGKEYS(          XKB_KEY_3, XKB_KEY_numbersign,                 2),
	TAGKEYS(          XKB_KEY_4, XKB_KEY_dollar,                     3),
	TAGKEYS(          XKB_KEY_5, XKB_KEY_percent,                    4),
	TAGKEYS(          XKB_KEY_6, XKB_KEY_asciicircum,                5),
	TAGKEYS(          XKB_KEY_7, XKB_KEY_ampersand,                  6),
	TAGKEYS(          XKB_KEY_8, XKB_KEY_asterisk,                   7),
	TAGKEYS(          XKB_KEY_9, XKB_KEY_parenleft,                  8),
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Q,          quit,           {0} },

	{ MODKEY,                    XKB_KEY_b,          SHCMD("hyprpicker | wl-copy") },
	{ MODKEY,                    XKB_KEY_x,          SHCMD("grim -g \"$(slurp -b 00000000 -s 61616140)\" - | wl-copy") },
	{ MODKEY,                    XKB_KEY_v,          SHCMD("cliphist list | rofi -dmenu | cliphist decode | wl-copy") },

	{ 0, XKB_KEY_XF86PowerOff,           spawn, {.v = (const char*[]){"ags", "-t", "powermenu", NULL}}},
	// TODO: Allow those bindings on lockscreen
	// TODO: Allow those bindings on repeat
	{ 0, XKB_KEY_XF86MonBrightnessUp,    spawn, {.v = (const char*[]){"ags", "run-js", "brightness.screen += 0.05; indicator.display()", NULL}}},
	{ 0, XKB_KEY_XF86MonBrightnessDown,  spawn, {.v = (const char*[]){"ags", "run-js", "brightness.screen -= 0.05; indicator.display()", NULL}}},
	{ 0, XKB_KEY_XF86KbdBrightnessUp,    spawn, {.v = (const char*[]){"ags", "run-js", "brightness.kbd++; indicator.kbd()", NULL}}},
	{ 0, XKB_KEY_XF86KbdBrightnessDown,  spawn, {.v = (const char*[]){"ags", "run-js", "brightness.kbd--; indicator.kbd()", NULL}}},
	{ 0, XKB_KEY_XF86AudioRaiseVolume,   spawn, {.v = (const char*[]){"ags", "run-js", "audio.speaker.volume += 0.05; indicator.speaker()", NULL}}},
	{ 0, XKB_KEY_XF86AudioLowerVolume,   spawn, {.v = (const char*[]){"ags", "run-js", "audio.speaker.volume -= 0.05; indicator.speaker()", NULL}}},
	{ 0, XKB_KEY_XF86AudioMute,          spawn, {.v = (const char*[]){"ags", "run-js", "audio.speaker.isMuted = !audio.speaker.isMuted; indicator.speaker()", NULL}}},
	{ 0, XKB_KEY_XF86AudioMicMute,       spawn, {.v = (const char*[]){"pactl", "set-source-mute", "@DEFAULT_SOURCE@", "toggle", NULL}}},

	{ 0, XKB_KEY_XF86AudioPlay,          spawn, {.v = (const char*[]){"ags", "run-js", "mpris.getPlayer()?.playPause()", NULL}}},
	{ 0, XKB_KEY_XF86AudioStop,          spawn, {.v = (const char*[]){"ags", "run-js", "mpris.getPlayer()?.stop()", NULL}}},
	{ 0, XKB_KEY_XF86AudioPause,         spawn, {.v = (const char*[]){"ags", "run-js", "mpris.getPlayer()?.pause()", NULL}}},
	{ 0, XKB_KEY_XF86AudioPrev,          spawn, {.v = (const char*[]){"ags", "run-js", "mpris.getPlayer()?.previous()", NULL}}},
	{ 0, XKB_KEY_XF86AudioNext,          spawn, {.v = (const char*[]){"ags", "run-js", "mpris.getPlayer()?.next()", NULL}}},

	/* Ctrl-Alt-Backspace and Ctrl-Alt-Fx used to be handled by X server */
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_Terminate_Server, quit, {0} },
#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
	CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
	CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

static const Button buttons[] = {
	{ MODKEY|WLR_MODIFIER_SHIFT, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ MODKEY|WLR_MODIFIER_SHIFT, BTN_MIDDLE, togglefloating, {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
};
