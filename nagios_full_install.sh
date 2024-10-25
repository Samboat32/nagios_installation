#!/bin/bash

# Note: Replace <your-server-ip> (step 17) and <nagios-host-ip> (step 24) with the actual IP addresses of your Nagios server and remote host.

# ON THE NAGIOS SERVER

# Step1
# Open Ports 8080, 8081 and 2377 for TCP
# ref: https://medium.com/@princeashok069/nagios-practical-028bd64c5c88
# Steps 2 to 16. Be sure to run the rest of the commands manually after this
# The steps from 17 onward typically involve post-installation tasks, such as fixing specific issues, adding hosts, and setting up monitoring for remote machines, which might be seen as extensions rather than core parts of the installation.


# Step 2: Update and Install Prerequisite Tools
sudo apt update && sudo apt upgrade -y
sudo apt install autoconf gcc libc6 make wget unzip apache2 apache2-utils php libgd-dev libmcrypt-dev libssl-dev bc gawk dc build-essential snmp libnet-snmp-perl gettext
sudo apt-get install -y openssl libssl-dev

# Step 3: Move index.php to the First Position and Restart Apache
sudo sed -i 's/DirectoryIndex.*/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf
sudo systemctl restart apache2

# Step 4: Download, Extract, Compile and Install Nagios Core Source
cd /opt
sudo wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.14.tar.gz
sudo tar xzf nagioscore.tar.gz
cd nagioscore-nagios-4.4.14/
sudo ./configure --with-httpd-conf=/etc/apache2/sites-enabled
sudo make all

# Step 5: Create User and Group
sudo make install-groups-users
sudo usermod -a -G nagios www-data

# Step 6: Install Binaries, Service/Daemon, Command Mode, Config Files, Apache Config File
sudo make install
sudo make install-daemoninit
sudo make install-commandmode
sudo make install-config
sudo make install-webconf

# Step 7: Configure Nagios
sudo sed -i '/^#cfg_dir=\/usr\/local\/nagios\/etc\/servers/s/^#//' /usr/local/nagios/etc/nagios.cfg
sudo mkdir /usr/local/nagios/etc/servers

# Step 8: Configure Nagios Contacts
sudo sed -i 's/nagios@localhost/your-email@example.com/' /usr/local/nagios/etc/objects/contacts.cfg

# Step 9: Configure check_nrpe Command
sudo bash -c 'cat >> /usr/local/nagios/etc/objects/commands.cfg <<EOL
define command{
    command_name check_nrpe
    command_line \$USER1\$/check_nrpe -H \$HOSTADDRESS\$ -c \$ARG1\$
}
EOL'

# Step 10: Configure Apache
sudo a2enmod rewrite
sudo a2enmod cgi
sudo systemctl restart apache2

# Step 11: Configure Firewall
sudo ufw allow Apache
sudo ufw enable
sudo ufw reload

# Step 12: Configure Nagios Service
sudo bash -c 'cat > /etc/systemd/system/nagios.service <<EOL
[Unit]
Description=Nagios
BindTo=network.target

[Service]
Type=simple
User=nagios
Group=nagios
ExecStart=/usr/local/nagios/bin/nagios -d /usr/local/nagios/etc/nagios.cfg
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL'
sudo systemctl enable nagios
sudo systemctl start nagios

# Step 13: Create nagiosadmin User Password
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

# Step 14: Restart Apache and Start Nagios Services
sudo systemctl restart apache2.service
sudo systemctl start nagios.service

# Step 15: Install Nagios Plugin
sudo apt-get install -y autoconf gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext

# Step 16: Download, Extract, Compile and Install the Plugins Package
cd /opt
sudo wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.4.6.tar.gz
sudo tar xzf nagios-plugins.tar.gz
cd nagios-plugins-release-2.4.6/
sudo ./tools/setup
sudo ./configure
sudo make
sudo make install

echo "Nagios installation is complete. Open your web browser and navigate to http://<your-server-ip>/nagios"
echo "Use 'nagiosadmin' as the username and the password you set in Step 13."

#........................................................................................................

# Step 17: Open Nagios Server Website

#ref: https://medium.com/@princeashok069/nagios-practical-028bd64c5c88
# ON THE NAGIOS SERVER

