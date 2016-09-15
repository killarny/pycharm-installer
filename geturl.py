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


def get_url():
    HiddenDisplay.start()
    browser = webdriver.Firefox()
    browser.get('https://www.jetbrains.com/pycharm/download/'
                'download-thanks.html?platform=linux')
    url = browser.find_element_by_link_text('direct link').get_attribute('href')
    browser.quit()
    HiddenDisplay.stop()
    return url


if __name__ == '__main__':
    print(get_url())

