# AWS CLI MFA Automation for WSLv2 with 1Password CLI
> This project started due to limitations of 1Password, WSL, and AWS CLI when requiring AWS CLI MFA authetication. Currently 1Password CLI in WSL does not work with plugins due to WSL not having access to the Windows Hello Authentication that is required for plugins in the 1Password App.  This script improves security of AWS CLI in WSL by using external MFA that is kept secret durring authetication, avoids permanently storing 1Password secrets and MFA codes in env variables. 

# Highlights
- calls PowerShell from WSL to temporarily store the OTP MFA code in a variable.
- Using PowerShell from WSL by passes the limitation and correctly prompts for a windows hello authetication to access the Secret Reference.
- The PS Session is transient. It exits automatically when called by script and ensures no secrets are stored permanently in env variables.
- stores 1pw MFA code in a Bash accessible variable that can be inserted into AWS CLI commands.  
- calls get-session token to retreive temporary credentials for aws cli sessions
- stores the temporary AWS Session credentials in the AWS CLI credentials profile for AWS CLI to use.
- Requires MFA (mine uses biometrics so there is no way someone could run this without my finger)

# Requirements and First Steps
- Windows Hello Authentication needs to be configured in Windows.
- You must have 1Password desktop application and 1Password CLI installed, configured, and signed-in in your Windows desktop.
   - 1Password Developer Setting
      - "Integrate with 1Password CLI" must be enabled in the desktop app.
   - 1Password Security Setting
      - "Unlock using Windows Hello" enabled
      - "Show Windows Hello prompt automatically" enabled 
- WSL installed and configured.
- AWS CLI intalled and configured in WSL Ubuntu with default Access and Secret Keys in your AWS CLI to initiate the script.
- In your AWS account your users need to have the mfa required permission applied in IAM.


## Resources
1. Microsoft Documentation
   - Windows Hello Setup - https://support.microsoft.com/en-us/windows/learn-about-windows-hello-and-set-it-up-dae28983-8242-bb2a-d3d1-87c9d265a5f0
   - Install WSL - https://learn.microsoft.com/en-us/windows/wsl/install
   - on PowerShell variables - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables?view=powershell-7.4
   - Calling applications from WSL - https://learn.microsoft.com/en-us/windows/wsl/filesystems

2. 1Password Documentation
   - Download 1Password for Windows - https://1password.com/downloads/windows/?msclkid=cf0ab159737f1e5556d6d4f0d9b267ee
   - Setup 1Password CLI in Windows - https://developer.1password.com/docs/cli/get-started
   - Secret references - https://developer.1password.com/docs/cli/secret-references/
  

3. AWS CLI to install in WSL
   - Install - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions
   - AWS CLI configuration - https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html
   - Helpful article for information on the original script.  https://www.packetmischief.ca/2023/02/26/how-i-use-mfa-with-the-aws-cli/


Adding next: 

- I want to pass the the AWS Access and Secret keys from 1Password to the script so it doesn't require a preconfigured permanent AWS credential file and only stores the temporary keys & token.  
