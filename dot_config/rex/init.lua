rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })
rex.bind("ctrl+a>ctrl+b", "pane.send_key", { key = "ctrl+a" })
rex.bind("ctrl+a>shift+'", "pane.split", { direction = "down" })
rex.bind("ctrl+a>shift+5", "pane.split", { direction = "right" })
rex.bind("ctrl+a>c", "client.tab.new")
rex.bind("ctrl+a>s", "pane.split", { direction = "down" })
rex.bind("ctrl+a>v", "pane.split", { direction = "right" })
rex.bind("alt+0", "client.tab.goto", { index = 0 })
rex.bind("alt+1", "client.tab.goto", { index = 1 })
rex.bind("alt+2", "client.tab.goto", { index = 2 })
rex.bind("alt+3", "client.tab.goto", { index = 3 })
rex.bind("alt+4", "client.tab.goto", { index = 4 })
rex.bind("alt+5", "client.tab.goto", { index = 5 })
rex.bind("alt+6", "client.tab.goto", { index = 6 })
rex.bind("alt+7", "client.tab.goto", { index = 7 })
rex.bind("alt+8", "client.tab.goto", { index = 8 })
rex.bind("alt+9", "client.tab.goto", { index = 9 })
rex.bind("alt+up", "session.next")
rex.bind("alt+down", "session.previous")

rex.bind("ctrl+b>ctrl+b", "pane.send_key", { key = "ctrl+b" })
rex.bind("ctrl+b>s","pane.split", { direction = "down" })
rex.bind("cmd+1", "client.tab.goto", { index = 1 })
rex.bind("cmd+2", "client.tab.goto", { index = 2 })
rex.bind("cmd+3", "client.tab.goto", { index = 3 })
rex.bind("cmd+4", "client.tab.goto", { index = 4 })
rex.bind("cmd+5", "client.tab.goto", { index = 5 })
rex.bind("cmd+6", "client.tab.goto", { index = 6 })
rex.bind("cmd+7", "client.tab.goto", { index = 7 })
rex.bind("cmd+8", "client.tab.goto", { index = 8 })
rex.bind("cmd+9", "client.tab.goto", { index = 9 })
rex.bind("ctrl+b>w", "session.switch")
rex.bind("ctrl+b>g", "session.switch")
rex.bind("ctrl+b>n", "session.next")
rex.bind("ctrl+b>p", "session.previous")

rex.bind("cmd+0", "pane.send_key", { key = "alt+0" })

rex.bind("ctrl+space", "pane.send_key", { key = "ctrl+space" })

local terminal = "com.superlogical.terminal"
local passthrough = {
  nvim = true, vim = true, vi = true, view = true, vimdiff = true,
  nvimdiff = true, gvim = true, fzf = true,
}

local function in_vim(ctx)
  local p = rex.block.call(terminal, "process", { block_id = ctx.block_id })
  local fg = p and p.foreground
  if fg == nil then return false end
  for _, v in ipairs({ fg.name, fg.argv0, fg.path }) do
    local base = type(v) == "string" and v:match("([^/]+)$")
    if base and passthrough[base] then return true end
  end
  return false
end

rex.action{
  name = "navfocus",
  title = "Focus Pane (no wrap)",
  args = { direction = "string" },
  run = function(ctx, args)
    rex.session.focus_direction{ direction = args.direction, wrap = false }
  end,
}

for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  local name = "nav_" .. dir
  rex.action{
    name = name,
    title = "Vim-aware Focus " .. dir,
    run = function(ctx, args)
      if in_vim(ctx) then
        rex.client.queue("pane.send_key", { key = "ctrl+" .. key })
      else
        rex.session.focus_direction{ direction = dir, wrap = false }
      end
    end,
  }
  rex.bind("ctrl+" .. key, name)
end

rex.bind("ctrl+a>x", "pane.close")

rex.bind("ctrl+b>v", "pane.split", { direction = "right" })
rex.bind("ctrl+b>x", "pane.close")
rex.bind("ctrl+b>z", "pane.zoom")

rex.bind("ctrl+b>c", "client.tab.new")

rex.bind("cmd+shift+c", "pane.copy_mode.enter")
rex.bind("ctrl+b>[", "pane.copy_mode.enter")

-- >>> leaf >>>
-- Managed by `leaf rex install`; `leaf rex uninstall` removes it.
-- plugin: 574a512c29e0d37d
dofile("/Users/hydrax/.config/rex/plugins/leaf/init.lua").setup({ bin = { "/opt/homebrew/bin/leaf" } })
-- open: idle classic
-- <<< leaf <<<
