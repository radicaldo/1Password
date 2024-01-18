# AWS CLI MFA Automation for WSLv2 with 1Password CLI
> This project started due to limitations of 1Password, WSL, and AWS CLI when requiring MFA. Currently 1Password CLI in WSL does not work with plugins due to WSL not having access to Windows Hello Authentication that is required for plugins in the 1Password App.  This script avoids storing 1Password secrets in env variables and automates the process in the same way. 

# Highlight details
- calls PowerShell from WSL to temporarily store the OTP MFA code in a variable.
- Using PowerShell from WSL by passes the limitation and correctly prompts for a windows hello authetication to access the Secret Reference.
- The PS Session is transient. It exits automatically when called by script and ensures no secrets are stored permanently in env variables.
- stores 1pw MFA code in a Bash accessible variable that can be inserted into AWS CLI commands.  
- calls get-session token to retreive temporary credentials for aws cli sessions
- stores the temporary AWS Session credentials in the AWS CLI credentials profile for AWS CLI to use.


## Resources
1. Microsoft Documentation

   a) on PowerShell variables - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables?view=powershell-7.4
 
   b) Calling applications from WSL - https://learn.microsoft.com/en-us/windows/wsl/filesystems

2. 1Password Documentation on Secret references - https://developer.1password.com/docs/cli/secret-references/
 
