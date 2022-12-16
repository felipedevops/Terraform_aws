#resource "aws_kms_key" "example" {
#  description             = "example"
#  deletion_window_in_days = 7
#}

resource "aws_cloudwatch_log_group" "ecs_cloudwatch" {
  name = "${var.infra_env}_ecs_aws_cloudwatch"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.infra_env}_ecs_cluster"
  tags = {
    Env  = "${var.infra_env}"
    Name = "${var.infra_env}"
  }
  configuration {
    execute_command_configuration {
      #kms_key_id = aws_kms_key.example.arn
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_cloudwatch.name
      }
    }
  }
}


resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                = "hello_world"
  container_definitions = <<DEFINITION
  [
    {
      "name": "hello-world",
      "image": "nginx:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],
      "memory": 500,
      "cpu": 10
    }
  ]
  DEFINITION
}

#resource "aws_ecs_service" "service" {
#  name            = "mongodb"
#  cluster         = aws_ecs_cluster.foo.id
#  task_definition = aws_ecs_task_definition.service.arn
#  desired_count   = 3
#  iam_role        = aws_iam_role.foo.arn
#  depends_on      = [aws_iam_role_policy.foo]
#
#  ordered_placement_strategy {
#    type  = "binpack"
#    field = "cpu"
#  }
#
#  load_balancer {
#    target_group_arn = aws_lb_target_group.foo.arn
#    container_name   = "mongo"
#    container_port   = 8080
#  }
#
#  placement_constraints {
#    type       = "memberOf"
#    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
#  }
#}

resource "aws_launch_configuration" "ecs-launch-configuration" {
  name                 = "${var.infra_env}_ecs-launch-configuration"
  image_id             = var.amiid
  instance_type        = "t2.micro"
  key_name             = var.ssh-key
  iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile.id

  root_block_device {
    volume_type           = "standard"
    volume_size           = 100
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  security_groups             = ["${aws_security_group.public.id}"]
  associate_public_ip_address = "true"
  user_data = <<-EOF
    #!/bin/bash
    set -x
    #====== Install ECS
    yum update -y
    amazon-linux-extras disable docker
    amazon-linux-extras install -y ecs
    echo ECS_CLUSTER="main_ecs_cluster" >> ~/ecs.config
    mv ~/ecs.config /etc/ecs/ecs.config
    systemctl enable --now --no-block ecs.service
    yum install -y ecs-init
    cp /usr/lib/systemd/system/ecs.service /etc/systemd/system/ecs.service
    sed -i '/After=cloud-final.service/d' /etc/systemd/system/ecs.service
    systemctl daemon-reload
    EOF
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "tdemo-ecs-instance-profile"
  path = "/"
  role = aws_iam_role.iam_for_ecs.id
  #provisioner "local-exec" {
  #  command = "ping 127.0.0.1 -n 11 > nul"
  #}
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
  name                 = "${var.infra_env}_asg"
  vpc_zone_identifier  = ["${aws_subnet.PrivateSubnet4.id}", "${aws_subnet.PublicSubnet1.id}"]
  launch_configuration = aws_launch_configuration.ecs-launch-configuration.name

  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 5
  health_check_grace_period = 300
  health_check_type         = "EC2"
}