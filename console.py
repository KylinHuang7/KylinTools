# -*- coding: utf-8 -*-
from __future__ import print_function, division

import time
import curses
import traceback

class TestConsole(object):
    def __init__(self):
        self.width = 79
        self.height = 23
        self.padding_left = 2
        self.padding_top = 2
        self.padding_bottom = 2
        self.buffer = []
        self.buffer_length = self.height - self.padding_top - self.padding_bottom - 2
        self.prompt = '>'
        self.input_command = '\n'
        self.quit_command = 'quit'
        self.command_quiting = False
    
    def start(self):
        stdscr = curses.initscr()
        self.screen = stdscr.subwin(self.height, self.width, 0, 0)
        self.screen.nodelay(1)
    
    def end(self):
        if not self.command_quiting:
            time.sleep(5)
        self.screen.nodelay(0)
        curses.endwin()
    
    def run(self):
        try:
            self.start()
            self.init()
            
            command = self.input()
            while command != self.quit_command:
                self.buffer.append(command)
                if len(self.buffer) > self.buffer_length:
                    self.buffer = self.buffer[-self.buffer_length:]
                self.clean_input()
                self.show_buffer()
                command = self.input()
            self.end()
        except:
            self.end()
            traceback.print_exc()
    
    def init(self):
        self.screen.box()
        self.screen.hline(self.height - 3, 1, curses.ACS_HLINE, self.width - 2)
        self.screen.move(self.height - 2, self.padding_left)
        self.screen.addstr(self.height - 2, self.padding_left, self.prompt, curses.A_NORMAL)
        self.screen.refresh()
        self.screen.move(self.height - 2, self.padding_left + len(self.prompt) + 1)
    
    def input(self):
        max_length = self.width - 2 - len(self.prompt) - self.padding_left
        self.screen.move(self.height - 2, self.padding_left + len(self.prompt) + 1)
        buffer = ''
        c = self.screen.getch()
        while c != ord(self.input_command):
            if c != -1:
                if len(buffer) < max_length:
                    buffer += chr(c)
                self.screen.addstr(self.height - 2, self.padding_left + len(self.prompt) + len(buffer), chr(c), curses.A_NORMAL)
            c = self.screen.getch()
        return buffer
    
    def clean_buffer(self):
        for i in xrange(self.buffer_length):
            line = i + self.padding_top
            self.screen.addstr(line, self.padding_left + 1, ' ' * (self.width - 2 - self.padding_left), curses.A_NORMAL)
    
    def clean_input(self):
        self.screen.addstr(self.height - 2, self.padding_left + len(self.prompt) + 1, ' ' * (self.width - 2 - len(self.prompt) - self.padding_left), curses.A_NORMAL)
    
    def show_buffer(self):
        self.clean_buffer()
        length = len(self.buffer)
        for i in xrange(length):
            line = i + self.padding_top
            self.screen.addstr(line, self.padding_left + 1, self.buffer[i], curses.A_NORMAL)
        self.screen.refresh()
        self.screen.move(self.height - 2, self.padding_left + len(self.prompt) + 1)

if __name__ == "__main__":
    test_console = TestConsole()
    test_console.run()
