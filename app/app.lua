local lapis = require("lapis")
local config = require("lapis.config").get()
local util = require("lapis.util")

local github = require("github")
local google = require("google")

local app = lapis.Application()
app:enable("etlua")
app.layout = require "views.layout"

app.handle_404 = function(self)
  print("Handle 404")
--  error("Failed to find route: " .. self.req.cmd_url)
-- To make this work comment the `default_route`
  return { status = 404, layout = false, "Not Found!" }
end

app.default_route = function(self)
  print("Default Route")

  -- strip trailing /
  if self.req.parsed_url.path:match("./$") then

    --    print(util.to_json(self.req.parsed_url))

    local stripped = self.req.parsed_url.path:match("^(.+)/+$")
    return {
      redirect_to = self:build_url(stripped, {
        status = 301,
        query = self.req.parsed_url.query,
      })
    }
  end

  self.app.handle_404(self)
end

-- Github authorization
app:get("/auth/github", github.authorize)
app:get("/auth/github/callback", github.callback)

-- Google authorization
app:get("/auth/google", google.authorize)
app:get("/auth/google/callback", google.callback)

--- -Before every action, can be multiply
-- app:before_filter(function(self)
-- if self.session.user then
-- self.current_user = load_user(self.session.user)
-- end
-- if not user_meets_requirements() then
-- -- Interrupt the method
-- self:write({redirect_to = self:url_for("login")})
-- end
-- end)

-- Routes. app:delete/put/post
-- self. parameters http://leafo.net/lapis/reference/actions.html

app:match("index", "/", function(self)
  --  return config.greeting .. "Welcome to Lapis " .. require("lapis.version")

  self.my_favorite_things = {
    "Cats",
    "Horses",
    "Skateboards"
  }
  --  return { render = "index" }
end)

--app:match("create_account", "/create-account", respond_to({
--  before = function(self)
--    self.user = Users:find(self.params.id)
--    if not self.user then
--      self:write({"Not Found", status = 404})
--    end
--  end,
--  GET = function(self)
--    return { render = true }
--  end,
--  POST = function(self)
--    do_something(self.params)
--    return { redirect_to = self:url_for("index") }
--  end
--}))

return app
