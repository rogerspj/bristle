# Week 7 - SSH Port Change, MFA Key, and Deeper EC2 Hardening

## What I Did

Continued building out the EC2 hardening from Week 6. Bigger focus this week on SSH itself, since SSH is the most exposed service on the server and the highest-leverage thing to harden well.

### SSH Port Change

Last week I tried to move SSH off the default port 22 to a custom port and ran into the AWS security group issue. This week:

- Picked a non-standard port 
- Sent an email asking to open the port in the AWS security group
- Re-applied the change on the server side: UFW updated, sshd_config edited, SSH service restarted
- Verified the new port worked from a second terminal before closing port 22
- Removed port 22 from UFW once the new port was confirmed working
- Asked to close port 22 on the AWS security group to complete the defense-in-depth
- Tried to SSH into port 22, request timed out, confirming it is closed

### MFA on the SSH Key

When we generated my SSH key originally, I skipped the passphrase to keep things simple. Added a passphrase to the existing key using `ssh-keygen -p`. Now SSH authentication uses both the private key file (something I have) and the passphrase (something I know) for MFA.

### Deeper SSH Config Hardening

Installed Lynis and ran a baseline security audit. Initial score was 67. The audit surfaced 7 separate SSH config improvements:

- `AllowTcpForwarding no` -- SSH can be used as a tunnel for arbitrary TCP traffic. Disabling means terminal-only access.
- `AllowAgentForwarding no` -- prevents forwarded SSH agent abuse if the server were compromised.
- `ClientAliveCountMax 2` -- kills dead sessions faster.
- `MaxAuthTries 3` -- attackers get 3 attempts per connection instead of 6.
- `MaxSessions 2` -- caps concurrent sessions per connection.
- `LogLevel VERBOSE` -- more detailed auth logging.
- `TCPKeepAlive no` -- forces reliance on SSH-level keepalives which can't be spoofed.

All applied in a single sshd_config edit and SSH service restart.

### Login Banners

Added a legal warning banner to both /etc/issue and /etc/issue.net. Configured SSH to display the banner before authentication. Under CFAA, prosecuting unauthorized access is much easier when you can prove the attacker was warned. The banner is that warning.

### Fail2Ban jail.local

Quick 30-second fix. Copied /etc/fail2ban/jail.conf to jail.local so any future Fail2Ban customizations survive package updates. Standard Linux configuration management pattern.

### Auditd Setup

Installed auditd and configured 10 audit rules monitoring sensitive files and commands:

- /etc/passwd, /etc/group, /etc/shadow, /etc/gshadow (user account changes)
- /etc/sudoers and /etc/sudoers.d/ (sudo config tampering)
- /etc/ssh/sshd_config (SSH config tampering)
- /var/log/auth.log (log tampering attempts)
- /usr/bin/sudo (sudo usage tracking)
- /etc/ufw/ (firewall rule changes)

Verified auditd actually logs by running `sudo touch /etc/ssh/sshd_config` and pulling the event with `ausearch -k ssh_changes`. Saw a complete forensic record: timestamp, who, what command, working directory, the whole picture.

### Lynis Score Progress

Ran Lynis three times across the session. Score went 67 → 73 → 74. Zero warnings throughout. About 30 suggestions remain, mostly things that either don't apply to a cloud VM (separate /var partition, GRUB password) or that make more sense once a real application is running.

## Why I Did It This Way

**SSH first, because SSH is the front door.** Everything else on the server is irrelevant if someone can SSH in. So moving the port, hardening the config, and adding a key passphrase were all higher priority than chasing every Lynis suggestion.

**MFA on the key was a real gap.** I had been treating the private key file alone as sufficient authentication. Including a passphrase encrypts the key file itself so theft of the file alone isn't enough.

**Lynis as a guide, not a goal.** Running a third-party audit tool prevents me from only fixing things I happened to think of myself. Lynis caught the 7 SSH settings, the missing banner, the jail.local pattern, and the auditd gap. I would not have known about most of those without it. That said, I deliberately didn't try to fix every single suggestion -- some don't apply to a cloud VM, others make more sense once there's an application running. The score is a useful tracking metric, not the goal.

**Auditd as forensic capability for the vulnerability scan.** If we open the projects up for student vulnerability scanning, I want to see exactly what the scanners did. Rsyslog alone shows me logins and failed auth attempts. Auditd shows me which specific files were touched at the system call level.

**SSH port change as obscurity layer, not primary defense.** The port change is less about security, more about noise reduction. Automated scanners that only check port 22 won't find my SSH. A determined attacker doing real recon will still find it. The value is in stripping out the dumb traffic from my logs so the meaningful events stand out. It only works as one layer among many, not as a standalone control.

## Connection to Learning Objectives

**Unit 2 - Security on the OS:** Most of this week's work falls here. SSH config hardening is secure configuration. The dedicated bristle service account from Week 6 was Principle of Least Privilege. Auditd rules implement centralized monitoring of privileged actions.

**Unit 3 - Logging and Auditing:** Auditd setup is the deeper version of this unit's content. Quiz feedback on integrity tools (AIDE limitations -- pre-modification blind spot, database as target) directly connects to auditd as a complementary realtime monitoring tool. Together they cover the gap each has alone.

**Unit 4 - Tools:** Lynis is an example of an enterprise tool this unit covered -- automated configuration assessment against a known baseline. 

**Unit 5 - Technical Protection:** SSH hardening is the practical application of "if you won't use it, turn the service off" applied to SSH features like X11 forwarding and agent forwarding.

## What I Learned

The biggest lesson this week was about defense in depth as a real layering exercise, not a buzzword. The SSH port change is a perfect example: by itself it's almost worthless, but when stacked on top of strong keys, key passphrases, Fail2Ban, UFW, AWS security groups, and auditd, the marginal value adds up. The lazy critique of security through obscurity treats it as if it's the only layer being used. 

Lynis was genuinely valuable as a guide. I caught things I would not have thought to harden on my own. The score progression also matters -- having a single number to track over time gives you a baseline that you can use to demonstrate progress and identify regressions. If the score drops after some future change, that's a signal something got loosened.

Also learned how to read auditd events properly. The format is dense and unfriendly, but everything you need is in there -- timestamp, user ID, command, working directory, the file that was touched, the audit key that fired. With practice it becomes more readable.