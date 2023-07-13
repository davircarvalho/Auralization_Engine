def start_headtracker():
    import EACheadtracker
    EACheadtracker.start(port=50050)
try:
    start_headtracker()
except ImportError as e:
    print("Hello world!")
    print("Couldn't locate a EACheadtracker >> downloading and installing it!")
    import os
    os.system("pip install EACheadtracker")
    start_headtracker()