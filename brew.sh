#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names
# Install a modern version of Bash.
brew install bash
brew install bash-completion2

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;

brew install wget

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# Install more recent versions of some macOS tools.
brew install neovim
brew install grep
brew install openssh
brew install screen
brew install php
brew install gmp
brew install python@3.9

# Install font tools.
brew tap bramstein/webfonttools
brew install sfnt2woff
brew install sfnt2woff-zopfli
brew install woff2

# Install other useful binaries.
brew install ack
brew install fzf
#brew install exiv2
brew install git
brew install git-lfs
brew install gs
brew install imagemagick
brew install lua
brew install lynx
brew install p7zip
brew install pigz
brew install pv
brew install rename
brew install rlwrap
brew install ssh-copy-id
brew install tree
brew install vbindiff
brew install zopfli

brew install bat
brew install prettyping

# Tools that I use for development
brew install awscli
brew install clojure
brew install borkdude/brew/clj-kondo
brew install leiningen
brew install packer
brew install pgcli
brew install terraform

# More tools I use
brew install jq
brew install ncdu
brew install q
brew install speedtest-cli
brew install the_silver_searcher
brew install tig
brew install tldr
brew install youtube-dl

# Fonts
brew tap homebrew/cask-fonts
brew install font-jetbrains-mono

# Brew Casks applications I use
brew install anki
# brew install bitwarden  ## must be installed through App Store
brew install caprine
brew install google-backup-and-sync
brew install iterm2
brew install keepassx
brew install keybase
brew install rectangle
brew install slack
brew install spotify
brew install sublime-text
brew install the-unarchiver
brew install homebrew/cask/transmission
brew install vlc
brew install whatsapp
brew install zoom

# Remove outdated versions from the cellar.
brew cleanup
