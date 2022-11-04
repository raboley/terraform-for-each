variable "list_of_strings" {
  default = ["1", "hello", "world", "strings"]
}

####### list_of_strings_to_map_for 
locals {
  simple_to_map = {
    for key, value in var.list_of_strings : key => value
  }
}

output "simple_to_map_to_map" {
  value = local.simple_to_map
}

# Here using a map will work with a for each directly
# The key of the map will be used for the alias of the resource
# (in this example that is the index of the array (not very good so be mindful when creating the map))
resource "null_resource" "simple_to_map" {
  for_each = local.simple_to_map

  triggers = {
    key   = each.key
    value = each.value
  }
}

output "null_resource_simple_to_map" {
  value = null_resource.simple_to_map
}

#### list_of_strings_for
locals {
  simple_to_list = [
    for key, value in var.list_of_strings : value
  ]
}

output "simple_to_list_to_list_of_string" {
  value = local.simple_to_list
}

# Have to change this to a set to be valid, cannot use a list
# When using toset both the key and value of the for each become the value of the list.
resource "null_resource" "simple_to_list" {
  for_each = toset(local.simple_to_list)
  triggers = {
    key   = each.key
    value = each.value
  }
}

output "null_resource_simple_to_list" {
  value = null_resource.simple_to_list
}

###### List of Objects

variable "list_of_objects" {
  default = [
    { name = "first", id = 1, color = "blue" },
    { name = "second", id = 2, color = "green" },
    { name = "third", id = 3, color = "red" },
  ]

}

locals {
  # Here we can see we create a map of objects using the object's property of name as the key, 
  # and then the object itself (including name) as the value of the map.
  objects_to_map = {
    for key, value in var.list_of_objects : value.name => value
  }
}

output "objects_to_map_to_map" {
  value = local.objects_to_map
}

resource "null_resource" "objects_to_map" {
  for_each = local.objects_to_map

  triggers = {
    key   = each.key
    
    name = each.value.name
    id = each.value.id
    color = each.value.color
  }
}

output "null_resource_objects_to_map" {
  value = null_resource.objects_to_map
}

###### Customize List of Objects

variable "custom_list_of_objects" {
  default = [
    { name = "first", id = 1, color = "blue" },
    { name = "second", id = 2, color = "green" },
    { name = "third", id = 3, color = "red" },
  ]

}

locals {
  # Here we can see we create a map of objects using the object's property of name as the key, 
  # and then the object itself (including name) as the value of the map.
  customize_objects_to_map = {
    for key, value in var.custom_list_of_objects : value.name => {
      # using the {} we can construct an object as the output for this map's value. 
      # We can put whatever we want/have access to in the scope (including outer scopes like variables, etc.)
      name = value.name
      id = value.id
      color = value.color

      # Adding a new property to the object which is the index in the array this item was. 
      # The key is index because we started with a list, so key = index, value = value of item at that index.
      index = key
    }
  }
}

output "customize_objects_to_map" {
  value = local.customize_objects_to_map
}

resource "null_resource" "customize_objects_to_map" {
  for_each = local.customize_objects_to_map

  triggers = {
    key   = each.key
    
    name = each.value.name
    id = each.value.id
    color = each.value.color
    index = each.value.index
  }
}

output "null_resource_customize_objects_to_map" {
  value = null_resource.customize_objects_to_map
}

###### How to Handle a list of objects with nested lists of objects

# Here we have a list of restaurant objects that each have a menu object
variable "nested_objects_to_map" {
  default = [
    { name = "Italian Pies Inc", foods = [
      {name = "pizza", price = 26 },
      {name = "pasta", price = 15 },
      ]},
    { name = "Big Bite Burgers", foods = [
      {name = "mondo burger", price = 14 },
      {name = "min burger", price = 8 },
      {name = "french fries", price = 4 },
    ]},
    { name = "Super Foods Health Blast", foods = [
      {name = "green drink", price = 9 },
      {name = "banana blast smoothie", price = 12 },
      {name = "shot of grass", price = 3 },
    ]},
  ]
}

locals {
  
  # lets say we wanted to create a resource for each restaurant with a dynamic resource in it for each menu item
  # Using a for loop to create lists and then flattening them we can then use them in a for each loop
  nested_objects_to_map_for_object = {
    for key, value in var.nested_objects_to_map : value.name => {
      value = value
      foods = { for index, food in value.foods: food.name => food }
    }
  }
}

output "nested_objects_to_map_for_object" {
  value = local.nested_objects_to_map_for_object
}

resource "null_resource" "nested_objects_to_map_for_object" {
  for_each = local.nested_objects_to_map_for_object

  # This is kinda hacky, but couldn't find an object that you could do dynamic blocks against without actually creating something
  # :thinking: 
  triggers = {for name, food in each.value.foods: food.name => food.price }
}

output "null_resource_nested_objects_to_map_for_object" {
  value = null_resource.nested_objects_to_map_for_object
}

###### How to Handle a list of objects with nested lists of objects and filter them.