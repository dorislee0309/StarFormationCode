#grep -r "Total elapsed time:"  lev9_10_test*/test.*.out
declare -a arr=(1  24 48 120 240 360 480 720 960 1920 2400)
for nproc in "${arr[@]}"
  do
    echo $nproc
    #ls -d test$nproc/trunk/ramses/bin/output_0* | wc -l
  done
