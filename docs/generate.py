from os.path import join, dirname

try:
    from robot.libdoc import libdoc
except:
    def main():
        print("""Robot Framework required for generating documentation""")
else:
    def main():
        libdoc(join(dirname(__file__), '..', 'src', 'Suds2Library'), join(dirname(__file__), 'Suds2Library.html'))

if __name__ == '__main__':
    main()
