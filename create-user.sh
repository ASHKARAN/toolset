# Set the username and password for the new user
new_username="username"
new_password="password"

# Create the new user
sudo adduser --disabled-password --gecos "" $new_username

# Set the password for the new user
echo "$new_username:$new_password" | sudo chpasswd

# Add the new user to the sudo group (if needed)
sudo usermod -aG sudo $new_username

# Optional: Set up SSH access for the new user
sudo mkdir /home/$new_username/.ssh
sudo touch /home/$new_username/.ssh/authorized_keys
sudo chmod 700 /home/$new_username/.ssh
sudo chmod 600 /home/$new_username/.ssh/authorized_keys
sudo chown -R $new_username:$new_username /home/$new_username/.ssh