# 1. To open the Nagios Server website we need to go back to the AWS EC2 instances page.
# 2. select the Nagios server and get the public IP address and copy it
# 3. paste the public IP address in the new tab and after the IP address give the tag as “/nagios”
# Note: <your-nagios-server-public-ip>/nagios 

# 4. Give the username and password we set
# 5. Go to the Hosts section and you will notice there will be a hosts “localhost” and its status will be up
# 6. Now go to the Service section and you will notice there will be an error for “Swap usage” with status critical
# 7. This error is because in the Nagios Server instance there is no swap partition.

#........................................................................................................

# Step 18, 19, 20, 21: Fixing Swap Usage Error (Optional)
sudo dd if=/dev/zero of=/root/myswapfile bs=1M count=1024
sudo chmod 600 /root/myswapfile
sudo mkswap /root/myswapfile
sudo swapon /root/myswapfile

#........................................................................................................

# Step 22: Reschedule the Service to Update Changes
# This is a manual step to be performed in the Nagios web interface.
# Now, go back to the Services section in Nagios website.
# Click on "Swap usage" service and click on “Re-schedule the next check” under the Service Commands menu and click "commit", then "Done"
# Monitor Remote Linux Host Machine using NRPE addon

#........................................................................................................

# Step 23: Download, Extract and Install NRPE Script in Remote Linux Host Machine
cd /opt
sudo wget http://assets.nagios.com/downloads/nagiosxi/agents/linux-nrpe-agent.tar.gz
sudo tar xzf linux-nrpe-agent.tar.gz
cd linux-nrpe-agent
sudo ./fullinstall

# Step 24: Add Host to Nagios Configuration in Nagios Server
sudo bash -c 'cat > /usr/local/nagios/etc/servers/nagihost.cfg <<EOL
define host {
    use                             linux-server
    host_name                       nagihost
    alias                           My first Apache server
    address                         <nagios-host-ip> 
    max_check_attempts              5
    check_period                    24x7
    notification_interval           30
    notification_period             24x7
}
EOL'
sudo systemctl restart nagios.service

#........................................................................................................

# Step 25 — Monitor the newly added host in the Nagios Website

# 1. Go to the Nagios Website, refresh and click on Hosts.
# 2. newly added host “nagihost” is added and the status is also up.
# 3. Click on it and monitor its services if there are any

#........................................................................................................

# Step 26: Install Apache2 Web Server in Remote Linux Host Machine
sudo apt-get install apache2 -y
sudo systemctl start apache2

# Step 27: Deploy Custom Webpage in Apache Web Server
cd /var/www/html
sudo rm index.html
sudo bash -c 'cat > index.html <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server 1 Card</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #F4F4F4;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .card {
            background-color: #FFFFFF;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            width: 300px;
            padding: 20px;
            text-align: center;
        }
        .card h2 {
            margin: 0 0 15px;
            color: #333333;
        }
        .card p {
            color: #777777;
            margin: 0 0 15px;
        }
        .card .status {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            background-color: #28A745;
            color: white;
            font-weight: bold;
        }
        .card .status.down {
            background-color: #DC3545;
        }
    </style>
</head>
<body>
    <div class="card">
        <h2>Hey there!</h2>
        <p>Welcome!</p>
        <p>This is a Test Webpage by Donatus</p>
        <p>Jomacs DevOps Trainee</p>
        <p class="status">Online</p>
    </div>
</body>
</html>
EOL'

# Step 28: Add HTTP Service to nagihost.cfg File in Nagios Server
sudo bash -c 'cat >> /usr/local/nagios/etc/servers/nagihost.cfg <<EOL
define service {
   use                      generic-service
   host_name                nagihost
   service_description      HTTP
   check_command            check_http
}
EOL'
sudo systemctl restart nagios.service

#........................................................................................................

# Step 29 — Monitor the HTTP service in the Nagios Website
# 1. Go to the Nagios Website and click on Services.
# 2. The HTTP service for “nagihost” is added and the status is OK.
# 3. if the status shows critical or pending we can click on that pending server
# 4. it takes us to server state information in that we can click on reschedule at servers commands
# 5. then we will get into command options there we have to click on commit
# 6. later click on done

#........................................................................................................

# Step 30: Deletion (Optional)
# You can terminate the Nagios and remote host instances if desired.

echo "Nagios setup and monitoring configuration complete. Please verify the setup by visiting the Nagios web interface."
