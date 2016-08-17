#! /usr/bin/env python2

import argparse

# ---------------------- main ---------------------- #
def cluster_nmm(cluster_data, strand_specific=False):
    def snv_type_count_init():
        count_dict = {}
        basename = ['A', 'C', 'G', 'T']
        for i in range(4):
            for j in range(4):
                if i != j:
                    snv_type = basename[i] + 'to' + basename[j]
                    count_dict[snv_type] = 0
        return count_dict

    print "nmm\tTtoA\tGtoA\tTtoC\tGtoC\tTtoG\tCtoG\tCtoA\tAtoT\tGtoT\tCtoT\tAtoC\tAtoG\ttotal" #\tAtoG/total\tGtoA/AtoG"

    nmm = 1
    while 1:
        nmm_count = snv_type_count_init()

        cluster_data_nmm_part = filter(lambda line1: (line1[11] != "") and (int(line1[11]) >= nmm), cluster_data)

        if len(cluster_data_nmm_part) == 0:
            print "No result!!"
            break

        for snv in map(lambda line2: line2[6], cluster_data_nmm_part):
            nmm_count[snv] += 1

        total_snv = sum(nmm_count.values())

        res_str = "%dmm\t"%nmm + "\t".join(map(str, nmm_count.values())) + "\t%d"%total_snv

        if nmm_count['AtoG'] == 0:
            print "No result!!"
            break

        if strand_specific:
            AtoG_all_ratio = float(nmm_count['AtoG']) / total_snv
            GtoA_AtoG_ratio = float(nmm_count['GtoA']) / nmm_count['AtoG']
            print res_str + "\t%.2f%%\t%.2f%%"%(AtoG_all_ratio*100, GtoA_AtoG_ratio*100)
            if (AtoG_all_ratio > 0.95) and (GtoA_AtoG_ratio < 0.01):
                #print nmm
                return cluster_data_nmm_part
        else:
            AtoG_TtoC_all_ratio = float(nmm_count['AtoG'] + nmm_count['TtoC']) / total_snv
            GtoA_AtoG_ratio = float(nmm_count['GtoA']) / nmm_count['AtoG']
            print res_str + "\t%.2f%%\t%.2f%%"%(AtoG_TtoC_all_ratio*100, GtoA_AtoG_ratio*100)
            if (AtoG_TtoC_all_ratio > 0.95) and (GtoA_AtoG_ratio < 0.01):
                #print sum(nmm_count.values())
                #print nmm
                return cluster_data_nmm_part
        
        nmm += 1
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
    #parser.add_argument('-l', '--print_log', action='store_true')
    parser.add_argument('-s', '--strand_specific', action='store_true')
    parser.add_argument('-o', '--output', type=str, help='The output filename. If there is no output filename assigned, the result will print into stdout.')
    parser.add_argument('cluster_data', type=str, help='cluster data')
    args = parser.parse_args()

    result = cluster_nmm(readTSV(args.cluster_data), args.strand_specific)

    if args.output:
        if result != None:
            writeTSV(result, args.output)
    else:
        printTSV(result)






if __name__ == "__main__":
    main()











