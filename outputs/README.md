Outputs Chaining

- Chaining outputs from a submodule -

Create a submodule and list a possible output. 

output "public_ip" {
  value = aws_instance.outputs_public.public_ip
}

Then in the parent main.tf we can call on that output with:

output "public_ip" {
  value = module.aws_server.public_ip
}