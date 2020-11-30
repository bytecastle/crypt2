import logging
import os


def setup_logger(file, level=logging.INFO):
    logging.info('setting up logger')
    index = file.find('.log')
    name = file[0:index]
    n = 1
    while os.path.isfile(file):
        file = name+'_'+str(n)+'.log'
        n += 1

    # removing old handlers
    for handler in logging.root.handlers[:]:
        logging.root.removeHandler(handler)

    logging.basicConfig(filename=file,
                        format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
                        datefmt='%H:%M:%S',
                        level=level)
    console = logging.StreamHandler()
    console.setLevel(level)
    console.setFormatter(logging.Formatter('%(levelname)s - %(message)s'))
    logging.getLogger('').addHandler(console)
