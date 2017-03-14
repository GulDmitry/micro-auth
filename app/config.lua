-- config.lua
local config = require("lapis.config")

config({"development", "production"}, {
  greeting = "greeting from config",
--  host = "example.com",
--  email_enabled = false,
--  postgres = {
--    host = "localhost",
--    port = "5432",
--    database = "my_app"
--  }
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
  }
})

config("development", {
  port = 8080,
  code_cache = "off"
})

config("production", {
--  email_enabled = true,
--  postgres = {
--    database = "my_app_prod"
--  }
  num_workers = 4,
  port = 8080,
  code_cache = "on"
})
