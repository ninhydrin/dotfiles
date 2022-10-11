

sudo adduser hoge
sudo gpasswd -a hoge sudo
sudo gpasswd -d pi sudo
sudo rm /etc/sudoers.d/010_pi-nopasswd
su hoge
cd
git clone http://github.com/ninhydrin/dotfiles
cd dotfiles
make deploy
cd
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install zsh emacs tmux fcitx-mozc vim

chsh -s /usr/bin/zsh

# piユーザーを無効化
sudo usermod --expiredate 1 pi

# ローカルで
ssh-copy-id -i ~/.ssh/id_rsa.pub hoge@XXX.XXX.XXX.XXX

# PasswordAuthentication no 追加
sudo vi /etc/ssh/sshd_config

# exFAT用
sudo apt-get install exfat-fuse exfat-utils

# samba
sudo apt install -y samba

# sambaの設定
sudo vim /etc/samba/smb.conf

#  [raspberryPi] 見える名前
#      comment = RasPi
#      path = /home/pi/Public
#      guest ok = yes
#      read only = no
#      browsable = no
#      force user = hoge

# sambaに接続するユーザーにパスワードを設定
sudo smbpasswd -a hoge

# pyenv
sudo apt install -y git openssl libssl-dev libbz2-dev libreadline-dev libsqlite3-dev libffi-dev
git clone https://github.com/yyuu/pyenv.git ~/.pyenv
# vnc
# 参考
# https://qiita.com/karaage0703/items/9650e7aeceb6e1b81612
# https://yrhw0609.hatenablog.com/entry/2019/06/09/181808

# 5 Interfacing Optionsの選択肢、P3 VNCでYESで有効化
sudo raspi-config

# 確認
systemctl status vncserver-x11-serviced

# Authentication=VncAuthを追加
vi /root/.vnc/config.d/vncserver-x11

# vncのパスワード追加
sudo vncpasswd -service

# 解像度設定
sudo nano /boot/config.txt
# hdmi_group=2
# hdmi_mode=(自分の解像度に合ったやつ)
# https://elinux.org/RPiconfig#Video_mode_optionsを参考に
# もしくは
sudo raspi-config
#して2 Display option -> D1 Resolution で設定

# vnc://XXX.XXX.XXX.XXX:5901 or vnc://raspberrypi.local:5901で接続


# sudo touch /boot/ssh
# autologin変更
# sudo emacs /etc/lightdm/lightdm.conf

# wget https://github.com/lhelontra/tensorflow-on-arm/releases/download/v1.3.1/tensorflow-1.3.1-cp35-none-linux_armv7l.whl
# pip3 install tensorflow-1.3.1-cp35-none-linux_armv7l.whl
# git clone http://github.com/Movidius/ncsdk && cd ncsdk && make install && make examples
