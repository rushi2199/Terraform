provider "aws" {
    region = "ap-south-1"
    access_key = "Your Acess Key"
    secret_key = "Your Secret Key"
    
}

resource "aws_instance" "my-tera-instance" {
  
  ami = "ami-067c21fb1979f0b27"
  instance_type = "t2.micro"
  tags = {
    Name="My-tera-serv"
  }
  

}
