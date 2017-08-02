#! /bin/bash

pycharm=${HOME}/.PyCharm2017.2
java_userprefs=${HOME}/.java/.userPrefs/jetbrains
jb_share=${HOME}/.local/share/JetBrains
workdir=${HOME}/.__pycharm_installer
rundir=$( cd $(dirname $0) ; pwd -P )
icon_url=https://d3nmt5vlzunoa1.cloudfront.net/pycharm/files/2015/12/PyCharm_400x400_Twitter_logo_white.png

echo "Preparing your environment.."
echo "  (this may ask for a sudo password to install some requirements)"

# look in the user's downloads for a pycharm release
if [ -f ${HOME}/Downloads/pycharm*.tar.gz ]; then
  echo "Found existing PyCharm release in ~/Downloads"
  echo "  (copying it to a working directory)"
  mkdir -p $workdir
  cp ${HOME}/Downloads/pycharm*.tar.gz $workdir
fi

if [ ! -f $workdir/pycharm*.tar.gz ]; then
  # pycharm release not found, so try to download it
  rm -rf $workdir
  mkdir -p $workdir
  sudo apt-get install -y xvfb
  pip install -U pyvirtualdisplay selenium
  
  # install browser driver since selenium annoyingly doesn't handle that for us
  cd $workdir
  latest_driver_version=$(wget -qO- https://chromedriver.storage.googleapis.com/LATEST_RELEASE |cat)
  wget -q https://chromedriver.storage.googleapis.com/$latest_driver_version/chromedriver_linux64.zip
  unzip chromedriver_linux64.zip
  rm chromedriver_linux64.zip
  cd -
  
  cd $workdir
  echo "Downloading latest PyCharm release.."
  echo "  (will show a browser window; close browser when download finished)"
  PATH=$PATH:$workdir python $rundir/geturl.py --directory=$workdir
  cd -
fi

echo "  unpacking PyCharm.."
if [ ! -f $workdir/pycharm*.tar.gz ]; then
  echo "ERROR: cannot find downloaded PyCharm release!"
  exit 1
fi
cd $workdir
tar zxf pycharm*.tar.gz
rm pycharm*.tar.gz
mv pycharm* $workdir/unpacked
cd -

# TODO: improve this check for java
if [ -f /etc/apt/sources.list.d/webupd8team-java.list ]; then
  echo "JDK (probably) already installed, yay!"
else
  echo "Installing JDK.."
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | sudo tee /etc/apt/sources.list.d/webupd8team-java.list
  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | sudo tee -a /etc/apt/sources.list.d/webupd8team-java.list
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 2>> /dev/null
  echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
  echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
  sudo apt-get update -qq && DEBIAN_FRONTEND=noninteractive sudo apt-get install -qqy oracle-java8-installer
fi

echo "Removing your old PyCharm configuration.."
rm -rf $pycharm
rm -rf $java_userprefs
rm -rf $jb_share

echo "Configuring PyCharm installation.."
mkdir $pycharm

# copy preserved configs
cp -r $rundir/config $pycharm/config

echo "Installing your plugins and bundles.."
# install plugins
mkdir -p $pycharm/config/plugins
cd $pycharm/config/plugins
# codeglance
wget --content-disposition $(PATH=$PATH:$workdir python $rundir/geturl.py --plugin 7275)
# .ignore
wget --content-disposition $(PATH=$PATH:$workdir python $rundir/geturl.py --plugin 7495)
# markdown navigator
wget --content-disposition $(PATH=$PATH:$workdir python $rundir/geturl.py --plugin 7896)
# bashsupport
wget --content-disposition $(PATH=$PATH:$workdir python $rundir/geturl.py --plugin 4230)
# git flow integration
wget --content-disposition $(PATH=$PATH:$workdir python $rundir/geturl.py --plugin 7315)
# docker integration
wget --content-disposition $(PATH=$PATH:$workdir python $rundir/geturl.py --plugin 7724)
# key promoter
wget --content-disposition $(PATH=$PATH:$workdir python $rundir/geturl.py --plugin 9792)
# bootstrap 4 & font awesome
wget --content-disposition $(PATH=$PATH:$workdir python $rundir/geturl.py --plugin 9341)
find . -name '*.zip' -print0 | xargs -0 -I {} -P 10 unzip -qq {}
cd -

# textmate bundles
cd $workdir
git clone https://github.com/textmate/ruby.tmbundle.git
git clone https://github.com/jjeising/nginx.tmbundle.git
cd -

# add an application icon for gnome
curl -#L $icon_url -o $workdir/.pycharm-container-icon.png
cat << EOF > ${HOME}/.local/share/applications/pycharm-container.desktop
[Desktop Entry]
Name=PyCharm
Exec=$workdir/unpacked/bin/pycharm.sh
Icon=$workdir/.pycharm-container-icon.png
Type=Application
Categories=Development;

EOF
