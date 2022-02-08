variable "ciao" {
  type = object({
    name = string
    color = string
    age = number
    food = list(string)
    athlete = bool
  })
}