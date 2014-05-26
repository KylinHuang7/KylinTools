# -*- coding: utf-8 -*-
from __future__ import print_function, division

import re
import urllib
import random
import socket
import StringIO

import pycurl

class Browser:
    def __init__(self, option={}):
        self._response      = ''
        self._domain        = ""
        self._user_agent    = "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"
        self._charset       = "utf-8"
        self._header        = None
        self._history       = []
        self._cookie_file   = '/tmp/'
        self._error         = False
        self._error_msg     = ""
        self._crawler       = pycurl.Curl()
        self._proxies       = None
        socket.setdefaulttimeout(30)
        for i in xrange(12):
            self._cookie_file += random.choice('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789')

        if "domain" in option:
            self._domain    = option["domain"]
        if "User-Agent" in option:
            self._user_agent = option["User-Agent"]
        if "charset" in option:
            self._charset   = option["charset"]
        if "Header" in option:
            self._charset   = option["charset"]
        if "Header" in option:
            self._header    = option["Header"].split("\n")
        self._crawler.setopt(pycurl.NOSIGNAL, 1)
        self._crawler.setopt(pycurl.FAILONERROR, 1)
        self._crawler.setopt(pycurl.AUTOREFERER, 1)
        self._crawler.setopt(pycurl.FOLLOWLOCATION, 1)
        self._crawler.setopt(pycurl.MAXREDIRS, 10)
        self._crawler.setopt(pycurl.MAXCONNECTS, 1)
        self._crawler.setopt(pycurl.FORBID_REUSE, 1)
        self._crawler.setopt(pycurl.TIMEOUT, 30)
        self._crawler.setopt(pycurl.USERAGENT, self._user_agent)
        self._crawler.setopt(pycurl.COOKIEFILE, self._cookie_file)
        self._crawler.setopt(pycurl.COOKIEJAR, self._cookie_file)
        if self._header:
            self._crawler.setopt(pycurl.HTTPHEADER, self._header)
        else:
            self._crawler.setopt(pycurl.HTTPHEADER, ['Expect:'])

    def __del__(self):
        self._crawler.close()

    def visit(self, url, follow=True):
        url = self._pre_action(url, follow)
        if self._error:
            return
        b = StringIO.StringIO()
        self._crawler.setopt(pycurl.WRITEFUNCTION, b.write)
        self._crawler.setopt(pycurl.URL, url)
        self._crawler.setopt(pycurl.HTTPGET, 1)
        try:
            print("Visit {0}.".format(url))
            self._crawler.perform()
            self._response = b.getvalue()
            self._error = False
        except pycurl.error as err:
            self._error = True
            self._error_msg = err[1]
            print("Error occured: {0}.".format(self._error_msg))
        self._post_action(follow)

    def submit(self, url, data, follow=True):
        url = self._pre_action(url, follow)
        if self._error:
            return
        b = StringIO.StringIO()
        self._crawler.setopt(pycurl.WRITEFUNCTION, b.write)
        self._crawler.setopt(pycurl.URL, url)
        self._crawler.setopt(pycurl.POSTFIELDS, urllib.urlencode(data))
        try:
            print("Submit {0} to {1}.".format(urllib.urlencode(data), url))
            self._crawler.perform()
            self._response = b.getvalue()
            self._error = False
        except pycurl.error as err:
            self._error = True
            self._error_msg = err[1]
            print("Error occured: {0}.".format(self._error_msg))
        self._post_action(follow)

    def error(self):
        return self._error

    def content(self):
        if self._error:
            return self._error_msg
        elif self._response is None:
            return ''
        else:
            content = self._response
            m = re.search('<meta.*?charset=\"?([\w\d-]+)\"?.*?\/?>', content)
            if m:
                charset = m.group(1)
                if charset != self._charset:
                    try:
                        content = self._response.decode(charset).encode(self._charset)
                    except UnicodeDecodeError as err:
                        print("Error when decode content: {0}.".format(err[1]))
            return content

    def binary_content(self):
        if self._error:
            return self._error_msg
        elif self._response is None:
            return ''
        else:
            return self._response

    def _set_header(self):
        if len(self._history) > 0:
            self._crawler.setopt(pycurl.REFERER, self._history[0])

    def _pre_action(self, url, follow=True):
        self._error = False
        self._error_msg = ''
        self._response = ''
        if not re.search("://", url):
            if re.search("^/", url):
                url = "http://" + self._domain + url
            else:
                m = re.search("^(.*/)[^/]*$", self._history[0])
                url = m.group(1) + url
        self._set_header()
        if follow:
            m = re.search("://([^/?]*)[/?]?", url)
            self._domain = m.group(1)
            self._history.insert(0, url)
        m = re.search("^(\w+):", url)
        if (m.group(1) != 'http' and m.group(1) != 'https'):
            self._error_msg = "Do not support protocol."
            self._error = True
            print("Used unsupported protocal: {0}.".format(m.group(1)))
        return url

    def _post_action(self, follow=True):
        if follow:
            last_url = self._crawler.getinfo(pycurl.EFFECTIVE_URL)
            if last_url != self._history[0]:
                m = re.search("://([^/?]*)[/?]?", last_url)
                self._domain = m.group(1)

if __name__ == "__main__":
    succ = None
    c = 0
    while not succ:
        c += 1
        if c == 5:
            break
        a = Browser()
        a.visit('http://www.baidu.com')
        succ = re.search('<html[^>]*>(.*)</html>', a.content(), re.M | re.S)
    succ = None
    c = 0
    while not succ:
        c += 1
        if c == 5:
            break
        a = Browser()
        a.visit('http://www.google.com.hk')
        succ = re.search('<html[^>]*>(.*)</html>', a.content(), re.M | re.S)
