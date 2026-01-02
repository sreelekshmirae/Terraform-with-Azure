resource "azuread_group" "engineering" {
  display_name     = "IT Department"
  security_enabled = true
}

resource "azuread_group_member" "engineering_members" {
  for_each = { for k, u in azuread_user.users : k => u if u.department == "IT Department" }

  group_object_id  = azuread_group.engineering.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "manager" {
  display_name     = "IT - Manager"
  security_enabled = true
}

resource "azuread_group_member" "manager" {
  for_each = { for k, u in azuread_user.users : k => u if u.job_title == "Manager" }

  group_object_id  = azuread_group.manager.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "developers" {
  display_name     = "IT - Developer"
  security_enabled = true
}

resource "azuread_group_member" "developers" {
  for_each = { for k, u in azuread_user.users : k => u if u.job_title == "Developer" }

  group_object_id  = azuread_group.developers.object_id
  member_object_id = each.value.object_id
}
