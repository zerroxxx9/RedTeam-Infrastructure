variable "hcloud_token" {
  description = "Hetzner Cloud API token (Project > Security > API Tokens, read/write)."
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Your SSH public key, e.g. file(\"~/.ssh/id_ed25519.pub\")."
  type        = string
}

variable "admin_ssh_source_ip" {
  description = "CIDR allowed to SSH on port 22, e.g. \"203.0.113.7/32\". Use your current public IP."
  type        = string
}

variable "phish_domain" {
  description = "The domain recipients will see, e.g. \"mail-update.example.com\". You point its A record at the server."
  type        = string
}

variable "server_name" {
  description = "Server + tailnet hostname."
  type        = string
  default     = "gophish-engagement"
}

variable "server_type" {
  description = "Hetzner server type. Cheapest EU-available x86 shared vCPU. cpx12 (1 vCPU/2GB) is the cheap-but-safe pick; cpx02 (1 vCPU/1GB) is rock-bottom but may OOM during cloud-init; cx23 (2 vCPU/4GB) is comfortable. All available in fsn1/nbg1/hel1. (cpx11/cpx21 are US-only now.)"
  type        = string
  default     = "cpx12"

  # Cost guardrail: only cheap shared-vCPU types are allowed, so a typo or a
  # copied config can't accidentally provision an expensive box. Every type in
  # this list caps well under ~EUR 10/mo. `terraform plan` fails on anything else.
  validation {
    condition     = contains(["cpx02", "cpx12", "cpx22", "cx23", "cx33"], var.server_type)
    error_message = "Use a cheap EU-available shared type (cpx02/cpx12/cpx22/cx23/cx33). Widen this allowlist in variables.tf only if you deliberately want to spend more."
  }
}

variable "server_location" {
  description = "Hetzner location. fsn1 = Falkenstein (Germany)."
  type        = string
  default     = "fsn1"
}

variable "gophish_version" {
  description = "GoPhish release version (no leading v)."
  type        = string
  default     = "0.12.1"
}
