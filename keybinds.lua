local awful = require("awful")
local gears = require("gears")
local my_table = awful.util.table or gears.table

local globalkeys =
my_table.join(
    -- Custom hotkeys
    awful.key({modkey}, "d", function () awful.util.spawn("rofi -show run")end),
    awful.key({modkey}, "l", function () awful.util.spawn("betterlockscreen -l dimblur")end),
    awful.key({modkey, altkey}, "l", function () os.execute("betterlockscreen -l dimblur")end),
    -- Tag browsing
    awful.key({modkey, "Control"}, "Left", awful.tag.viewprev, {description = "view previous", group = "tag"}),
    awful.key({modkey, "Control"}, "Right", awful.tag.viewnext, {description = "view next", group = "tag"}),
    awful.key({modkey}, "Escape", awful.tag.history.restore, {description = "go back", group = "tag"}),
    awful.key({modkey, }, "Tab",
        function ()
            -- awful.client.focus.history.previous()
            awful.client.focus.byidx(-1)
            if client.focus then
                client.focus:raise()
            end
        end),
        -- Show/Hide Wibox
        awful.key(
            {modkey},
            "b",
            function()
                for s in screen do
                    s.mywibox.visible = not s.mywibox.visible
                    if s.mybottomwibox then
                        s.mybottomwibox.visible = not s.mybottomwibox.visible
                    end
                end
            end,
        {description = "toggle wibox", group = "awesome"}),
        awful.key({modkey},
            "Return",
            function()
                awful.spawn(terminal)
            end,
        {description = "open a terminal", group = "launcher"}),
        awful.key({modkey, "Control"}, "r", awesome.restart, {description = "reload awesome", group = "awesome"}),
        awful.key({modkey, "Shift"}, "q", awesome.quit, {description = "quit awesome", group = "awesome"}),
        awful.key(
            {modkey},
            "space",
            function()
                awful.layout.inc(1)
            end,
        {description = "select next layout", group = "layout"}),
        -- User programs
        awful.key(
            {modkey},
            "q",
            function()
                awful.spawn(browser)
            end,
        {description = "run browser", group = "launcher"}),
        awful.key(
            {modkey},
            "a",
            function()
                awful.spawn(gui_editor)
            end,
        {description = "run gui editor", group = "launcher"}))
        
        local clientkeys =
        my_table.join(
            awful.key(
                {modkey, "Shift"},
                "c",
                function(c)
                    c:kill()
                end,
            {description = "close", group = "client"}),
            awful.key(
                {modkey},
                "z",
                function(c)
                    c:move_to_screen()
                end,
            {description = "move to other screen", group = "client"}),
            awful.key(
                {modkey},
                "n",
                function(c)
                    -- The client currently has the input focus, so it cannot be
                    -- minimized, since minimized clients can't have the focus.
                    c.minimized = true
                end,
            {description = "minimize", group = "client"}),
            awful.key(
                {modkey, "Shift"},
                "m",
                function(c)
                    c.maximized = not c.maximized
                    c:raise()
                end,
            {description = "maximize", group = "client"}))
            
            local clientbuttons =
            gears.table.join(
                awful.button(
                    {},
                    1,
                    function(c)
                        c:emit_signal("request::activate", "mouse_click", {raise = true})
                    end
                ),
                awful.button(
                    {modkey},
                    1,
                    function(c)
                        c:emit_signal("request::activate", "mouse_click", {raise = true})
                        awful.mouse.client.move(c)
                    end
                ),
                awful.button(
                    {modkey},
                    3,
                    function(c)
                        c:emit_signal("request::activate", "mouse_click", {raise = true})
                        awful.mouse.client.resize(c)
                    end
                ))
                
                return function()
                    return globalkeys, clientkeys, clientbuttons
                end
                
