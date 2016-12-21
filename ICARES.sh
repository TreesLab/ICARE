#! /usr/bin/env bash

# version: 0.6.2

if [ "$#" -ne "5" ];then
	echo 'Usage:'
	echo '  ./ICARES.sh [SAMPLE_LIST] [GENE_REGION] [MEF_FILE] [WORK_SPACE] [Conserved?(Yes/No)]'
	echo '  (The multi-sample support will not be used when the "Conserved" option is set to "Yes".)'
	exit 0
fi

if [ "$(echo $0 | grep -o '\/')" = "" ]; then
    bin='./bin'
else
    bin=$(echo $0 | sed 's/\/[^/]*$//g')"/bin"
fi

function RDD(){
    cat $1 | awk '{
    if (($4=="A" || $4=="a") && $14>0 && $15==0 && $16==0)  
        print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\tAtoC";  
    else if (($4=="A" || $4=="a") && $15>0 && $14==0 &&$16==0)  
        print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\tAtoG";  
    else if (($4=="A" || $4=="a") && $16>0 && $14==0 && $15==0)  
        print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\tAtoT";  
    else if (($4=="C" || $4 =="c") && $13>0 && $15==0 && $16==0)  
        print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\tCtoA";  
    else if (($4=="C" || $4=="c") && $15>0 && $13==0 && $16==0)  
        print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\tCtoG";  
    else if (($4=="C" || $4=="c") && $16>0 && $15==0 &&$13==0)  
        print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\tCtoT";  
    else if (($4=="G" || $4=="g") && $13>0 && $14==0 && $16==0)  
        print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\tGtoA";  
    else if (($4=="G" || $4 =="g") && $14>0 && $13==0 && $16==0)  
        print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\tGtoC";  
    else if (($4=="G" || $4=="g") && $16>0 && $14==0 && $13==0)  
        print$1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\tGtoT";  
    else if (($4=="T" || $4=="t") && $13>0 && $14==0 && $15==0)  
        print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\tTtoA";  
    else if (($4=="T" || $4=="t") && $14>0 && $13==0 && $15==0)  
        print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\tTtoC";  
    else if (($4=="T" || $4 =="t") && $15>0 && $14==0 && $13==0)  
        print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\tTtoG";  
    else  
        print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\tBAD"}'
}

mkdir -p $4

##
for sample in $(cat $1)
do
    sample_name=$(echo $sample | sed "s/.*\///g")
    $bin/SiteQ $sample -i $2 $4"/"$sample_name".preRDD" 2>> $4/tmp.log
    RDD $4"/"$sample_name".preRDD" > $4"/"$sample_name".RDD"
    cat $4"/"$sample_name".RDD" | grep 'BAD' -v > $4"/"$sample_name".RDD.noBAD"
    cat $4"/"$sample_name".RDD.noBAD" | cut -f '1,2,3,14,16' | sort | uniq > $4"/"$sample_name".RDD.noBAD.uniq"
    cat $4"/"$sample_name".RDD.noBAD.uniq" | awk -F'\t' '($4=="+")' > $4"/"$sample_name".RDD.noBAD.uniq.positive"
    cat $4"/"$sample_name".RDD.noBAD.uniq" | awk -F'\t' '($4=="-")' > $4"/"$sample_name".RDD.noBAD.uniq.minus"
    $bin/SiteQ $4"/"$sample_name".RDD.noBAD.uniq.positive" -s $4"/"$sample_name".RDD.noBAD.uniq.positive" -c $4"/"$sample_name".RDD.noBAD.uniq.positive.counter" 2>> $4/tmp.log
    $bin/SiteQ $4"/"$sample_name".RDD.noBAD.uniq.minus" -s $4"/"$sample_name".RDD.noBAD.uniq.minus" -c $4"/"$sample_name".RDD.noBAD.uniq.minus.counter" 2>> $4/tmp.log
    cat $4"/"$sample_name".RDD.noBAD.uniq.positive.counter" | awk -F'\t' '($6==1)' | cut -f '1-5' > $4"/"$sample_name".RDD.noBAD.uniq.positive.counter.uniqlo"
    cat $4"/"$sample_name".RDD.noBAD.uniq.minus.counter" | awk -F'\t' '($6==1)' | cut -f '1-5' > $4"/"$sample_name".RDD.noBAD.uniq.minus.counter.uniqlo"
