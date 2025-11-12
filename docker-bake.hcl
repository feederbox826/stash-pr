variable "OWNER_NAME" {
  type    = string
  default = "feederbox826"
}

variable "TARGET_BRANCH" {
  type    = string
  default = "main"
}

group "default" {
  targets = ["s6", "s6-hwaccel", "stashapp", "nerethos"]
}

target "_common" {
  secret = [{
    type = "env"
    id = "GITHUB_TOKEN"
  }]
  cache-to = [{
    type = "gha"
    mode = "max"
  }]
  cache-from = [{
    type = "gha"
  }]
}

target "s6" {
  inherits = ["_common"]
  target = "stash-s6"
  tags = ["ghcr.io/${OWNER_NAME}/stash-pr:s6-${TARGET_BRANCH}"]
}

target "s6-hwaccel" {
  inherits = ["_common"]
  target = "stash-s6-hwaccel"
  tags = ["ghcr.io/${OWNER_NAME}/stash-pr:s6-hwaccel-${TARGET_BRANCH}"]
}

target "stashapp" {
  inherits = ["_common"]
  target = "stashapp"
  tags = ["ghcr.io/${OWNER_NAME}/stash-pr:${TARGET_BRANCH}"]
}

target "nerethos" {
  inherits = ["_common"]
  target = "nerethos"
  tags = ["ghcr.io/${OWNER_NAME}/stash-pr:nerethos-${TARGET_BRANCH}"]
}