 ## Quick and Dirty example
 Quick and dirty example to create an Azure VM with a post-config script. 
 `azurerm_virtual_machine_extension` has awful documentation however [this blog post](https://techcommunity.microsoft.com/t5/itops-talk-blog/how-to-run-powershell-scripts-on-azure-vms-with-terraform/ba-p/3827573) shows how to template a powershell script. Not sure if b64 encode and then decode is needed. 


To run this you will need to update the provider.tf with your subscription ID.
You also ought to update the variables with a default value that makes sense or pass them in during `terraform plan` or set them in env with `TF_VAR` prefix. 