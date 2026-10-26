# NTP client configuration

All devices synchronise against the backbone time source **172.20.128.6**
(`ntp.wfl.lan`), which is itself a Chrony server disciplined from the public
`*.pool.ntp.org` pools.

## Ubuntu and Debian (Chrony)

```bash
sudo apt-get install -y chrony
```

Edit `/etc/chrony/chrony.conf`: comment out the existing `pool` lines and add

```
server 172.20.128.6 iburst
```

Apply and verify:

```bash
sudo systemctl restart chrony
chronyc tracking
chronyc sources -v
timedatectl
```

## Ubuntu (systemd-timesyncd, lightweight alternative)

Edit `/etc/systemd/timesyncd.conf`:

```
[Time]
NTP=172.20.128.6
```

Apply and verify:

```bash
sudo systemctl restart systemd-timesyncd
sudo timedatectl set-ntp true
timedatectl show-timesync
timedatectl status
```

## Windows 10, 11 and Server

In an administrator PowerShell:

```powershell
w32tm /config /manualpeerlist:"172.20.128.6" /syncfromflags:manual /reliable:YES /update
net stop w32tm
net start w32tm
w32tm /resync /force
```

Verify:

```powershell
w32tm /query /status
w32tm /query /peers
```

## Cisco IOS (router or switch)

In global configuration mode:

```
ntp server 172.20.128.6
ntp update-calendar
clock timezone CET 1
clock summer-time CEST recurring last Sun Mar 2:00 last Sun Oct 3:00
service timestamps log datetime msec localtime
service timestamps debug datetime msec localtime
```

Verify (privileged mode):

```
show ntp status
show ntp associations
show clock detail
```

## Command notes

| Command | Purpose |
|---|---|
| `ntp server 172.20.128.6` | Use the backbone as the time source |
| `ntp update-calendar` | Sync the hardware RTC from NTP |
| `clock timezone CET 1` | Central European Time, UTC+1 |
| `clock summer-time CEST recurring ...` | Automatic DST to UTC+2 (EU rules) |
| `service timestamps log datetime msec localtime` | Local timestamped logs with milliseconds |
| `server 172.20.128.6 iburst` (Chrony) | `iburst` sends a fast initial burst for quick sync |
