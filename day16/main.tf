data "azuread_domains" "aad" {
  only_initial = true
}

locals {

  domain_name = data.azuread_domains.aad.domains.0.domain_name
  users       = csvdecode(file("users.csv"))
}

resource "azuread_user" "users" {
  for_each = { for user in local.users : user.first_name => user }

  user_principal_name = format("%s%s@%s",
    lower(substr(each.value.first_name, 0, 1)),
    lower(each.value.last_name),
  local.domain_name)

  password = format("%s%s@%d!%s",
    upper(substr(each.value.first_name, 0, 1)),
    substr(each.value.first_name, 1, -1),
    length(each.value.first_name),
  upper(substr(each.value.last_name, 0, 1)))

  display_name = "${each.value.first_name} ${each.value.last_name}"

  force_password_change = true #this means user has to change the password after first login

  department = each.value.department

  job_title = each.value.job_title
}

output "domain" {
  value = local.domain_name
}

output "username" {
  value = [for user in local.users : "${user.first_name} ${user.last_name} - ${user.job_title}"]
}
