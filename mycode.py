import os

FILENAME = "C:/emu8086/MyBuild/FILE.txt"


def main():
    file_last_mod_time = 0
    while True:
        s = os.stat(FILENAME)
        if s.st_mtime > file_last_mod_time:
            file_last_mod_time = s.st_mtime
            with open(FILENAME, 'r') as f:
                u = f.read()
                print(f'[INPUT] {u}')

if __name__ == '__main__':
    main()
