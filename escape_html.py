import sys

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1]:
        print(
            ''.join([f"&#{ord(c)};" for c in sys.argv[1]])
        )
