#! /usr/bin/env python2

import argparse

def merge_column(in_file):
    with open(in_file) as data_reader:
        merged_dict = {}
        for line in data_reader:
            line_list = line.rstrip('\n').split('\t')
            line_key = tuple(line_list[:4])
            if merged_dict.has_key(line_key):
                merged_dict[line_key].append(line_list[4])
            else:
                merged_dict[line_key] = [line_list[4]]

    result = []
    for key in merged_dict.keys():
        merged_items = sorted(list(set(merged_dict[key])))
        line = list(key) + [','.join(merged_items), str(len(merged_items))]
        result.append(line)

    sorted_result = sorted(result, key=lambda x: x[:4])
    return sorted_result

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
    p.add_argument("-o", "--output", help="Output.")
    args = p.parse_args()

    result = merge_column(args.main_file)
    write_tsv(result, args.output)


if __name__ == "__main__":
    main()
