## Linux palvelimena
```bash
sudo apt install nginx pipx python3.11
sudo mkdir -p /data/www
sudo sed -i "s/\/var\/www\/html;/\/data\/www;/" /etc/nginx/sites-enabled/default
sudo systemctl restart nginx
pipx install poetry
pipx ensurepath
git clone https://github.com/sourander/linux-perusteet.git /tmp/linux-perusteet
cd /tmp/linux-perusteet
poetry install --no-root
poetry run mkdocs build
sudo chown -R ao:ao /data
mv -f site/* /data/www/
```

