local cjson = require "cjson"

local _M = {}

-- TODO: DB.
local fixtures = {
  { email = "ex@ex.com", password = "ex" },
  { email = "admin@ex.com", password = "admin" }
}

function _M.authorize(self)
  local user;

  -- TODO: remove
  print(cjson.encode(self.params))

  for _, v in pairs(fixtures) do
    if (v.email == self.params.email and v.password == self.params.password) then
      user = v
    end
  end
  if not user then
    return
  end

  -- TODO: remove
  print(cjson.encode(user))

  user.password = nil
  return user
end

return _M
