-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local menubar = require("menubar")
local beautiful = require("beautiful")
local freedesktop = require("freedesktop")

require("wibar")
require("errorhandling")
require("vars")

-- {{{ Variable definitions
beautiful.bg_normal = "#282a36"
beautiful.bg_focus = "#282a36"
beautiful.font = "Noto Sans Regular 10"
beautiful.notification_font = "Noto Sans Bold 14"
beautiful.useless_gap_width = 10
beautiful.notification_icon_size = 100
beautiful.notification_opacity = 10
beautiful.notification_shape = gears.shape.rounded_rect
beautiful.notification_bg = "#282a36"
beautiful.notification_font = "Source Code Pro 9"

awful.layout.layouts = {
    awful.layout.suit.floating,
awful.layout.suit.tile, }

myawesomemenu = {
    {"manual", terminal .. " -e man awesome", menubar.utils.lookup_icon("system-help")},
    {"edit config", gui_editor .. " " .. awesome.conffile, menubar.utils.lookup_icon("accessories-text-editor")},
{"restart", awesome.restart, menubar.utils.lookup_icon("system-restart")}}
myexitmenu = {
    {"log out", function() awesome.quit() end, menubar.utils.lookup_icon("system-log-out")},
    {"suspend", "systemctl suspend", menubar.utils.lookup_icon("system-suspend")},
    {"hibernate", "systemctl hibernate", menubar.utils.lookup_icon("system-suspend-hibernate")},
    {"reboot", "systemctl reboot", menubar.utils.lookup_icon("system-reboot")},
{"shutdown", "poweroff", menubar.utils.lookup_icon("system-shutdown")}}
mymainmenu = freedesktop.menu.build({
    icon_size = 32,
    after = {
        {"Awesome", myawesomemenu, "/usr/share/awesome/icons/awesome32.png"},
        {"Exit", myexitmenu, menubar.utils.lookup_icon("system-shutdown")},
    }})
    
    mylauncher = awful.widget.launcher({image = beautiful.awesome_icon, menu = mymainmenu})
    
    root.buttons(gears.table.join(
        awful.button({}, 1, function () mymainmenu:hide() end),
        awful.button({}, 3, function () mymainmenu:toggle() end),
        awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)))
    
    -- {{{ Helper functions
    local function client_menu_toggle_fn()
        local instance = nil
        return function ()
            if instance and instance.wibox.visible then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients({theme = {width = 250}})
            end
        end
    end
    -- }}}
    
    local globalkeys, clientkeys, clientbuttons = require("keybinds")()
    
    root.keys(globalkeys)
    -- {{{ Rules
    -- Rules to apply to new clients (through the "manage" signal).
    awful.rules.rules = {
        -- All clients will match this rule.
        {rule = {},
            properties = {border_width = beautiful.border_width,
                border_color = beautiful.border_normal,
                focus = awful.client.focus.filter,
                raise = true,
                keys = clientkeys,
                buttons = clientbuttons,
                size_hints_honor = false, -- Remove gaps between terminals
                screen = awful.screen.preferred,
                callback = awful.client.setslave,
                placement = awful.placement.no_overlap + awful.placement.no_offscreen
            }},
            
            -- Floating clients.
            {rule_any = {
                instance = {
                    "DTA", -- Firefox addon DownThemAll.
                    "copyq", -- Includes session name in class.
                },
                class = {
                    "Arandr",
                    "Gpick",
                    "Kruler",
                    "MessageWin", -- kalarm.
                    "Sxiv",
                    "Wpa_gui",
                    "pinentry",
                    "veromix",
                "xtightvncviewer"},
                
                name = {
                    "Event Tester", -- xev.
                },
                role = {
                    "AlarmWindow", -- Thunderbird's calendar.
                    "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
                }}, properties = {floating = true}},
                
                -- Add titlebars to normal clients and dialogs
                {rule_any = {type = {"normal", "dialog"}},
                properties = {titlebars_enabled = false}},
            }
            -- }}}
            
            -- {{{ Signals
            -- Signal function to execute when a new client appears.
            client.connect_signal("manage", function (c)
                c.shape = function(cr, w, h)
                    gears.shape.rounded_rect(cr, w, h, 8)
                end
                if awesome.startup and
                    not c.size_hints.user_position
                    and not c.size_hints.program_position then
                    -- Prevent clients from being unreachable after screen count changes.
                    awful.placement.no_offscreen(c)
                end
            end)
            
            -- Add a titlebar if titlebars_enabled is set to true in the rules.
            client.connect_signal("request::titlebars", function(c)
                -- buttons for the titlebar
                local buttons = gears.table.join(
                    awful.button({}, 1, function()
                        client.focus = c
                        c:raise()
                        awful.mouse.client.move(c)
                    end),
                    awful.button({}, 3, function()
                        client.focus = c
                        c:raise()
                        awful.mouse.client.resize(c)
                    end))
                    
                    awful.titlebar(c) : setup {
                        {-- Left
                            awful.titlebar.widget.iconwidget(c),
                            buttons = buttons,
                            layout = wibox.layout.fixed.horizontal
                        },
                        {-- Middle
                            {-- Title
                                align = "center",
                            widget = awful.titlebar.widget.titlewidget(c)},
                            buttons = buttons,
                            layout = wibox.layout.flex.horizontal
                        },
                        {-- Right
                            awful.titlebar.widget.floatingbutton (c),
                            awful.titlebar.widget.stickybutton (c),
                            -- awful.titlebar.widget.ontopbutton    (c),
                            awful.titlebar.widget.maximizedbutton(c),
                            awful.titlebar.widget.closebutton (c),
                        layout = wibox.layout.fixed.horizontal()},
                        layout = wibox.layout.align.horizontal
                    }
                end)
                
                -- Enable sloppy focus, so that focus follows mouse.
                client.connect_signal("mouse::enter", function(c)
                    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                        and awful.client.focus.filter(c) then
                        client.focus = c
                    end
                end)
                
                client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
                client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
                
                -- Disable borders on lone windows
                -- Handle border sizes of clients.
                for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
                    local clients = awful.client.visible(s)
                    local layout = awful.layout.getname(awful.layout.get(s))
                    
                    for _, c in pairs(clients) do
                        -- No borders with only one humanly visible client
                        if c.maximized then
                            -- NOTE: also handled in focus, but that does not cover maximizing from a
                            -- tiled state (when the client had focus).
                            c.border_width = 0
                        elseif c.floating or layout == "floating" then
                            c.border_width = beautiful.border_width
                        elseif layout == "max" or layout == "fullscreen" then
                            c.border_width = 0
                        else
                            local tiled = awful.client.tiled(c.screen)
                            if #tiled == 1 then -- and c == tiled[1] then
                                tiled[1].border_width = 0
                            else
                                c.border_width = beautiful.border_width
                            end
                        end
                    end
                end)
            end
            
            -- }}}
            
            awful.spawn.with_shell("~/.config/awesome/autorun.sh")
            
