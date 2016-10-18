from argparse import ArgumentParser
from selenium import webdriver


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


class Browser(webdriver.Firefox):
    pass


def get_plugin_url(id, plugin_url):
    HiddenDisplay.start()
    browser = Browser()
    browser.get(plugin_url.format(id=id))
    url = (browser.find_element_by_class_name('_download')
           .find_element_by_tag_name('a')
           .get_attribute('href'))
    browser.quit()
    HiddenDisplay.stop()
    return url


def get_url(pycharm_url):
    HiddenDisplay.start()
    browser = Browser()
    browser.get(pycharm_url)
    url = browser.find_element_by_link_text('direct link').get_attribute('href')
    browser.quit()
    HiddenDisplay.stop()
    return url


if __name__ == '__main__':
    parser = ArgumentParser(description='specify a plugin ID to get the '
                                        'download URL for that, or nothing to '
                                        'get the main PyCharm download URL')
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
        print(get_url(opts.pycharm_url))