done

##
Con=`echo $5|awk '{ if ($1==x) print 0; else print 1;}' "x=Yes"`
cat $4"/"*.RDD.noBAD.uniq.positive.counter.uniqlo > $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo
cat $4"/"*.RDD.noBAD.uniq.minus.counter.uniqlo > $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo
$bin/SiteQ $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo -s $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo -c $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo.counter 2>> $4/tmp.log
$bin/SiteQ $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo -s $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo -c $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo.counter 2>> $4/tmp.log
cat $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo.counter | awk -F'\t' '($6>x)' "x=$Con"| cut -f '1-5' | sort | uniq > $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo.counter.mutiple_support
cat $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo.counter | awk -F'\t' '($6>x)' "x=$Con" | cut -f '1-5' | sort | uniq > $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo.counter.mutiple_support
$bin/SiteQ $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo.counter.mutiple_support -s $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo.counter.mutiple_support -c $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo.counter.mutiple_support.counter 2>> $4/tmp.log
$bin/SiteQ $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo.counter.mutiple_support -s $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo.counter.mutiple_support -c $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo.counter.mutiple_support.counter 2>> $4/tmp.log
cat $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo.counter.mutiple_support.counter | awk -F'\t' '($6==1)' | cut -f '1-5' > $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo.counter.mutiple_support.counter.single_snv
cat $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo.counter.mutiple_support.counter | awk -F'\t' '($6==1)' | cut -f '1-5' > $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo.counter.mutiple_support.counter.single_snv
cat $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo.counter.mutiple_support.counter.single_snv $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo.counter.mutiple_support.counter.single_snv | cut -f '1,2,3' | sort | uniq > $4"/"all_sample.RDD.noBAD.uniq.bothstrand.counter.uniqlo.counter.mutiple_support.counter.single_snv

##
for sample in $(cat $1)
do
    sample_name=$(echo $sample | sed "s/.*\///g")
    $bin/SiteQ $sample -s $4"/"all_sample.RDD.noBAD.uniq.bothstrand.counter.uniqlo.counter.mutiple_support.counter.single_snv $4"/"$sample_name".bothstrand_sites" 2>> $4/tmp.log
    cat $4"/"$sample_name".bothstrand_sites" | cut -f '1,2,3,10' | sed -r 's/[.,]//g' > $4"/"$sample_name".single"
    cat $4"/"$sample_name".bothstrand_sites" | awk -F'\t' '($17!=$18)' > $4"/"$sample_name".bothstrand_sites.btw0_100"
done

