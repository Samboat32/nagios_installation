# nagios_install

These are series of scripts to be used for Nagios installation on the Server and Host  

Setting up and Monitoring the Linux Server in Nagios

Introduction
Today we will set up and monitor the Linux server in Nagios. First of all, Nagios is for monitoring devices running Linux, Windows, and Unix OSes and alerts you when the service is stopped or crashes. The Nagios installation process will be manual, installation of Nagios can take a minimum of 16 to 20 steps after installation we have to Monitor the Remote Linux Host Machine using Nagios Remote Plugin Executor (NRPE) addon we do this with the help of AWS EC2 and Linux commands.

completion steps
For installing Nagios

Step 1 — Launch 2 Ubuntu based Instances.

Step 2 — Update and Install prerequisite tools.

Step 3 — Move index.php in first position and restart Apache service.

Step 4 — Download, extract, Compile and Install Nagios Core source.

Step 5 — Create User And Group.

Step 6 — Install Binaries, Service / Daemon, Command Mode, Configuration Files, Apache Config File

Step 7 — Configure Nagios.

Step 8 — Configure Nagios Contacts.

Step 9 — Configure check_nrpe Command.

Step 10 — Configure Apache.

Step 11 — Configure Firewall.

Step 12 — Configure a nagios service.

Step 13 — Create nagiosadmin User password.

Step 14 — Restart Apache and start Nagios services.

Step 15 — Install Nagios Plugin.

Step 16 — Download, Extract, Compile and Install the Plugins package

Step 17 — Opening Nagios Server website.

After the installation of Nagios we have to

Step 18— Fixing Swap usage error.

Step 19— Check and change the permission for the file

Step 20— Make this file as a swap file using mkswap command

Step 21 — Enable the newly created swapfile

Step 22— Re-schedule the service to update changes.

Monitor Remote Linux Host Machine using NRPE addon

Step 23— Download, extract and Install NRPE Script in Remote Linux Host Machine.

Step 24— Add Host to Nagios Configuration in Nagios Server

Step 25— Monitor the newly added host in the Nagios Website

Step 26— Install Apache2 Web Server in Remote LinuxHost machine

Step 27— Deploy our custom webpage in the Apache Web Server

Step 28 — Add HTTP service to nagihost.cfg file in Nagios Server

Step 29— Monitor the HTTP service in the Nagios Website

Step 30— deletion
