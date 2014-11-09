import os
import sys
import time
import datetime
import pyinotify

wm = pyinotify.WatchManager()

mask = pyinotify.IN_CREATE | pyinotify.IN_CLOSE_WRITE | pyinotify.IN_DELETE

date_str = datetime.datetime.today().strftime("%Y%m%d")
venus_dir = '/home/jail/home/uploader/venus'
venus_db_file = venus_dir + '/day.' + date_str + '.gz'

quit_flag = False

class EventHandler(pyinotify.ProcessEvent):
    def process_IN_CREATE(self, event):
        print "[", str(datetime.datetime.now()), "] Creating:", event.pathname
        sys.stdout.flush()

    def process_IN_CLOSE_WRITE(self, event):
        print "[", str(datetime.datetime.now()), "] Done:", event.pathname
        sys.stdout.flush()
        if event.pathname == venus_db_file:
            global quit_flag
            quit_flag = True

    def process_IN_DELETE(self, event):
        print "[", str(datetime.datetime.now()), "] Deleting:", event.pathname
        sys.stdout.flush()

handler = EventHandler()
notifier = pyinotify.Notifier(wm, handler)

wdd = wm.add_watch(venus_dir, mask, rec=True)

start_time = time.time()
while not quit_flag:
    notifier.process_events()
    if notifier.check_events(1):
        notifier.read_events()
notifier.stop()

print "[", str(datetime.datetime.now()), "] Cron Start!"
sys.stdout.flush()
os.system("/usr/bin/python /var/www/datamining/bin/venus_db.py >> /var/www/datamining/logs/db.log 2>&1")
os.system("/sbin/service infinidb restart >/dev/null 2>&1")
os.system("/usr/bin/python /var/www/datamining/bin/import_venus.py >> /var/www/datamining/logs/cron.log 2>&1")

