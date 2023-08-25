import os

if __name__ == '__main__':
    # invoke from banners/
    dir = os.getcwd()

    # see https://docs.python.org/3/library/os.path.html#module-os.path
    base_dir = os.path.basename(os.fsdecode(dir))
    for file in os.listdir(dir):
        print(f"<img\n\tsrc={base_dir + '/' + file}\n\talt={file[:-4]}>")
        
