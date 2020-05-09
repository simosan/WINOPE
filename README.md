# NAME

WINOPE.py - Windows automation tool


## Overview

A python script inspired by Infrastracutre as code, a push-type configuration management tool.
This tool executes Windows commands and PowershellDSC defined in yaml by specifying a configuration file (yaml file) as the argument of this tool.

## Prerequisite

This tool has been tested on Windows10 or 2016+ where python is installed.
Execute remote commands and PowershellDSC on WinRM enabled Windows servers. It is also possible to execute commands on the Windows OS from which they are executed.

* python 3.7+
* python library(pyyaml)

## Usage

    $ python WINOPE.py xxxx.yaml


xxxx is optional.


## How to Write a YAML File (Configuration Definition)

Summary of Description

The case of the operation key "remotehost"

```
    TargetCon1:
      ConnParm:
      - hostname: XXX.XXX.XXX.XXX
      - userid: Administrator
      - passwd: \_${XXXXXPASSWD}
      Operation:
      - remoteope: cmd /c net user Administrator \_${YYYYYPASSWD}
      - remoteope: Powershell -c '$i6 = Get-NetAdapterBinding | Where-Object {$_.ComponentID -eq ''ms_tcpip6''};
                                  foreach($List in $i6){
                                    Disable-NetAdapterBinding -Name $List.Name -ComponentID ms_tcpip6}'
```      
---
- hostname: hostname or IP  You can specify more than one by comma.
- userid: User ID to connect to.
- passwd: Hardcodes are not acceptable. The format should be _${XXXXPASSWD}.
- remoteope: OS command
---

The case of the operation key "PowershellDSC"

```
TargetCon1:
  ConnParm:
  - hostname: XXX.XXX.XXX.XXX 
  - userid: Administrator
  - passwd: \_${XXXXXPASSWD}
  Operation:
  - psdscope: \_${DSCDIRECTORY}\Add_IIS
```      

---
- hostname: hostname or IP. In the case of PowershellDSC, only one host is specified. The reason is described later in Note. 
- userid: User ID to connect to.
- passwd: Hardcodes are not acceptable. The format should be _${XXXXPASSWD}.
- psdscope: Specifies the folder(ex Add_IIS) where the PowershellDSC Configuration files are stored. 
---

The case of the operation key "localope"

```
TargetCon1:
  ConnParm:
  - hostname: localhost
  Operation:
  - localope: 'powershell -c "
               for(;;){ 
                  $result=Test-Connection _${SIM2016AWSIP} -Count 1 -quiet;
                  if($result -eq ''True''){ 
                     Write-Host \_${SIM2016AWSIP} ping ok; break;
                  } 
                  Write-host \_${SIM2016AWSIP} It's not working.;Start-Sleep -Seconds 5
               }"'
```      

---
- hostname: You can specify localhost. 
- localope: OS command 
---

## Note

1) This AP execution source supports only Windows.

2) Each command described in Operation about the yaml to be read should use a command that can guarantee power-effectiveness. Override options and

3) The following operations are supported in YAML.
           localope     local Windows command execution
           remoteope    remote Windows command execution
           psdscope     running PowershellDSC

4) Environment variables (\_${XXX}) in yaml can be replaced with environment variables set to the OS. If you want to replace it, you need to set the OS environment variables in advance.
The yaml environment variable $\_{HOGE} should be set in advance like $env:HOGE="AAA" in powershell or set HOGE="AAA" in DOS, so that you don't have to write passwd and so on.
XXX in \_${XXX} should be the letters in a-zA-Z0-9. Special characters and 2-byte characters are not allowed.

5) When inserting a password into the environment variable (\_${XXX}) in yaml, be sure to use the format $\_{~PASSWD}.
If this format is not followed, the password will be displayed (not masked) in the standard output of the runtime command.

6) The error handling of YAML's XXOPE is seen in the standard error output. If you want to stop the process in the middle, output the standard error.
Note that I have not seen the return code.
If you want to continue the process, put ERREXCEPTLIST.conf on the same level as WINOPE.py and run
If you define the error output message (partial matching is possible) inline, the process will not fall down in the middle.

7) Multiple hosts can be specified in hostname of yaml. Separate them with commas. However, psdscope (PowershellDSC) is not applicable.

8) Follow the following rules when you use the Configuration file of PowershellDSC in this AP.

a) Node specifies $env:TARGETHOSTNAME (environment variable of Powershell).

b) Define it at the bottom of the configuration file as follows

$md = $env:DSCDIRECTORY + "\Add_IIS"
New-Item $md -ItemType Directory -Force
Add_IIS -outputpath $md;

→By this definition, the folder specified by yaml is automatically generated and mof is also generated.

9) The method of specifying ConParm is different for each operation.
         localope    Only hostname. You can specify localhost and so on.
         remoteope   hostname(required,more than one can be specified),userid(arbitrary),passwd(arbitrary).If userid and passwd are omitted, it will be executed with the authority of the source account.
         psdscope    hostname(required,only one host),userid(optional),passwd(optional).If you omit userid and passwd, it will be executed in LocalSystem.

10) When obtaining the initial EC2 password, the format of the passwd parameter should be "EC2INITPASSWD|\_${each hostname environment variable}".
Automatically retrieve passwords from the AWS console and output them to a temporary file. The process of reading the file.
The point is that you want to read _${WORKDIR}}\_${hostname environment variable}_tmpps.txt.

11) If you use PowershellDSC, the node name specified in the resource file (ps1 for generating mof) and the hostname specified in yaml must be the same.
If one of them is a host name and one of them is an IP address, the process ends abnormally.

12) When you operate PowershelDSC from this tool, the Node specified in the resource file of PowershellDSC should be "$env:TARGETHOSTNAME" according to the specification of this tool. Assign the value of hostname to "TARGETHOSTNAME".

13) If you use PowershellDSC (psdscope), the hostname of yaml should be limited to one host for the reason of No11.

14) In order to be able to get the initial EC2 password automatically from AWS console, the temporary password obtained will be temporarily saved in WORKDIR. Define passwd as "EC2INITPASSWD|\_${target hostname variable}" to use that password to log in and change it to an arbitrary password.

## Licence

SSHOPE.py is under [MIT license](https://en.wikipedia.org/wiki/MIT_License).