##
cat $4"/"*bothstrand_sites.btw0_100 | cut -f '1,2,3' | sort | uniq > $4"/"bothstrand_sites.btw0_100.sites
$bin/SiteQ $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo.counter.mutiple_support.counter.single_snv -s $4"/"bothstrand_sites.btw0_100.sites $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean 2>> $4/tmp.log
$bin/SiteQ $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo.counter.mutiple_support.counter.single_snv -s $4"/"bothstrand_sites.btw0_100.sites $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean 2>> $4/tmp.log
cat $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean | cut -f '1,2,3,5' | sort | uniq > $4"/"all_sample.RDD.noBAD.uniq.BOTH.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean
$bin/merge_bed.py $4"/"all_sample.RDD.noBAD.uniq.BOTH.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean $4"/"*.single -o $4"/"all_sample.RDD.noBAD.uniq.BOTH.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean.Thanda
cat $4"/"all_sample.RDD.noBAD.uniq.BOTH.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean.Thanda | grep 'toA' | sed "s/toA//g" | grep "a" | grep "A" > $4"/"all_sample.RDD.noBAD.uniq.BOTH.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean.Thanda.2strand3support.toA
cat $4"/"all_sample.RDD.noBAD.uniq.BOTH.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean.Thanda | grep 'toC' | sed "s/toC//g" | grep "c" | grep "C" > $4"/"all_sample.RDD.noBAD.uniq.BOTH.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean.Thanda.2strand3support.toC
cat $4"/"all_sample.RDD.noBAD.uniq.BOTH.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean.Thanda | grep 'toG' | sed "s/toG//g" | grep "g" | grep "G" > $4"/"all_sample.RDD.noBAD.uniq.BOTH.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean.Thanda.2strand3support.toG
cat $4"/"all_sample.RDD.noBAD.uniq.BOTH.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean.Thanda | grep 'toT' | sed "s/toT//g" | grep "t" | grep "T" > $4"/"all_sample.RDD.noBAD.uniq.BOTH.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean.Thanda.2strand3support.toT
cat $4"/"all_sample.RDD.noBAD.uniq.BOTH.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean.Thanda.2strand3support.to* | cut -f '1,2,3' > $4"/"all_sample.RDD.noBAD.uniq.BOTH.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean.Thanda.2strand3support
$bin/SiteQ $4"/"all_sample.RDD.noBAD.uniq.positive.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean -s $4"/"all_sample.RDD.noBAD.uniq.BOTH.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean.Thanda.2strand3support $4"/"positive.clean.2strand3support 2>> $4/tmp.log
$bin/SiteQ $4"/"all_sample.RDD.noBAD.uniq.minus.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean -s $4"/"all_sample.RDD.noBAD.uniq.BOTH.counter.uniqlo.counter.mutiple_support.counter.single_snv.clean.Thanda.2strand3support $4"/"minus.clean.2strand3support 2>> $4/tmp.log

##
for sample in $(cat $1)
do
    sample_name=$(echo $sample | sed "s/.*\///g")
    $bin/SiteQ $4"/"$sample_name".RDD" -s $4"/"positive.clean.2strand3support $4"/"$sample_name".RDD.positive.clean.2strand3support" 2>> $4/tmp.log
    $bin/SiteQ $4"/"$sample_name".RDD" -s $4"/"minus.clean.2strand3support $4"/"$sample_name".RDD.minus.clean.2strand3support" 2>> $4/tmp.log
    cat $4"/"$sample_name".RDD.positive.clean.2strand3support" | cut -f '1,2,3,14,16' | grep '+' | sort | uniq > $4"/"$sample_name".RDD.positive.clean.2strand3support.tmp"
    cat $4"/"$sample_name".RDD.minus.clean.2strand3support" | cut -f '1,2,3,14,16' | grep '-' | sort | uniq > $4"/"$sample_name".RDD.minus.clean.2strand3support.tmp"
done

##
cat $4"/"*RDD.positive.clean.2strand3support | cut -f '1,2,3,14,15' | grep '+' | sort | uniq > $4"/"positive_tmp.preThanda
cat $4"/"*RDD.minus.clean.2strand3support | cut -f '1,2,3,14,15' | grep '-' | sort | uniq > $4"/"minus_tmp.preThanda
$bin/merge_column.py $4"/"positive_tmp.preThanda -o $4"/"positive_tmp.Thanda
$bin/merge_column.py $4"/"minus_tmp.preThanda -o $4"/"minus_tmp.Thanda
$bin/SiteQ $4"/"positive_tmp.Thanda -s $3 -c $4"/"positive_tmp.Thanda.MEFcounter 2>> $4/tmp.log
$bin/SiteQ $4"/"minus_tmp.Thanda -s $3 -c $4"/"minus_tmp.Thanda.MEFcounter 2>> $4/tmp.log
cat $4"/"positive_tmp.Thanda.MEFcounter | awk -F'\t' '($7==0)' | cut -f '1-6' > $4"/"positive_tmp.Thanda.MEFok
cat $4"/"minus_tmp.Thanda.MEFcounter | awk -F'\t' '($7==0)' | cut -f '1-6' > $4"/"minus_tmp.Thanda.MEFok

