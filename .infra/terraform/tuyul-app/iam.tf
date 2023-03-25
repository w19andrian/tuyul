locals {
  policy_json = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : [
          "${data.aws_secretsmanager_secret.docker_hub.arn}",
        ]
      }
    ]
  })

}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = local.full_app_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = local.user_def_tags
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy" "docker_hub_auth" {
  name   = "${local.full_app_name}-dockerhub-auth-policy"
  path   = "/app/${var.env}/${var.app_name}/"
  policy = local.policy_json
}

resource "aws_iam_role_policy_attachment" "docker_hub_auth" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.docker_hub_auth.arn
}
