

sudo adduser hoge
sudo gpasswd -a hoge sudo
sudo gpasswd -d pi sudo
rm /etc/sudoers.d/010_pi-nopasswd
su hoge
cd
git clone http://github.com/ninhydrin/dotfiles
cd dotfiles
make deploy
cd
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install zsh emacs tmux fcitx-mozc

chsh -s /usr/bin/zsh
sudo touch /boot/ssh
# autologin変更
sudo emacs /etc/lightdm/lightdm.conf

wget https://github.com/lhelontra/tensorflow-on-arm/releases/download/v1.3.1/tensorflow-1.3.1-cp35-none-linux_armv7l.whl
pip3 install tensorflow-1.3.1-cp35-none-linux_armv7l.whl
git clone http://github.com/Movidius/ncsdk && cd ncsdk && make install && make examples
