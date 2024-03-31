variable key_policy {
  description = "Informações da policy"
  type = list(object({
    sid           = optional(string)
    effect        = string
    actions       = list(string)
    resources     = list(string)
    principals  = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    conditions = optional(list(object({
      test = optional(string),
      variable = string,
      values = list(string)
    })))
  }))
  default = []
}

