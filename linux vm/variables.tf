/*variable "vm" {
  type = map(object({
    vmname=string
  }))
  #default = [ "myvm1","myvm2","myvm3" ]
  default={
  "vm1"={
    vmname="myvm1"
  }
  "vm2"={
    vmname="myvm2"
  }
  "vm3"={
    vmname="myvm3"
  }
}
}
  type= map(object({
    name=string
  }))
  
default={
  "vm1"={
    name="myvm1"
  }
  "vm2"={
    name="myvm2"
  }
  "vm3"={
    name="myvm3"
  }
  

}
*/
variable "subnetname" {
  type = map(object({
    subnetname=string
    vmname=string
    address_prefixes=list(string)

  }))
  default = { 
    "subnet1"={
  subnetname="subnet1"
  vmname="myvm1"
  address_prefixes=["10.0.1.0/24"]
  }
   "subnet2"={
  subnetname="subnet2"
  vmname="myvm2"
  address_prefixes=["10.0.2.0/24"]
  }
   "subnet3"={
  subnetname="subnet3"
  vmname="myvm3"
  address_prefixes=["10.0.3.0/24"]
  }
  }
  
}

/*
variable "address_prefixes" {
  type = map(object({
    address_prefixes=list(string)
  }))
  default = {
    "ap1" = {
      address_prefixes=["10.0.1.0/24"]
    }
    "ap2" = {

      address_prefixes=["10.0.2.0/24"]
    }
    "ap3" = {
      address_prefixes=["10.0.3.0/24"]
    }
  }
  type = list(string)
  default = [ "10.0.1.0/24","10.0.2.0/24","10.0.3.0/24" ]
  
  
  */
  
