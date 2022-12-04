resource "aws_ecs_task_definition" "service" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "service-first"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
    {
      name      = "second"
      image     = "service-second"
      cpu       = 10
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 443
          hostPort      = 443
        }
      ]
    }
  ])

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}

#resource "aws_ecs_task_definition" "service" {
#  family                = "service"
#  container_definitions = file("task-definitions/service.json")
#
#  volume {
#    name = "service-storage"
#
#    efs_volume_configuration {
#      file_system_id          = aws_efs_file_system.fs.id
#      root_directory          = "/opt/data"
#      transit_encryption      = "ENABLED"
#      transit_encryption_port = 2999
#      authorization_config {
#        access_point_id = aws_efs_access_point.test.id
#        iam             = "ENABLED"
#      }
#    }
#  }
#}