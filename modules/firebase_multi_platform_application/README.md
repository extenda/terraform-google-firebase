# Firebase Multi-Platform App

This module provides a comprehensive bootstrap for a Firebase project, including project initialization and the creation of platform-specific apps (Web, Apple, Android).

Two submodules are available depending on your use case:

| Module                                    | Use when                                                                    |
|-------------------------------------------|-----------------------------------------------------------------------------|
| `firebase_multi_platform_application`     | You need **one logical app group** (one web + one Android + one Apple app)  |
| `firebase_multi_platform_application/apps`| You need **multiple independent apps** within a single Firebase project     |

## Features

- **Project Initialization**: Converts a standard Google Cloud project into a Firebase project.
- **Multi-Platform App Creation**: Register Web, Android, and Apple apps simultaneously.
- **Secure Configuration Outputs**: Retrieves and outputs `google-services.json`, `GoogleService-Info.plist`, and Web SDK snippets as sensitive values.
- **App Check support**: Outputs a structured `app_check_bundle` compatible with the Firebase App Check module.

---

## Usage: single app group

```hcl
module "firebase_app" {
  source     = "./modules/firebase_multi_platform_application"
  project_id = "my-project-id"

  apps = {
    web_app = {
      display_name = "My App"
    }
    android_app = {
      display_name = "My App"
      package_name = "com.example_app.checkout"
    }
    apple_app = {
      display_name = "My App"
      bundle_id    = "com.example-app.checkout"
    }
  }
}
```

## Usage: multiple apps (`apps/` wrapper)

Use this wrapper when you need to register multiple independent apps in a single Terraform plan — for example, one app per brand or tenant within the same Firebase project.

```hcl
module "firebase_apps" {
  source     = "./modules/firebase_multi_platform_application/apps"
  project_id = "my-project-id"

  apps = [
    {
      display_name = "Checkout app ISRG"
      android = { package_name = "com.example_isrg.checkout" }
      ios     = { bundle_id    = "com.example-isrg.checkout" }
    },
    {
      display_name = "Checkout app ICA"
      android = { package_name = "com.example_ica.checkout" }
      ios     = { bundle_id    = "com.example-ica.checkout" }
      web     = {}
    },
  ]
}
```

### Platform naming conventions

| Platform | Field          | Allowed characters                                  | Example                    |
|----------|----------------|-----------------------------------------------------|----------------------------|
| Android  | `package_name` | Letters, digits, underscores, dots. **No hyphens.** | `com.example_app.checkout` |
| iOS      | `bundle_id`    | Letters, digits, hyphens, dots. **No underscores.** | `com.example-app.checkout` |

Both constraints are enforced by input validations — an invalid format will fail at `plan` time with a clear error message.

### Outputs (`apps/` wrapper)

| Name               | Description                                                                                      |
| ------------------ | ------------------------------------------------------------------------------------------------ |
| `project_id`       | The project ID.                                                                                  |
| `app_ids`          | Nested map of Firebase App IDs keyed by `display_name` then platform (`android`, `ios`, `web`).  |
| `android_configs`  | Map of `google-services.json` contents keyed by `display_name` (sensitive).                      |
| `apple_configs`    | Map of `GoogleService-Info.plist` contents keyed by `display_name` (sensitive).                  |
| `web_configs`      | Map of Web SDK config snippets keyed by `display_name` (sensitive).                              |
| `app_check_bundle` | Aggregated App Check bundle for all apps with App Check enabled.                                 |

---

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| apps | Configuration for Firebase apps. If you leave all the inputs of the app (ios, android, or web details) empty, the app will not be created. Only filled input for app will be created. | <pre>object({<br>    web_app = optional(object({<br>      display_name = optional(string)<br>      api_key_id   = optional(string)<br>      app_check_config = optional(object({<br>        enable             = optional(bool)<br>        recaptcha_site_key = optional(string)<br>        debug_tokens = optional(list(object({<br>          display_name = optional(string)<br>          token        = string<br>        })))<br>      }))<br>    }))<br>    android_app = optional(object({<br>      package_name  = optional(string)<br>      display_name  = optional(string)<br>      sha256_hashes = optional(list(string))<br>      app_check_config = optional(object({<br>        enable = optional(bool)<br>        debug_tokens = optional(list(object({<br>          display_name = optional(string)<br>          token        = string<br>        })))<br>      }))<br>    }))<br>    apple_app = optional(object({<br>      bundle_id    = optional(string)<br>      display_name = optional(string)<br>      team_id      = optional(string)<br>      app_check_config = optional(object({<br>        enable_app_attest   = optional(bool)<br>        enable_device_check = optional(bool)<br>        device_check_key    = optional(string)<br>        device_check_id     = optional(string)<br>        debug_tokens = optional(list(object({<br>          display_name = optional(string)<br>          token        = string<br>        })))<br>      }))<br>    }))<br>  })</pre> | `{}` | no |
| project\_id | The GCP project ID to initialize Firebase in. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| android\_config | The google-services.json content for the Android App. |
| app\_check\_bundle | A structured object containing verified app IDs and metadata tailored for the Firebase App Check module. |
| app\_ids | List of Firebase App IDs provisioned by this module. |
| apple\_config | The GoogleService-Info.plist content for the Apple App. |
| project\_id | The project ID. |
| web\_config | The configuration snippet for the Firebase Web App. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
