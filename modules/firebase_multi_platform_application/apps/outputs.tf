/**
 * Copyright 2026 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "project_id" {
  description = "The project ID."
  value       = var.project_id
}

output "app_ids" {
  description = "Map of Firebase App IDs keyed by display name and platform (android, ios, web)."
  value = {
    for app in var.apps : app.display_name => merge(
      app.web != null ? { web = google_firebase_web_app.default[app.display_name].app_id } : {},
      app.android != null ? { android = google_firebase_android_app.default[app.display_name].app_id } : {},
      app.ios != null ? { ios = google_firebase_apple_app.default[app.display_name].app_id } : {}
    )
  }
}

output "web_configs" {
  description = "Map of web app configuration snippets keyed by display name."
  sensitive   = true
  value       = { for k, v in data.google_firebase_web_app_config.default : k => v }
}

output "android_configs" {
  description = "Map of google-services.json contents keyed by display name."
  sensitive   = true
  value       = { for k, v in data.google_firebase_android_app_config.default : k => v.config_file_contents }
}

output "apple_configs" {
  description = "Map of GoogleService-Info.plist contents keyed by display name."
  sensitive   = true
  value       = { for k, v in data.google_firebase_apple_app_config.default : k => v.config_file_contents }
}

output "app_check_bundle" {
  description = "Structured object containing app IDs and metadata for all apps with App Check enabled, tailored for the Firebase App Check module."
  value = {
    android = [for app in var.apps : {
      app_id    = google_firebase_android_app.default[app.display_name].app_id
      token_ttl = null
    } if app.android != null && coalesce(try(app.android.app_check_config.enable, false), false)]

    apple = [for app in var.apps : {
      app_id     = google_firebase_apple_app.default[app.display_name].app_id
      token_ttl  = null
      app_attest = coalesce(try(app.ios.app_check_config.enable_app_attest, false), false) ? true : null
      device_check = coalesce(try(app.ios.app_check_config.enable_device_check, false), false) && try(app.ios.app_check_config.device_check_key, null) != null && try(app.ios.app_check_config.device_check_id, null) != null ? {
        private_key = app.ios.app_check_config.device_check_key
        key_id      = app.ios.app_check_config.device_check_id
      } : null
    } if app.ios != null && (coalesce(try(app.ios.app_check_config.enable_app_attest, false), false) || coalesce(try(app.ios.app_check_config.enable_device_check, false), false))]

    web = [for app in var.apps : {
      app_id              = google_firebase_web_app.default[app.display_name].app_id
      site_key            = try(app.web.app_check_config.recaptcha_site_key, null)
      recaptcha_v3_secret = null
      token_ttl           = null
    } if app.web != null && coalesce(try(app.web.app_check_config.enable, false), false)]

    debug_tokens = flatten([
      [for app in var.apps : [
        for token in coalesce(try(app.android.app_check_config.debug_tokens, null), []) : {
          app_id       = google_firebase_android_app.default[app.display_name].app_id
          display_name = token.display_name
          token        = token.token
        }
      ] if app.android != null],
      [for app in var.apps : [
        for token in coalesce(try(app.ios.app_check_config.debug_tokens, null), []) : {
          app_id       = google_firebase_apple_app.default[app.display_name].app_id
          display_name = token.display_name
          token        = token.token
        }
      ] if app.ios != null],
      [for app in var.apps : [
        for token in coalesce(try(app.web.app_check_config.debug_tokens, null), []) : {
          app_id       = google_firebase_web_app.default[app.display_name].app_id
          display_name = token.display_name
          token        = token.token
        }
      ] if app.web != null]
    ])
  }
}
