from argparse import ArgumentParser
from time import sleep
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException


class HiddenDisplay:
    @classmethod
    def start(cls):
        try:
            if cls.display:
                return
        except AttributeError:
            pass
        try:
            from pyvirtualdisplay import Display
        except ImportError:
            pass
        else:
            from easyprocess import EasyProcessCheckInstalledError
            try:
                cls.display = Display(visible=0, size=(800, 600))
                cls.display.start()
            except EasyProcessCheckInstalledError:
                pass

    @classmethod
    def stop(cls):
        try:
            cls.display.stop()
        except AttributeError:
            pass


class Browser(webdriver.Chrome):
    def __init__(self, directory='.'):
        opts = webdriver.ChromeOptions()
        opts.add_experimental_option("prefs",
            {"download.default_directory": directory,
             "download.prompt_for_download": False})
        super(Browser, self).__init__(chrome_options=opts)


def get_plugin_url(id, plugin_url):
    __plugin_url = plugin_url.format(id=id)
    HiddenDisplay.start()
    browser = Browser()
    browser.get(__plugin_url)
    sleep(0.5)
    max_tries = 10
    url = None
    for i in range(0, max_tries):
        try:
            if i:
                print('..failed..retry {}'.format(i))
            url = (browser.find_element_by_class_name('_download')
                   .find_element_by_tag_name('a')
                   .get_attribute('href'))
        except NoSuchElementException:
            sleep(0.5)
            continue
        break
    if not url:
        raise Exception("Unable to parse page at: {}".format(__plugin_url))
    browser.quit()
    HiddenDisplay.stop()
    return url


def download_pycharm(pycharm_url, directory='.'):
    browser = Browser(directory=directory)
    browser.get(pycharm_url)
    browser.quit()


if __name__ == '__main__':
    parser = ArgumentParser(description='specify a plugin ID to get the '
                                        'download URL for that, or nothing to '
                                        'download the latest PyCharm')
    parser.add_argument('--directory', default='.')
    parser.add_argument('--plugin', type=int, dest='ID')
    parser.add_argument('--pycharm-url', help='default: %(default)s',
                        default='https://www.jetbrains.com/pycharm/download/'
                                'download-thanks.html?platform=linux')
    parser.add_argument('--plugin-url', help='default: %(default)s',
                        default='https://plugins.jetbrains.com/plugin/{id}')
    opts = parser.parse_args()
    if opts.ID:
        print(get_plugin_url(opts.ID, opts.plugin_url))
    else:
        download_pycharm(opts.pycharm_url, directory=opts.directory)

