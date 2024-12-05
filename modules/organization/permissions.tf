data "aws_caller_identity" "main" {}
data "aws_ssoadmin_instances" "main" {}

resource "aws_iam_group" "main" {
  count = length(var.roles)

  name = var.roles[count.index].name
}

resource "aws_iam_group_policy_attachment" "main" {
  count = length(var.roles)

  group      = var.roles[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/${var.roles[count.index].policy}"

  depends_on = [
    aws_iam_group_policy_attachment.main
  ]
}

resource "aws_ssoadmin_permission_set" "main" {
  count = data.aws_ssoadmin_instances.main != null ? length(var.roles) : 0

  name = var.roles[count.index].name
  description = try(
    var.roles[count.index].description,
    "Permission set for organization accounts"
  )
  session_duration = "PT12H"

  instance_arn = data.aws_ssoadmin_instances.main.arns[0]

  tags = var.tags
}

resource "aws_ssoadmin_managed_policy_attachment" "main" {
  count = data.aws_ssoadmin_instances.main != null ? length(var.roles) : 0

  managed_policy_arn = "arn:aws:iam::aws:policy/${var.roles[count.index].policy}"
  permission_set_arn = aws_ssoadmin_permission_set.main[count.index].arn

  instance_arn = data.aws_ssoadmin_instances.main.arns[0]
}

resource "aws_identitystore_group" "main" {
  count = data.aws_ssoadmin_instances.main != null ? length(var.roles) : 0

  display_name = var.roles[count.index].name
  description = try(
    var.roles[count.index].description,
    "Role set for organization accounts"
  )

  identity_store_id = data.aws_ssoadmin_instances.main.identity_store_ids[0]
}

resource "aws_ssoadmin_account_assignment" "main" {
  count = data.aws_ssoadmin_instances.main != null ? length(var.roles) : 0

  permission_set_arn = aws_ssoadmin_permission_set.main[count.index].arn
  principal_id       = aws_identitystore_group.main[count.index].group_id
  principal_type     = "GROUP"

  target_id   = data.aws_caller_identity.main.account_id
  target_type = "AWS_ACCOUNT"

  instance_arn = data.aws_ssoadmin_instances.main.arns[0]
}
