local jwt = require "resty.jwt"
local cjson = require "cjson"
local validators = require "resty.jwt-validators"
local config = require("lapis.config").get()
local util = require("lapis.util")

local _M = {}

-- TODO: DB.
local fixtures = {
  { email = "ex@ex.com", password = "ex" },
  { email = "admin@ex.com", password = "admin" }
}

-- Sign
function _M.authorize(self)
  local user = null;

  print(util.to_json(self.params))

  for _, v in pairs(fixtures) do
    if (v.email == self.params.email and v.password == self.params.password) then
      user = v
    end
  end
  if not user then
    return
  end

  print(util.to_json(user))

  local jwt_token = jwt:sign(config.secret,
    {
      header = {
        typ = "JWT",
        alg = "HS256"
      },
      payload = {
        iss = "micro-auth",
        exp = os.time() + 10, -- TODO: increase
        email = user.email
      }
    })
  -- TODO: move outside.
  self.session.token = jwt_token
  return jwt_token
end

function _M.verify(jwt_token)
  local claim_spec = {
    iss = validators.equals_any_of({ "micro-auth" }),
    __jwt = validators.chain(validators.require_one_of({ "email" })),
    exp = validators.opt_is_not_expired(),
  }
  local jwt_obj = jwt:verify(config.secret, jwt_token, claim_spec)

  print("TOKEN:" .. cjson.encode(jwt_obj))

  if jwt_obj.verified == false or jwt_obj.valid == false then
    return false
  end
  return true
end

return _M
