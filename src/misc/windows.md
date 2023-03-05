# Windows cheatsheet

## Prompt
`mode` List all COM ports


## Commands

`eventvwr.msc` Event viewer.

`ncpa.cpl` Network settings.

`appwiz.cpl` Install/Uninstall software.

`netplwiz` Config to allow login without password

`sysdm.cpl` System properties; Env vars; Enable remote desktop access

`GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}` Create a folder with this name shows lots of settings.

`Intl.cpl` Regional settings dialog.


## Keyboard Shortcuts

`Windows + r` Run

`Alt + d` in Windows Explorer and then `cmd` to open the command prompt in that folder.

`Windows + Alt + g` Xbox game bar that allows you to record the screen among other things.

# List USBs
```powershell
Get-PnpDevice -PresentOnly | Where-Object {$_. InstanceId -match '^USB'}
```

# Add stuff to PATH for a particular session
I needed to run QEMU for a project, but did not want to change my `%PATH%` variable adding the QEMU instalation path just for a temporary thing.

My solution was to create a `qemu-cli.bat` that launches a prompt with `%PATH%`:

```batch
cmd /K set PATH=%PATH%;"C:\Program Files\qemu"
```




# Windows 10 Cleanup
Do this after a fresh windows installation
## Free more disk space avoiding hibernation:
Open cmd as administrator;
```batch
powercfg -h off
```

## Uninstall bloatware
PowerShell as administrator:
```powershell
Get-AppxPackage -AllUsers | Remove-AppxPackage
```

Put back the Microsoft store:
```powershell
Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
```

Now it is a good time to install the camera and calculator apps back (from MS store).
As image viewer you can use [FastStone](https://www.faststone.org)

## Configuring updates
Open Group Policy Editor (`gpedit.msc`):
- Computer Configuration -> Administrative Templates -> Windows Components -> Windows Update -> Configure Automatic Updates -> 2 - Notify for download and notify for install.
- Computer Configuration -> Administrative Templates -> Windows Components -> Windows Update -> Turn on Software Notifications -> Enabled.
- Computer Configuration -> Administrative Templates -> Windows Components -> Windows Update -> Allow Automatic Updates immediate installation -> Disabled.
- Computer Configuration -> Administrative Templates -> Windows Components -> Windows Update -> Turn on recommended updates via Automatic Updates -> Enabled.
- Computer Configuration -> Administrative Templates -> Windows Components -> Application compatibility -> Turn off application telemetry.
- Computer Configuration -> Administrative Templates -> Windows Components -> Data collection and preview builds -> Allow telemetry - 0 (security).

## Sources
Special thanks to Dr. Rodrigo Cadore and Dr. Ramon Fernandes for those tips.
