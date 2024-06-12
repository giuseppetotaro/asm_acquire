import subprocess
import threading
import time

def browse_services(service_type):
    name=''
    # Call the dns-sd command and browse for services
    proc = subprocess.Popen(['dns-sd', '-B', service_type], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    thread = threading.Thread(target=watch_timer, args=(proc,))
    thread.start()
    name = check_output(proc.stdout)
    #proc.terminate()
    thread.join()

    return name

def watch_timer(proc, secs=10):
    time.sleep(secs)
    proc.terminate()

def check_output(stream):
    header = False
    name = ''
    while True:
        line = stream.readline()
        if not line:
            break

        line = line.decode('utf-8').strip()
        if header:
            name = line[idx:]
            break

        idx = line.find("Instance Name")
        if idx >= 0:
            header = True

    return name

service_type='_smb._tcp'

if __name__ == "__main__":
    print(browse_services('_smb._tcp'))
