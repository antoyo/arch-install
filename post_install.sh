#!/bin/bash

set -x

desktop=false
dev=false
laptop=false
images=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --desktop)
            desktop=true
            dev=true
            images=true
            shift
            ;;
        --laptop)
            laptop=true
            ;;
        *)
            echo "Unknown parameter: $1";
            exit 1
            ;;
    esac
    shift
done

sudo pacman -S --noconfirm 7zip asciidoctor-pdf alacritty arandr base-devel bat cmake cups discord duf dust fbreader fd feh firefox firefox-i18n-fr fish fzf gdb git-delta git-lfs gopass gopass-jsonapi gparted gst-libav gst-plugins-bad gst-plugins-base gst-plugins-good gst-plugins-ugly gstreamer gurk htop i3lock i3status-rust i3-wm less liferea man-db mpv neovim network-manager-applet nheko noto-fonts-emoji ouch p7zip pavucontrol pcmanfm pinentry plocate pulsemixer python-pynvim quassel-monolithic-qt ripgrep rofi rustup scrot sddm steam strace stow systray-x-common thunderbird thunderbird-i18n-fr translate-shell tree ttf-dejavu udiskie udisks2 util-linux xclip xdg-utils xdotool xorg-xsetroot xorg-xrandr yazi zathura zathura-pdf-poppler yt-dlp zoxide
#sudo pacman -S --noconfirm pidgin # TODO: remove?
if $dev
then
    sudo pacman -S --noconfirm crosstool-ng hyperfine lld nasm valgrind
fi
# TODO: install perf?
if $images
then
    sudo pacman -S --noconfirm gimp simple-scan
fi

sudo systemctl enable sddm.service

git clone git@github.com:antoyo/.dotfiles.git
pushd .dotfiles
apps=(alacritty directories fish gdb git gnupg gopass gtk-printers i3 i3status-rust less mimeapps nvim paru psql rofi yazi zathura)
# TODO: transmission?
for app in "${apps[@]}"
do
    stow --no-folding $app
done

apps=(apps makepkg pam-gnupg sudo sysrq systemd xorg)

for app in "${apps[@]}"
do
    sudo stow --no-folding --target=/ $app
done

popd

chsh bouanto -s /usr/bin/fish

sudo chown root:root /etc/sudoers.d/01_passwd_timeout

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

rustup default stable

mkdir Telechargements
git clone https://aur.archlinux.org/paru.git ~/Telechargements/paru
pushd ~/Telechargements/paru
makepkg -si
popd

paru -S --noconfirm fish-tide-git git-extras i3-notifier pam-gnupg pazi rustfilt
if $desktop
then
    paru -S --noconfirm chromium sunshine-bin samsung-unified-driver kepubify-bin joystickwake
fi

if $laptop
then
    paru -S --noconfirm i3-battery-popup
fi

# TODO: Set pacman color.
# TODO: install i3-aww.
# TODO: install quotes.

sudo systemctl enable cups

if $desktop
then
    # Website development:

    sudo pacman -S --noconfirm postgresql python-lsp-server uv
    # FIXME: this doesn't work.
    #sudo su postgres -c 'initdb -D /var/lib/postgres/data'
    sudo systemctl enable postgresql
fi
