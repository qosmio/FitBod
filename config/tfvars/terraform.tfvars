gke_version = "latest"

pg_name        = "fitbod"
pg_version     = "POSTGRES_14"
project_id     = "zkhan-1"
project_name   = "fitbod"
db_user        = "fitbod-adm"
app_image_name = "fitbodinc/my_workout:0.1.0"

app_name = "myworkout"
app_user_pass = {
  "admin" = {
    email    = "admin@example.com"
    password = ""
  },
  "user1" = {
    email    = "user1@fitbod.me"
    password = ""
  }
}
