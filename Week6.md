# Week 6 - EC2 Hardening

## What I Did

Shifted from app development to backend development / security this week. Started an EC2 instance running Ubuntu 26.04 Resolute. Spent three sessions getting it from a fresh server into a hardened baseline before any backend code gets deployed to it.

### Session 1 - Initial Server Hardening

- Connected to the EC2 via SSH for the first time using key-based authentication (no password)
- Ran system updates via apt to verify patching baseline
- Audited open network ports with `ss -tlnp` (only SSH on 22 exposed to the internet, DNS on localhost only)
- Reviewed all user accounts in /etc/passwd, confirmed only root and ubuntu have login shells
- Verified the ubuntu account password is locked (key-only authentication enforced)
- Read through sshd_config and the AWS cloud image override snippet
- Made my first hardening edit: disabled X11Forwarding in sshd_config since this is a headless server
- Reloaded systemd and restarted SSH to apply changes
- Verified the change took effect with `sshd -T`

### Session 2 - Firewall and Intrusion Prevention

- Configured UFW with default deny incoming, allow outgoing
- Added rules for SSH (22), HTTP (80), and HTTPS (443) only -- nothing else exposed
- Enabled UFW logging at medium level so blocked connections get recorded
- Verified rsyslog is running and capturing auth.log, syslog, kern.log, and others
- Installed Fail2Ban to automatically ban IPs after repeated failed SSH attempts
- Confirmed the default sshd jail is active and watching
- Verified unattended-upgrades configured to apply security patches automatically (AWS sets this up by default)

### Session 3 - Service Account and SSH Port Change Attempt

- Created a dedicated bristle system user with no home directory and no login shell, per Principle of Least Privilege
- Created a matching bristle group
- Set up /opt/bristle directory owned by bristle:bristle with 750 permissions
- Attempted to move SSH off port 22 to a non-standard port
- Configured UFW and sshd_config for the new port correctly, but the connection timed out from outside
- Discovered the AWS security group is a separate firewall layer that also needs the port opened
- Reverted the SSH change to avoid lockout risk and emailed to request the port be opened on the AWS side

## Why I Did It This Way

**Hardening before deployment** -- the goal was to get the server into a defensible baseline state before putting any application code on it. Deploying a backend onto an unhardened server and then trying to retrofit security is harder and riskier than doing it the other way around.

**Two layers of firewall** -- UFW at the OS level on top of AWS security groups at the network level. Defense in depth. If one layer is misconfigured or has a bug, the other still provides protection. The port change attempt revealed how this works in practice -- AWS blocked the new port even though UFW had it open.

**Default deny posture on UFW** -- everything blocked unless explicitly allowed. Unit 5 slides emphasized this approach ("if you won't use it, turn the service off") and it's the industry standard for server firewalls. The alternative -- default allow with specific blocks -- means you have to anticipate every possible attack vector, which doesn't scale.

**Fail2Ban over manual log review** -- watching auth.log by hand isn't realistic for a production-bound server. Fail2Ban provides automated response to brute force attempts, which is the most common form of attack against public-facing SSH.

**Dedicated service account for Bristle** -- if the backend ever gets compromised, the attacker is contained inside an account with no sudo, no home directory, no login shell, and access only to /opt/bristle. The blast radius of a compromised backend is smaller than if it ran as the ubuntu user.

**Verified before changing, tested before committing** -- the SSH port change session was a good lesson in this. I added the new port to UFW before changing sshd_config, kept the existing session alive while testing from a second terminal, and was ready to revert if anything went wrong.

## Connection to Learning Objectives

**Unit 2 - Security on the OS** -- most app work this week ties to this unit. Principle of Least Privilege (the bristle service account), secure configuration (SSH hardening), centralized management (UFW rules, Fail2Ban configuration).

**Unit 3 - Logging and Auditing** -- verified rsyslog operation, configured UFW logging, examined auth.log to understand what gets recorded and read my own session as a sanity check.

**Unit 4 - Tools** -- patch management is part of this unit, and the unattended-upgrades verification connects directly.


## What I Learned

The biggest realization this week was how security can depend on many small decisions. There wasn't a single dramatic hardening moment. It was a long series of small choices, close this port, lock that account, restrict these permissions, log this thing, automate that patch. Each one adds a small amount of friction for an attacker. Adding them together creates defense in depth to make things harder for attackers.

The SSH port change attempt was the most valuable failure I've had on the course so far. I learned three things from it: cloud servers have multiple firewall layers, my mental model of "firewall = UFW" was incomplete, and asking for help can be part of the process. 