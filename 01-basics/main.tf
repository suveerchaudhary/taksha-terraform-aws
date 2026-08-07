# This is dry run test to see if Terraform is working. No real infrastructure is created.
terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "~>3.6"
    }
  }
}

resource "random_pet" "example" {
    length = 2
}

output "pet_name" {
  value = random_pet.example.id
}
