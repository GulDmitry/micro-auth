local lapis = require("lapis")
local utils = require "utils"
local lapis_util = require "lapis.util"
local config = require("lapis.config").get()
local date = require "date"
local ck = require "resty.cookie"

local github = require("github")
local google = require("google")
local localAuth = require("local")

local app = lapis.Application()
local app_helpers = require "lapis.application"

app:enable("etlua")
app.layout = require "views.layout"

app.cookie_attributes = function()
  local expires = date(true):adddays(10):fmt("${http}")
  return "Expires=" .. expires .. "; Path=/; HttpOnly"
end

-- Called before every action.
app:before_filter(function(self)
  local pathsToStop = {};
  pathsToStop[self:url_for("index")] = true
  pathsToStop[self:url_for("logout")] = true
  if self.cookies.jwt_token and not pathsToStop[self.req.parsed_url.path] then
    self:write({ redirect_to = self:url_for("index") })
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

app:match("index", "/", function(self)
  if self.cookies.jwt_token then
    local token = utils.decodeJWT(self.cookies.jwt_token)
    if token ~= nil then
      self.jwt_token = lapis_util.to_json(token)
    end
  end
  return { render = "index" }
end)

-- Github authorization
app:get("/auth/github", github.authorize)
app:get("/auth/github/callback", github.callback)

-- Google authorization
app:get("/auth/google", google.authorize)
app:get("/auth/google/callback", google.callback)

-- Local authorization
app:match("local-auth", "/auth/local", app_helpers.respond_to({
  before = function() end,
  GET = function()
    return { render = "signin" }
  end,
  POST = function(self)
    local user = localAuth.authorize(self);
    if user == nil then
      -- TODO: error message if the method cannot find a user.
      return
    end

    local jwt_token = utils.encodeJWT({
      bearer = "local",
      user = user
    })
    self.cookies.jwt_token = jwt_token

    return {
      utils.createRedirectHTML(config.local_auth.redirect_uri, { access_token = jwt_token }),
      status = 200
    }
  end
}))

app:match("logout", "/logout", function(self)
  local cookie = ck:new()
  -- Expire.
  cookie:set({
    key = "jwt_token",
    value = "",
    expires = date(true)
  })
  return { redirect_to = self:url_for("index") }
end)

app.handle_404 = function(self)
  error("Failed to find route: " .. self.req.cmd_url)
  -- To make this work comment the `default_route`
  --  return { status = 404, layout = false, "Not Found!" }
end

return app
