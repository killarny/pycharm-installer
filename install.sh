#! /bin/bash

pycharm=${HOME}/.PyCharm2016.3
java_userprefs=${HOME}/.java/.userPrefs/jetbrains
jb_share=${HOME}/.local/share/JetBrains
workdir=${HOME}/.__pycharm_installer
rundir=$( cd $(dirname $0) ; pwd -P )
icon_url=http://drslash.com/wp-content/uploads/2014/07/Intellij-PyCharm.png

echo "Preparing your environment.."
echo "  (this may ask for a sudo password to install some requirements)"
rm -rf $workdir
mkdir $workdir
sudo apt-get install -y xvfb
pip install pyvirtualdisplay selenium==2.53.1

echo "Downloading latest PyCharm release.."
echo "  (this may show a browser window for a few seconds, be patient)"
python geturl.py >> $workdir/__pycharm_url.txt
if [ ! -s $workdir/__pycharm_url.txt ]; then
    >&2 echo "Unable to retrieve the PyCharm url."
    exit 1
fi
curl -#L $(cat $workdir/__pycharm_url.txt) | tar zx
mv pycharm* $workdir/unpacked

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
cp -r config $pycharm/config

echo "Installing your plugins and bundles.."
# install plugins
mkdir -p $pycharm/config/plugins
cd $pycharm/config/plugins
wget --trust-server-names $(python $rundir/geturl.py --plugin 7275)
wget --trust-server-names $(python $rundir/geturl.py --plugin 7495)
wget --trust-server-names $(python $rundir/geturl.py --plugin 5970)
wget --trust-server-names $(python $rundir/geturl.py --plugin 4230)
wget --trust-server-names $(python $rundir/geturl.py --plugin 7315)
wget --trust-server-names $(python $rundir/geturl.py --plugin 7724)
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
