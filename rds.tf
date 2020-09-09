resource "aws_db_instance" "rdsinstance" {
  allocated_storage    = 20
  max_allocated_storage= 40
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "admin"
  password             = "abcd1234"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  auto_minor_version_upgrade = true
  vpc_security_group_ids = [aws_security_group.rdssecure.id]
  publicly_accessible = true
  port = 3306
}