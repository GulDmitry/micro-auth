local Template = require('pl.text').Template
local lapis_util = require("lapis.util")
local encoding = require "lapis.util.encoding"
local jwt = require "resty.jwt"
local validators = require "resty.jwt-validators"
local config = require("lapis.config").get()
local resty_random = require "resty.random"

local _M = {}
local issuer = "micro-auth"

function _M.createRedirectHTML(url, data)
  local htmlTemplate = [[<!DOCTYPE html>
          <meta charset=utf-8>
          <title>Redirecting…</title>
          <meta http-equiv=refresh content='0;URL=${url}'>
          <script>location="${url}"</script>]]
  local t = Template(htmlTemplate)

  return t:substitute { url = url .. "?" .. lapis_util.encode_query_string(data) }
end

function _M.encodeJWT(data)
  local iat = os.time()
  local nbf = iat + 1
  local payload = {
    data = data,
    jti = encoding.encode_base64(resty_random.bytes(32)), -- Unique token id.
    iss = issuer, -- Issuer.
    iat = iat, -- Issued at.
    nbf = nbf, -- Not before.
--    exp = nbf + 60 * 60 * 24 * 10 -- Expire. 10 days.
    exp = nbf + 20
  }

  return jwt:sign(config.secret,
    {
      header = {
        typ = "JWT",
        alg = "HS256"
      },
      payload = payload
    })
end

-- Return nil in case of invalid token.
function _M.decodeJWT(token)
  local claim_spec = {
    iss = validators.equals_any_of({ issuer }),
    __jwt = validators.chain(validators.require_one_of({ "data" })),
    exp = validators.opt_is_not_expired(),
  }
  local jwt_obj = jwt:verify(config.secret, token, claim_spec)

  if jwt_obj.verified == false or jwt_obj.valid == false then
    return
  end
  return jwt_obj
end

return _M
