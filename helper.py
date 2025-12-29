import subprocess
import re
import os

def start_dev_tunnel() -> tuple[str, subprocess.Popen ] | None:
    PID_FILE_PATH = "devtunnel.pid"

    if (os.path.exists(PID_FILE_PATH)):
        raise Exception("devtunnel already running!")

    process = subprocess.Popen(["devtunnel", "host", "-p", "8080"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, text=True)
    for i in range(0, 4):
        if process.stdout is not None:
            line = process.stdout.readline()
            match = re.search(r"https:\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])", line)
            if match is not None:
                print("Started devtunnel on port 8080")
                with open(PID_FILE_PATH, "w") as pid_file:
                    pid_file.write(str(process.pid))

                return (match.group(), process)
        else:
            raise Exception("Couldn't launch the dev tunnel. Is any other application running on 8080?")