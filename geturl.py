from argparse import ArgumentParser
from os import environ
from os.path import join
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.chrome.options import Options

def main(webdriver_dir):
    environ['PATH'] = ':'.join([environ.get('PATH'), webdriver_dir])

    options = Options()
    options.add_argument('--download')
    browser = webdriver.Chrome(chrome_options=options)

#    capabilities = DesiredCapabilities.FIREFOX
#    capabilities['marionette'] = True
#    capabilities['binary'] = '/usr/bin/firefox'
#    browser = webdriver.Firefox(capabilities=capabilities)

    browser.get('https://www.jetbrains.com/pycharm/download/download-thanks.html?platform=linux')
#    url = browser.find_element_by_link_text('direct link').get_attribute('href')
#    browser.quit()

#    print(url)


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('--webdriver_dir')
    opts = parser.parse_args()
    main(opts.webdriver_dir)

