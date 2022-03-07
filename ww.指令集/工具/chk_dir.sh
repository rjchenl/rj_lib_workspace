echo ==========start rj test ==============


path1_0=/log/UP0090_01
path1_1=/log/UP0090_01/log
path1_2=/log/UP0090_01/tx

path0_0=/log/UP0090_00
path0_1=/log/UP0090_00/log
path0_2=/log/UP0090_00/tx

path3_0=/log/UP0090_03
path3_1=/log/UP0090_03/log
path3_2=/log/UP0090_03/tx


chk_path(){
(cd $1)||(mkdir $1)
(cd $2)||(mkdir $2)
(cd $3)||(mkdir $3)
(cd $2 )&&( echo path:$2 exists)
(cd $3 )&&( echo path:$3 exists)
}


chk_path $path1_0 $path1_1 $path1_2
echo UP0090_01 chk finished

chk_path $path0_0 $path0_1 $path0_2
echo UP0090_00 chk finished

chk_path $path3_0 $path3_1 $path3_2
echo UP0090_03 chk finished


echo ===========end rj test================
