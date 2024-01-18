# AWS CLI MFA Automation for WSLv2
> This project started due to limitations of 1Password, WSL, and AWS CLI when requiring MFA. Currently 1Password CLI does not work with WSL and the 1Password App.  This also avoids storing 1Password secrets in env variables. You can configure 1Passoword with MFA to work with Windows Hello Pin or biometrics.  

# Highlight details
- calls PowerShell from WSL to temporarily store the OTP MFA code in a variable.
  - This PS Session is transient and exits automatically to ensure that no secrets are stored permanently in env variables.
- stores 1pw MFA code in a Bash accessible variable that can be inserted into AWS CLI commands.  
- calls get-session token to retreive temporary credentials for aws cli sessions
- stores the temporary AWS Session credentials in a credentials profile for AWS CLI to use.


## Resources
1. Microsoft Documentation:
   a) on PowerShell variables - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables?view=powershell-7.4
   b) Calling applications from WSL - https://learn.microsoft.com/en-us/windows/wsl/filesystems
2. 1Password Documentation on Secret references - https://developer.1password.com/docs/cli/secret-references/
 
