# AWS CLI MFA Automation for WSLv2
> This project started due to limitations of 1Password with WSL AWS CLI when requiring MFA.  

Currently directly calling 1Password Secret References in WSL AWS CLI does not work.  This is a workaround to use a powershell script to temporarily store the secret reference and pass that into a variable that is accessible from WSL Bash. 

Readme is not finished.  
- Need to add code examples
- Screenshots
- Test setting Windows env variables between wsl and AWS CLI
  
```sh
edit autoexec.bat
```

## Usage example

Using with AWS CLI to call MFA code into Get-Session-Token

_For more examples and usage, please refer to the [Wiki][wiki]._



## Release History

* 0.0.1
    * Work in progress


## Contributing

1. Fork it (<https://github.com/yourname/yourproject/fork>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request

