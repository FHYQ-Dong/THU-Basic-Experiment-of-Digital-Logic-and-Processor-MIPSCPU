import os
import argparse

def asm2inst(asm_file, inst_file, mode='HexText'):
    """
    Convert assembly instructions to machine code instructions.
    
    :param asm_file: Path to the input assembly file.
    :param inst_file: Path to the output instruction file.
    """
    if not os.path.exists(asm_file):
        raise FileNotFoundError(f"Assembly file '{asm_file}' does not exist.")
    
    cmd = f"java -jar Mars4_5.jar {asm_file} a dump .text HexText {inst_file}"
    os.system(cmd)
    lines = []
    with open(inst_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    with open(inst_file, 'w', encoding='utf-8') as f:
        f.writelines(lines + ["00000000\n"] * (256 - len(lines)))
    
    if mode == 'VerilogCase':
        new_lines = []
        with open(inst_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        inst_idx = 0
        for line in lines:
            new_lines.append(f"32'h0040_{inst_idx:04x}: Instruction = 32'h{line[:4]}_{line[4:8]};\n")
            inst_idx += 4
        with open(inst_file, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
            f.write("default:       Instruction = 32'h0000_0000;\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert assembly instructions to machine code instructions.")
    parser.add_argument("asm_file", help="Path to the input assembly file.")
    parser.add_argument("inst_file", help="Path to the output instruction file.")
    parser.add_argument("--mode", "-m", help="Convert mode (HexText or VerilogCase)", default=None)
    args = parser.parse_args()
    if not os.path.exists(args.asm_file):
        print(f"Error: Assembly file '{asm_file}' does not exist.")
        exit(1)
    
    try:
        asm2inst(args.asm_file, args.inst_file, args.mode)
        print(f"Converted '{args.asm_file}' to '{args.inst_file}' successfully.")
    except Exception as e:
        print(f"Error: {e}")