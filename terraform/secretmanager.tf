resource "aws_secretsmanager_secret" "docker-auth" {
  name = "docker-auth"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "docker-auth" {
  secret_id     = "${aws_secretsmanager_secret.docker-auth.id}"
  secret_string = "${jsonencode(map("username", "iliazlobin", "password", "U4aUi4DpsgXJfgN"))}"
}
