# COM754
This project has the following hard dependencies:
 - Python 3.13
 - a Microsoft Azure account for the Azure Communication and Cognition services
 - enough credits or money to run those said services
 - the project's own dependencies in `requirements.txt`

Other soft dependencies may have to be adapted depending on the OS on which this project is ran:
 - Azure CLI or Powershell 5 to obtain the different tokens
 - Azure devtunnel

Starting the project requires following those steps:
0) Reproducing the project's Azure infrastructure or importing it from the `azure.json`
1) Obtaining the dataset (from us, by emailing us)
2) Authenticating with Azure
3) Running the devtunnel 
4) Launching the detection system
5) Launching the caller-callee system

# Authentication with azure
```
Connect-AzAccount
```