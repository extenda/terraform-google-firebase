/**
 * Wrapper module for managing multiple Firebase apps within a single project.
 *
 * This module initializes Firebase once for the project and then creates
 * multiple web, Android, and Apple apps in a single plan using for_each,
 * accepting the same app list format used in firebase.yaml.
 */

resource "google_firebase_project" "default" {
  provider = google-beta
  project  = var.project_id
}

resource "google_firebase_web_app" "default" {
  for_each     = { for app in var.apps : app.display_name => app if app.web != null }
  provider     = google-beta
  project      = google_firebase_project.default.project
  display_name = each.key
  api_key_id   = try(each.value.web.api_key_id, null)
}

resource "google_firebase_android_app" "default" {
  for_each      = { for app in var.apps : app.display_name => app if app.android != null }
  provider      = google-beta
  project       = google_firebase_project.default.project
  package_name  = each.value.android.package_name
  display_name  = coalesce(try(each.value.android.display_name, null), each.key)
  sha256_hashes = try(each.value.android.sha256_hashes, null)
}

resource "google_firebase_apple_app" "default" {
  for_each     = { for app in var.apps : app.display_name => app if app.ios != null }
  provider     = google-beta
  project      = google_firebase_project.default.project
  bundle_id    = each.value.ios.bundle_id
  display_name = coalesce(try(each.value.ios.display_name, null), each.key)
  team_id      = try(each.value.ios.team_id, null)
}

data "google_firebase_web_app_config" "default" {
  for_each   = google_firebase_web_app.default
  provider   = google-beta
  project    = google_firebase_project.default.project
  web_app_id = each.value.app_id
}

data "google_firebase_android_app_config" "default" {
  for_each = google_firebase_android_app.default
  provider = google-beta
  project  = google_firebase_project.default.project
  app_id   = each.value.app_id
}

data "google_firebase_apple_app_config" "default" {
  for_each = google_firebase_apple_app.default
  provider = google-beta
  project  = google_firebase_project.default.project
  app_id   = each.value.app_id
}
