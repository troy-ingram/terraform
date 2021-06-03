
resource "aws_ecs_cluster" "default" {
  name = "centos-ecs-cluster"
}

resource "aws_ecs_task_definition" "service" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "centos"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "centos" {
  name            = "centos"
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
}