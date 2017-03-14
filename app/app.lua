local lapis = require("lapis")
local config = require("lapis.config").get()

local github = require("github")
local google = require("google")

local app = lapis.Application()
app:enable("etlua")
app.layout = require "views.layout"

-- Github authorization
app:get("/auth/github", github.authorize)
app:get("/auth/github/callback", github.callback)

-- Google authorization
app:get("/auth/google", google.authorize)
app:get("/auth/google/callback", google.callback)

app:get("/", function(self)
  --  return config.greeting .. "Welcome to Lapis " .. require("lapis.version")

  self.my_favorite_things = {
    "Cats",
    "Horses",
    "Skateboards"
  }
  return { render = "index" }
end)

return app
