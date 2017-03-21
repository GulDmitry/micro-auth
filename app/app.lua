local lapis = require("lapis")
local utils = require "utils"
local lapis_util = require "lapis.util"

local github = require("github")
local google = require("google")
local localAuth = require("local")

local app = lapis.Application()
local app_helpers = require "lapis.application"

app:enable("etlua")
app.layout = require "views.layout"

-- TODO: logout

-- Called before every action.
app:before_filter(function(self)
  -- JWT token.
  if self.session.token then
    local token = utils.decodeJWT(self.session.token)
    if token ~= nil then
      self.jwt_token = lapis_util.to_json(token)
    end
  end
end)

app.default_route = function(self)
  -- strip trailing /
  if self.req.parsed_url.path:match("./$") then
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

app:match("index", "/", function() return { render = "index" } end)

-- TODO: get payload from every auth strategy
-- convert it to the jwt
-- store the token as a base64 cookie
-- in the `before_filter` check the cookie and show the json.

-- Github authorization
app:get("/auth/github", github.authorize)
app:get("/auth/github/callback", github.callback)

-- Google authorization
app:get("/auth/google", google.authorize)
app:get("/auth/google/callback", google.callback)

-- Local authorization
app:match("local-auth", "/auth/local", app_helpers.respond_to({
  before = function(self)
    if self.session.token and utils.decodeJWT(self.session.token) then
      self:write({ redirect_to = self:url_for("index") })
    end
  end,
  GET = function()
    return { render = "signin" }
  end,
  POST = function(self)
    local user = localAuth.authorize(self);
    if user == nil then
      -- TODO: error message if the method cannot find a user.
      return
    end

    local jwt_token = utils.encodeJWT(user)
    self.session.token = jwt_token

--    Does NOT change the url
--    return { render = "index" }
    self:write({ redirect_to = self:url_for("index") })
  end
}))

app.handle_404 = function(self)
  error("Failed to find route: " .. self.req.cmd_url)
  -- To make this work comment the `default_route`
  --  return { status = 404, layout = false, "Not Found!" }
end

return app
