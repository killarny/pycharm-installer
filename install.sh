#! /bin/bash

pycharm=${HOME}/.config/JetBrains/PyCharm2020.1
java_userprefs=${HOME}/.java/.userPrefs/jetbrains
jb_share=${HOME}/.local/share/JetBrains
workdir=${HOME}/.__pycharm_installer
rundir=$( cd $(dirname $0) ; pwd -P )
icon_url=https://d3nmt5vlzunoa1.cloudfront.net/pycharm/files/2015/12/PyCharm_400x400_Twitter_logo_white.png

echo "Preparing your environment.."
echo "  (this may ask for a sudo password to install some requirements)"

# install requirements
sudo apt-get install -y curl git

echo "Installing JDK.."
sudo add-apt-repository -y ppa:linuxuprising/java
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
DEBIAN_FRONTEND=noninteractive sudo apt-get install -qqy oracle-java14-installer

# set up workdir
rm -rf $workdir
mkdir -p $workdir

# set up selenium
#sudo apt-get install -y xvfb wget python-pip
#pip install -U pyvirtualdisplay selenium

# install browser driver since selenium annoyingly doesn't handle that for us
#cd $workdir
#latest_driver_version=$(wget -qO- https://chromedriver.storage.googleapis.com/LATEST_RELEASE |cat)
#wget -q https://chromedriver.storage.googleapis.com/$latest_driver_version/chromedriver_linux64.zip
#unzip chromedriver_linux64.zip
#rm chromedriver_linux64.zip
#cd -

# look in the user's downloads for a pycharm release
echo "Searching in ${HOME}/Downloads for an existing release download.."
if [ -f ${HOME}/Downloads/pycharm*.tar.gz ]; then
  echo
  echo "Found existing PyCharm release in ~/Downloads"
  echo "  (copying it to a working directory)"
  cp ${HOME}/Downloads/pycharm*.tar.gz $workdir
else
  echo "Existing release download not found."
fi

#if [ ! -f $workdir/pycharm*.tar.gz ]; then
#  cd $workdir
#  echo
#  echo "Downloading latest PyCharm release.."
#  echo "  (will show a browser window; close browser when download finished)"
#  PATH=$PATH:$workdir python $rundir/geturl.py --directory=$workdir
#  cd -
#fi

echo "  unpacking PyCharm.."
if [ ! -f $workdir/pycharm*.tar.gz ]; then
  echo "ERROR: cannot find downloaded PyCharm release!"
  echo "  (try opening https://www.jetbrains.com/pycharm/download/"
  echo "   in your browser, download the release, and run this "
  echo "   script again.)"
  exit 1
fi
cd $workdir
tar zxf pycharm*.tar.gz
rm pycharm*.tar.gz
mv pycharm* $workdir/unpacked
cd -


echo "Removing your old PyCharm configuration.."
rm -rf $pycharm
rm -rf $java_userprefs
rm -rf $jb_share

echo "Configuring PyCharm installation.."
mkdir $pycharm

# copy preserved configs
cp -r $rundir/config $pycharm/config

# echo "Installing your plugins and bundles.."
# # install plugins
# mkdir -p $pycharm/config/plugins
# cd $pycharm/config/plugins
# # codeglance
# wget --content-disposition $(PATH=$PATH:$workdir python $rundir/geturl.py --plugin 7275)
# # .ignore
# wget --content-disposition $(PATH=$PATH:$workdir python $rundir/geturl.py --plugin 7495)
# # bashsupport
# wget --content-disposition $(PATH=$PATH:$workdir python $rundir/geturl.py --plugin 4230)
# # git flow integration
# wget --content-disposition $(PATH=$PATH:$workdir python $rundir/geturl.py --plugin 7315)
# # docker integration
# wget --content-disposition $(PATH=$PATH:$workdir python $rundir/geturl.py --plugin 7724)
# # key promoter
# wget --content-disposition $(PATH=$PATH:$workdir python $rundir/geturl.py --plugin 9792)
# # bootstrap 4 & font awesome
# wget --content-disposition $(PATH=$PATH:$workdir python $rundir/geturl.py --plugin 9341)
# find . -name '*.zip' -print0 | xargs -0 -I {} -P 10 unzip -qq {}
# cd -

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
