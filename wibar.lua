local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local lain = require("lain")
require("vars")
local markup = lain.util.markup
local separators = lain.util.separators
local dpi = require("beautiful.xresources").apply_dpi

local clock = wibox.widget.textclock(" %d.%m. | %H:%M")
local calendar = wibox.widget.calendar.month(os.date('*t'))
calendar.font = font

local memory_usage = lain.widget.mem({
    settings = function()
        text = string.format("%sMB/%s", mem_now.used, mem_now.total)
        widget:set_markup(markup.font(font, " " .. text .. "MB "))
    end
})
local cpu_usage = lain.widget.cpu({
    settings = function()
        cores = ""
        for i = 1, 4, 1 do cores = cores .. cpu_now[i].usage .. "% " end
        widget:set_markup(markup.font(font, " " .. cores))
    end
})
local battery = lain.widget.bat({
    settings = function()
        if bat_now.ac_status == 1 then
            widget:set_markup(markup.font(font, " AC "))
            return
        end
        widget:set_markup(markup.font(font, " Battery: " .. bat_now.perc .. "%"))
    end
})

local network = lain.widget.net({
    settings = function()
        widget:set_markup(markup.font(font, " " .. net_now.received ..
                                          " ↓↑ " .. net_now.sent .. ""))
    end
})
local arrow = separators.arrow_left

local widget_colors = {
    filler = "#282a36",
    clock = "#ffaac3",
    net = "#f8b195",
    temp = "#f67280",
    cpu = "#c06c84",
    mem = "#6c567b"
}

awful.screen.connect_for_each_screen(function(s)
    awful.tag({"1", "2"}, s, awful.layout.layouts[1])
    s.layoutbox = awful.widget.layoutbox(s)
    s.layoutbox:buttons(gears.table.join(
                            awful.button({}, 1,
                                         function() awful.layout.inc(1) end),
                            awful.button({}, 3,
                                         function() awful.layout.inc(-1) end),
                            awful.button({}, 4,
                                         function() awful.layout.inc(1) end),
                            awful.button({}, 5,
                                         function() awful.layout.inc(-1) end)))
    s.taglist = awful.widget.taglist(s, awful.widget.taglist.filter.all)

    s.topbar = awful.wibar({
        position = "top",
        screen = s,
        bg = "#282a36",
        wibar_shape = gears.shape.rounded_rect
    })

    s.topbar:setup{
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.fixed.horizontal,
            s.taglist,
            wibox.widget.systray()
        },
        nil,
        {
            layout = wibox.layout.fixed.horizontal,
            arrow(alpha, widget_colors.filler),
            arrow(widget_colors.filler, widget_colors.clock),
            wibox.container.background(wibox.container.margin(
                                           wibox.widget {
                    _,
                    network.widget,
                    layout = wibox.layout.align.horizontal
                }, dpi(2), dpi(3)), widget_colors.clock),
            arrow(widget_colors.clock, widget_colors.net),
            wibox.container.background(wibox.container.margin(
                                           wibox.widget {
                    _,
                    battery.widget,
                    layout = wibox.layout.align.horizontal
                }, dpi(2), dpi(3)), widget_colors.net),
            arrow(widget_colors.net, widget_colors.temp),
            wibox.container.background(wibox.container.margin(
                                           wibox.widget {
                    _,
                    cpu_usage.widget,
                    layout = wibox.layout.align.horizontal
                }, dpi(2), dpi(3)), widget_colors.temp),
            arrow(widget_colors.temp, widget_colors.cpu),
            wibox.container.background(wibox.container.margin(
                                           wibox.widget {
                    _,
                    memory_usage.widget,
                    layout = wibox.layout.align.horizontal
                }, dpi(2), dpi(3)), widget_colors.cpu),
            arrow(widget_colors.cpu, widget_colors.clock),
            wibox.container.background(wibox.container.margin(
                                           wibox.widget {
                    _,
                    clock,
                    layout = wibox.layout.align.horizontal
                }, dpi(2), dpi(3)), widget_colors.clock)
        }
    }
end)

