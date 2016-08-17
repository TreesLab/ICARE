#! /usr/bin/env python2

import argparse

def merge_bed(main_file, second_files):
    with open(main_file) as data_reader:
        main_data = [line.rstrip('\n').split('\t') for line in data_reader]
    
    for second_file in second_files:
        with open(second_file) as data_reader:
            second_data = [line.rstrip('\n').split('\t') for line in data_reader]
            second_data_dict = dict([[tuple(line[:3]), line[3]] for line in second_data])
            
        for i in range(len(main_data)):
            line_key = tuple(main_data[i][:3])
            if second_data_dict.has_key(line_key):
                main_data[i].append(second_data_dict[line_key])
            else:
                main_data[i].append("")
    return main_data

def write_tsv(result, out_file):
    if out_file == None:
        for line in result:
            print '\t'.join(line)
    else:
        with open(out_file, 'w') as data_writer:
            for line in result:
                print >> data_writer, '\t'.join(line)

def main():
    p = argparse.ArgumentParser()
    p.add_argument("main_file", help="Main file.")
    p.add_argument("second_file", nargs="+", help="Second file.")
    p.add_argument("-o", "--output", help="Output.")
    args = p.parse_args()


    result = merge_bed(args.main_file, args.second_file)
    write_tsv(result, args.output)


if __name__ == "__main__":
    main()