##
for sample in $(cat $1)
do
    sample_name=$(echo $sample | sed "s/.*\///g")
    $bin/SiteQ $4"/"$sample_name".RDD.positive.clean.2strand3support.tmp" -s $4"/"positive_tmp.Thanda.MEFok $4"/"$sample_name".RDD.positive.clean.2strand3support.MEFok.sites" 2>> $4/tmp.log
    $bin/SiteQ $4"/"$sample_name".RDD.minus.clean.2strand3support.tmp" -s $4"/"minus_tmp.Thanda.MEFok $4"/"$sample_name".RDD.minus.clean.2strand3support.MEFok.sites" 2>> $4/tmp.log
    cat $4"/"$sample_name".RDD.positive.clean.2strand3support.MEFok.sites" | grep "BAD" -v | awk -F'\t' '{print $1"\t"$2"\t"$3"\t"$4"\t"$9"\t"$10"\t"$5}' > $4"/"$sample_name".RDD.positive.clean.2strand3support.MEFok.noBAD.sites"
    cat $4"/"$sample_name".RDD.minus.clean.2strand3support.MEFok.sites" | grep "BAD" -v | awk -F'\t' '{print $1"\t"$2"\t"$3"\t"$4"\t"$9"\t"$10"\t"$5}' > $4"/"$sample_name".RDD.minus.clean.2strand3support.MEFok.noBAD.sites"
done

##
cat $(cat $1 | sed "s/.*\///g" | sed -r "s/(.+)/\/\1.RDD.minus.clean.2strand3support.MEFok.noBAD.sites\n\/\1.RDD.positive.clean.2strand3support.MEFok.noBAD.sites/g"|sed 's/\///g'|awk '{print x"/"$1}' "x=$4")|sort -k1,1 -k2,2n -k3,3n | uniq > $4"/""all_MEFok.sort"
$bin/SiteQ $4"/""all_MEFok.sort" -s $4"/""all_MEFok.sort" -c $4"/""all_MEFok.sort.SiteQ_counter" 2>> $4/tmp.log
cat $4"/""all_MEFok.sort.SiteQ_counter" | awk -F'\t' '($8==1)||(($4=="+")&&(($7=="AtoG")||($7=="CtoT")))||(($4=="-")&&(($7=="TtoC")||($7=="GtoA")))' | cut -f '1-7' > $4"/""all_MEFok.sort.clean"

##
cat $4"/""all_MEFok.sort.clean" | awk -F'\t' '($4=="+")' > $4"/""all_MEFok.sort.positive"
cat $4"/""all_MEFok.sort.clean" | awk -F'\t' '($4=="-")' > $4"/""all_MEFok.sort.minus"

##
$bin/clustering.py $4"/""all_MEFok.sort.positive" -o $4"/""all_MEFok.sort.positive.clustering"
$bin/clustering.py $4"/""all_MEFok.sort.minus" -rev -o $4"/""all_MEFok.sort.minus.clustering"

##
cat $4"/""all_MEFok.sort.positive.clustering" $4"/""all_MEFok.sort.minus.clustering" | awk -F'\t' '($12!="")' | sort -k1,1 -k2,2n -k3,3n > $4"/""all_MEFok.sort.all.clustering"

## 
$bin/clustering.py <(cut -f '1-7' $4"/""all_MEFok.sort.all.clustering") -o $4"/""all_MEFok.sort.all.clustering.re_clustering"

##
$bin/clustering_nmm.py $4"/""all_MEFok.sort.all.clustering.re_clustering" -o $4"/""all_MEFok.sort.all.clustering.re_clustering.nmm" > $4"/""nmm.log"
