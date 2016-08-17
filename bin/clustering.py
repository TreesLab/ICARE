#! /usr/bin/env python2

import argparse

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE,SIG_DFL)


def get_complement_snv_type(snv_type):
    def get_complement_base(base):
        if base == 'A':
            return 'T'
        elif base == 'T':
            return 'A'
        elif base == 'C':
            return 'G'
        elif base == 'G':
            return 'C'

    return 'to'.join(map(get_complement_base, snv_type.split('to')))


# ---------------------- main ---------------------- #
def clustering(MEFok_data, min_cluster_dist=50, max_site_dist=100, reverse_minus_strand_snv_type=False):
    result_data = MEFok_data[:]
    data_length = len(MEFok_data)

    ## get complement snv_type if strand is '-'
    if reverse_minus_strand_snv_type:
        for line in result_data:
            if line[3] == '-':
                line[6] = get_complement_snv_type(line[6])

    ## get up_dist, down_dist
    for idx in range(data_length):
        if idx == 0:
            up_dist = None
        else:
            if result_data[idx][4] == result_data[idx-1][4]:
                up_dist = int(result_data[idx][1]) - int(result_data[idx-1][1])
            else:
                up_dist = None

        if idx == data_length - 1:
            down_dist = None
        else:
            if result_data[idx+1][4] == result_data[idx][4]:
                down_dist = int(result_data[idx+1][1]) - int(result_data[idx][1])
            else:
                down_dist = None

        result_data[idx] += [up_dist, down_dist]

    ## get cluster number
    for idx in range(data_length):
        gene_id = result_data[idx][4]
        snv_type = result_data[idx][6]
        up_dist = result_data[idx][7]
        down_dist = result_data[idx][8]

        if idx == 0:
            gene_id_next = result_data[idx+1][4]
            snv_type_next = result_data[idx+1][6]
            # FIX 1: fix condition of first one
            if (gene_id == gene_id_next) and (snv_type == snv_type_next):
                cluster_number = 1
            elif down_dist > min_cluster_dist:
                cluster_number = 1
            else:
                cluster_number = None
        elif idx == data_length - 1:
            gene_id_pre = result_data[idx-1][4]
            snv_type_pre = result_data[idx-1][6]
            cluster_number_pre = result_data[idx-1][9]
            if (gene_id == gene_id_pre) and (snv_type == snv_type_pre) and (up_dist < max_site_dist) and (cluster_number_pre != None):
                cluster_number = cluster_number_pre + 1
            elif up_dist > min_cluster_dist: # FIX 3: fix condition of last one
                cluster_number = 1
            else:
                cluster_number = None
        else:
            gene_id_pre = result_data[idx-1][4]
            snv_type_pre = result_data[idx-1][6]
            cluster_number_pre = result_data[idx-1][9]

            gene_id_next = result_data[idx+1][4]
            snv_type_next = result_data[idx+1][6]

            # THIS PART NEED REORGANIZATION !!!
            if (gene_id == gene_id_pre) and (snv_type == snv_type_pre) and \
                (gene_id == gene_id_next) and (snv_type == snv_type_next) and \
                (up_dist < max_site_dist) and (cluster_number_pre != None):
                cluster_number = cluster_number_pre + 1
            elif (gene_id == gene_id_pre) and (snv_type == snv_type_pre) and \
                ((gene_id == gene_id_next) or (snv_type == snv_type_next)) and \
                (up_dist < max_site_dist) and (cluster_number_pre != None) and \
                (down_dist != None) and (down_dist > min_cluster_dist):
                cluster_number = cluster_number_pre + 1
            elif (gene_id == gene_id_pre) and (snv_type == snv_type_pre) and \
                (up_dist < max_site_dist) and (cluster_number_pre != None) and (down_dist == None):
                cluster_number = cluster_number_pre + 1
            elif (gene_id == gene_id_next) and (snv_type == snv_type_next) and \
                ((up_dist > min_cluster_dist) or (up_dist == None)):
                cluster_number = 1
            elif ((up_dist == None) or (up_dist > min_cluster_dist)) and ((down_dist == None) or (down_dist > min_cluster_dist)):
                cluster_number = 1
            else:
                cluster_number = None

        result_data[idx] += [cluster_number]

    ## get modified cluster number
    for idx in reversed(range(data_length)):
        down_dist = result_data[idx][8]
        cluster_number = result_data[idx][9]

        if idx == data_length -1:
            mod_cluster_number = cluster_number
        else:
            if cluster_number == None:
                mod_cluster_number = None                
            else:
                if (result_data[idx+1][10] == None) and ((down_dist != None) and (down_dist <= min_cluster_dist)):
                    mod_cluster_number = None
                else:
                    mod_cluster_number = cluster_number

        result_data[idx] += [mod_cluster_number]

    ## get cluster_count
    for idx in reversed(range(data_length)):
        mod_cluster_number = result_data[idx][10]

        if idx == data_length -1:
            cluster_count = mod_cluster_number
        else:
            mod_cluster_number_next = result_data[idx+1][10]
            if mod_cluster_number == None:
                cluster_count = None
            else:
                if mod_cluster_number_next == None:
                    cluster_count = mod_cluster_number
                else:
                    if mod_cluster_number > mod_cluster_number_next:
                        cluster_count = mod_cluster_number
                    elif mod_cluster_number < mod_cluster_number_next:
                        cluster_count = result_data[idx+1][11]
                    else:
                        if (mod_cluster_number == 1) and (mod_cluster_number_next == 1):
                            cluster_count = 1
                        else:
                            cluster_count = None

        result_data[idx] += [cluster_count]

    return result_data
# -------------------------------------------------- #


def readTSV(in_file):
    with open(in_file) as data_reader:
        all_data = [line.rstrip('\n').split('\t') for line in data_reader]
    return all_data


def writeTSV(result, out_file):
    toString = lambda x: "" if x==None else str(x)
    with open(out_file, 'w') as data_writer:
        for line in result:
            print >> data_writer, '\t'.join(map(toString, line))


def printTSV(result):
    toString = lambda x: "" if x==None else str(x)
    for line in result:
        print '\t'.join(map(toString, line))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-cd', '--cluster_dist', type=int, default=50, help='The minimum distance between two clusters. Defaul 50.')
    parser.add_argument('-sd', '--site_dist', type=int, default=100, help='The maximun distance between two sites in a cluster. Default 100.')
    parser.add_argument('-rev', '--reverse_minus_snv', action="store_true", help='Reverse the snv type of minus strand if this option is assigned.')
    parser.add_argument('-o', '--output', type=str, help='The output filename. If there is no output filename assigned, the result will print into stdout.')
    parser.add_argument('MEFok_data', type=str, help='MEFok data')
    args = parser.parse_args()

    result = clustering(readTSV(args.MEFok_data), args.cluster_dist, args.site_dist, args.reverse_minus_snv)

    if args.output:
        writeTSV(result, args.output)
    else:
        printTSV(result)






if __name__ == "__main__":
    main()
















