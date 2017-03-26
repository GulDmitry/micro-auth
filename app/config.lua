-- config.lua
local config = require("lapis.config")

config({"development", "production"}, {
  secret = os.getenv("SECRET") or config.secret,
  app_url = os.getenv("APP_URL") or "http://localhost:8080",
  github = {
    client_id = os.getenv("GITHUB_CLIENT_ID"),
    client_secret = os.getenv("GITHUB_CLIENT_SECRET"),
    redirect_uri = os.getenv("GITHUB_REDIRECT_URL")
  },
  google = {
    client_id = os.getenv("GOOGLE_CLIENT_ID"),
    client_secret = os.getenv("GOOGLE_CLIENT_SECRET"),
    redirect_uri = os.getenv("GOOGLE_REDIRECT_URL"),
    scope = os.getenv("GOOGLE_SCOPE") or "https://www.googleapis.com/auth/plus.me"
  },
  local_auth = {
    redirect_uri = os.getenv("LOCAL_REDIRECT_URL"),
  }
})

config("development", {
  port = 8080,
  code_cache = "off"
})

config("production", {
  num_workers = 4,
  port = 8080,
  code_cache = "on"
})
