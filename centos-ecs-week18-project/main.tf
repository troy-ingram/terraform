
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
  cluster         = aws_ecs_cluster.default.arn
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  # iam_role        = aws_iam_role.my_role.arn
  # depends_on      = [aws_iam_role_policy.my_policy]
}

# resource "aws_iam_role" "my_role" {
#   name = "my_role"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
#     "Version" : "2008-10-17",
#     "Statement" : [
#       {
#         "Sid" : "",
#         "Effect" : "Allow",
#         "Principal" : {
#           "Service" : "ec2.amazonaws.com"
#         },
#         "Action" : "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy" "my_policy" {
#   name = "my_policy"
#   role = aws_iam_role.my_role.id

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "ec2:DescribeTags",
#           "ecs:CreateCluster",
#           "ecs:DeregisterContainerInstance",
#           "ecs:DiscoverPollEndpoint",
#           "ecs:Poll",
#           "ecs:RegisterContainerInstance",
#           "ecs:StartTelemetrySession",
#           "ecs:UpdateContainerInstancesState",
#           "ecs:Submit*",
#           "ecr:GetAuthorizationToken",
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:BatchGetImage",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ],
#         "Resource" : "*"
#       }
#     ]
#   })
# }