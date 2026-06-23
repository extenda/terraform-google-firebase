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

variable "project_id" {
  description = "The GCP project ID to initialize Firebase in."
  type        = string
}

variable "apps" {
  description = "List of Firebase apps to create. Each entry must have a unique display_name and at least one platform (web, android, ios) configured."
  type = list(object({
    display_name = string
    web = optional(object({
      api_key_id = optional(string)
      app_check_config = optional(object({
        enable             = optional(bool)
        recaptcha_site_key = optional(string)
        debug_tokens = optional(list(object({
          display_name = optional(string)
          token        = string
        })))
      }))
    }))
    android = optional(object({
      package_name  = string
      display_name  = optional(string)
      sha256_hashes = optional(list(string))
      app_check_config = optional(object({
        enable = optional(bool)
        debug_tokens = optional(list(object({
          display_name = optional(string)
          token        = string
        })))
      }))
    }))
    ios = optional(object({
      bundle_id    = string
      display_name = optional(string)
      team_id      = optional(string)
      app_check_config = optional(object({
        enable_app_attest   = optional(bool)
        enable_device_check = optional(bool)
        device_check_key    = optional(string)
        device_check_id     = optional(string)
        debug_tokens = optional(list(object({
          display_name = optional(string)
          token        = string
        })))
      }))
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for app in var.apps :
      can(regex("^[a-zA-Z][a-zA-Z0-9_]*(\\.[a-zA-Z][a-zA-Z0-9_]*)+$", app.android.package_name))
      if app.android != null
    ])
    error_message = "Android package names must follow Java naming conventions: only letters, digits, and underscores, no hyphens."
  }

  validation {
    condition = alltrue([
      for app in var.apps :
      can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*(\\.[a-zA-Z0-9][a-zA-Z0-9-]*)+$", app.ios.bundle_id))
      if app.ios != null
    ])
    error_message = "iOS bundle IDs must follow reverse DNS notation: only letters, digits, hyphens, and periods. Underscores are not allowed."
  }

  validation {
    condition = alltrue([
      for app in var.apps :
      try(app.android.app_check_config.enable, null) != true || try(length(app.android.sha256_hashes), 0) > 0
      if app.android != null
    ])
    error_message = "If App Check is enabled for an Android app, at least one 'sha256_hashes' value must be provided."
  }

  validation {
    condition = alltrue([
      for app in var.apps :
      (try(app.ios.app_check_config.enable_app_attest, null) != true && try(app.ios.app_check_config.enable_device_check, null) != true) || try(app.ios.team_id, null) != null
      if app.ios != null
    ])
    error_message = "If App Check (App Attest or DeviceCheck) is enabled for an Apple app, 'team_id' must be provided."
  }
}
