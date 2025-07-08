import argparse
import os

def printbin(filename, byteorder='big', outputorder='big'):
    with open(filename, 'rb') as f:
        content = f.read()
    for i in range(0, len(content), 4):
        if i + 4 <= len(content):
            word = content[i: i+4]
            word = int.from_bytes(word, byteorder=byteorder)
            word = word.to_bytes(4, byteorder=outputorder)
            # 32'h format
            print(f"memory[{i//4:2d}] <= 32'h{word[0]:02x}{word[1]:02x}_{word[2]:02x}{word[3]:02x};")
        else:
            # Handle the case where the last word is less than 4 bytes
            word = content[i:] + b'\x00' * (4 - len(content[i:]))
            word = int.from_bytes(word, byteorder=byteorder)
            word = word.to_bytes(4, byteorder=outputorder)
            print(f"memory[{i//4:2d}] <= 32'h{word[0]:02x}{word[1]:02x}_{word[2]:02x}{word[3]:02x};")
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Print binary representation of a file.")
    parser.add_argument("filename", help="Path to the binary file.")
    parser.add_argument("--byteorder", "-bo", choices=['big', 'little'], default='big',
                        help="Byte order of the input file (default: big).")
    parser.add_argument("--outputorder", "-oo", choices=['big', 'little'], default='big',
                        help="Byte order of the output (default: big).")
    args = parser.parse_args()
    if not os.path.exists(args.filename):
        print(f"Error: File '{args.filename}' does not exist.")
        exit(1)

    try:
        printbin(args.filename, byteorder=args.byteorder, outputorder=args.outputorder)
    except Exception as e:
        print(f"Error: {e}")
        exit(1)
