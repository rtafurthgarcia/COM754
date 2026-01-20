import subprocess
import re
import os

def start_dev_tunnel(pid_path: str, port: int) -> tuple[str, subprocess.Popen]:
    if (port <= 1024):
        raise ConnectionError("Won't run anything on privileged ports!")

    if (os.path.exists(pid_path)):
        raise Exception("devtunnel already running!")

    process = subprocess.Popen(["devtunnel", "host", "-p", str(port)], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, text=True)
    for i in range(0, 4):
        if process.stdout is not None:
            line = process.stdout.readline()
            match = re.search(r"https:\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])", line)
            if match is not None:
                host = match.group()
                print("Started devtunnel on port " + str(port))
                with open(pid_path, "w") as pid_file:
                    pid_file.write(host)

                return (host, process)
        else:
            raise Exception("Couldn't launch the dev tunnel. Is any other application running on {}?".format(str(port)))
    
    raise Exception("Couldn't launch the dev tunnel. Is any other application running on {}?".format(str(port)))
        
def read_pid(pid_path: str) -> tuple[str, int]:
    with open(pid_path, "r") as pid_file:
        content = pid_file.readline()

        port = int(content[:content.rfind(":")])
        host = content[content.rfind(":"):]

        return host, port

def close_dev_tunnel(process: subprocess.Popen):
    process.kill()

    os.remove("*.pid")