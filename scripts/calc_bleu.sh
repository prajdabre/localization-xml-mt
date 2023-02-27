# Copyright 2020, Salesforce.com, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#!/bin/sh

##################################
###
# Added by anonymous@institution
###
### 
###


WAT_LOC=./tools/WAT-scripts/
KYTEA=./tools/local/bin/kytea
KYTEA_MODEL=./tools/kytea_models/

MOSES_TOK=./tools/mosesdecoder/scripts/tokenizer/tokenizer.perl

MULTI_BLEU=./tools/mosesdecoder/scripts/generic/multi-bleu.perl

L=${1}
LOC=${2}

T=trans.txt
G=gold.txt
T_S=trans_struct.txt
G_S=gold_struct.txt
 ## Use the segmenters I wrote for ja, zh and ko.

 
if [ ${L} = "ja" ]; then
    cat ${LOC}/${T} | sed -r 's/(@@ )|(@@ ?$)//g' | perl -C -pe 'use utf8; s/(.)［[０-９．]+］$/${1}/;' |sh ${WAT_LOC}/remove-space.sh |perl -C ${WAT_LOC}/h2z-utf8-without-space.pl | ${KYTEA} -model ${KYTEA_MODEL}/jp-0.4.2-utf8-1.mod -out tok | perl -C -pe 's/^ +//; s/ +$//; s/ +/ /g;' |perl -C -pe 'use utf8; while(s/([０-９]) ([０-９])/$1$2/g){} s/([０-９]) (．) ([０-９])/$1$2$3/g; while(s/([Ａ-Ｚ]) ([Ａ-Ｚａ-ｚ])/$1$2/g){} while(s/([ａ-ｚ]) ([ａ-ｚ])/$1$2/g){}' > ${LOC}/${T}.eval

    cat ${LOC}/${G} | sed -r 's/(@@ )|(@@ ?$)//g' | perl -C -pe 'use utf8; s/(.)［[０-９．]+］$/${1}/;' |sh ${WAT_LOC}/remove-space.sh |perl -C ${WAT_LOC}/h2z-utf8-without-space.pl | ${KYTEA} -model ${KYTEA_MODEL}/jp-0.4.2-utf8-1.mod -out tok | perl -C -pe 's/^ +//; s/ +$//; s/ +/ /g;' |perl -C -pe 'use utf8; while(s/([０-９]) ([０-９])/$1$2/g){} s/([０-９]) (．) ([０-９])/$1$2$3/g; while(s/([Ａ-Ｚ]) ([Ａ-Ｚａ-ｚ])/$1$2/g){} while(s/([ａ-ｚ]) ([ａ-ｚ])/$1$2/g){}' > ${LOC}/${G}.eval

    cat ${LOC}/${T_S} | sed -r 's/(@@ )|(@@ ?$)//g' | perl -C -pe 'use utf8; s/(.)［[０-９．]+］$/${1}/;' |sh ${WAT_LOC}/remove-space.sh |perl -C ${WAT_LOC}/h2z-utf8-without-space.pl | ${KYTEA} -model ${KYTEA_MODEL}/jp-0.4.2-utf8-1.mod -out tok | perl -C -pe 's/^ +//; s/ +$//; s/ +/ /g;' |perl -C -pe 'use utf8; while(s/([０-９]) ([０-９])/$1$2/g){} s/([０-９]) (．) ([０-９])/$1$2$3/g; while(s/([Ａ-Ｚ]) ([Ａ-Ｚａ-ｚ])/$1$2/g){} while(s/([ａ-ｚ]) ([ａ-ｚ])/$1$2/g){}' > ${LOC}/${T_S}.eval

    cat ${LOC}/${G_S} | sed -r 's/(@@ )|(@@ ?$)//g' | perl -C -pe 'use utf8; s/(.)［[０-９．]+］$/${1}/;' |sh ${WAT_LOC}/remove-space.sh |perl -C ${WAT_LOC}/h2z-utf8-without-space.pl | ${KYTEA} -model ${KYTEA_MODEL}/jp-0.4.2-utf8-1.mod -out tok | perl -C -pe 's/^ +//; s/ +$//; s/ +/ /g;' |perl -C -pe 'use utf8; while(s/([０-９]) ([０-９])/$1$2/g){} s/([０-９]) (．) ([０-９])/$1$2$3/g; while(s/([Ａ-Ｚ]) ([Ａ-Ｚａ-ｚ])/$1$2/g){} while(s/([ａ-ｚ]) ([ａ-ｚ])/$1$2/g){}' > ${LOC}/${G_S}.eval
    
    # python seg_ja.py ${LOC}/${T} > ${LOC}/${T}.eval
    # python seg_ja.py ${LOC}/${G} > ${LOC}/${G}.eval
    # python seg_ja.py ${LOC}/${T_S} > ${LOC}/${T_S}.eval
    # python seg_ja.py ${LOC}/${G_S} > ${LOC}/${G_S}.eval
    # cat ${2}/gold_orig.txt | sed -r 's/(@@ )|(@@ ?$)//g' | perl -C -pe 'use utf8; s/(.)［[０-９．]+］$/${1}/;' |sh ${WAT_LOC}/remove-space.sh  > ${2}/gold_orig_unspace.txt 
    
    # cat ${2}/gold_orig_unspace.txt | ./tools/mosesdecoder/scripts/training/strip-xml.perl > ${2}/gold_noxml.txt
    cat ${2}/gold_orig.txt | ./tools/mosesdecoder/scripts/training/strip-xml.perl > ${2}/gold_noxml.txt
    cat ${2}/trans_orig.txt | sed -r 's/(@@ )|(@@ ?$)//g' | perl -C -pe 'use utf8; s/(.)［[０-９．]+］$/${1}/;' |sh ${WAT_LOC}/remove-space.sh  > ${2}/trans_orig_unspace.txt 
    
    cat ${2}/trans_orig_unspace.txt | ./tools/mosesdecoder/scripts/training/strip-xml.perl > ${2}/trans_noxml.txt
    # ./tools/mosesdecoder/scripts/training/strip-xml.perl < ${2}/gold_orig.txt > ${2}/gold_noxml.txt
    # ./tools/mosesdecoder/scripts/training/strip-xml.perl < ${2}/trans_orig.txt > ${2}/trans_noxml.txt
    # echo "%%% Evaluation with SacreBLEU %%%"
    # python ./scripts/metrics.py \
    #     -hyp ${2}/trans_noxml.txt \
    #     -hypx ${2}/trans_orig_unspace.txt \
    #     -ref ${2}/gold_noxml.txt \
    #     -refx ${2}/gold_orig.txt \
    #     -t ${1} > ${2}/sacrebleu.txt


elif [ ${L} = "zh" ]; then
    cat ${LOC}/${T} | sh ${WAT_LOC}/remove-space.sh | perl -C ${WAT_LOC}/h2z-utf8-without-space.pl | ${KYTEA} -model ${KYTEA_MODEL}/msr-0.4.0-1.mod -out tok | perl -C -pe 's/^ +//; s/ +$//; s/ +/ /g;' > ${LOC}/${T}.eval

    cat ${LOC}/${G} | sh ${WAT_LOC}/remove-space.sh | perl -C ${WAT_LOC}/h2z-utf8-without-space.pl | ${KYTEA} -model ${KYTEA_MODEL}/msr-0.4.0-1.mod -out tok | perl -C -pe 's/^ +//; s/ +$//; s/ +/ /g;' > ${LOC}/${G}.eval

    cat ${LOC}/${T_S} | sh ${WAT_LOC}/remove-space.sh | perl -C ${WAT_LOC}/h2z-utf8-without-space.pl | ${KYTEA} -model ${KYTEA_MODEL}/msr-0.4.0-1.mod -out tok | perl -C -pe 's/^ +//; s/ +$//; s/ +/ /g;' > ${LOC}/${T_S}.eval

    cat ${LOC}/${G_S} | sh ${WAT_LOC}/remove-space.sh | perl -C ${WAT_LOC}/h2z-utf8-without-space.pl | ${KYTEA} -model ${KYTEA_MODEL}/msr-0.4.0-1.mod -out tok | perl -C -pe 's/^ +//; s/ +$//; s/ +/ /g;' > ${LOC}/${G_S}.eval
    
    # bash seg_zh.sh ${LOC}/${T} ${LOC}/${T}.eval
    # bash seg_zh.sh ${LOC}/${G} ${LOC}/${G}.eval
    # bash seg_zh.sh ${LOC}/${T_S} ${LOC}/${T_S}.eval
    # bash seg_zh.sh ${LOC}/${G_S} ${LOC}/${G_S}.eval
    ./tools/mosesdecoder/scripts/training/strip-xml.perl < ${2}/gold_orig.txt > ${2}/gold_noxml.txt
    ./tools/mosesdecoder/scripts/training/strip-xml.perl < ${2}/trans_orig.txt > ${2}/trans_noxml.txt
    # echo "%%% Evaluation with SacreBLEU %%%"
    # python ./scripts/metrics.py \
    #     -hyp ${2}/trans_noxml.txt \
    #     -hypx ${2}/trans_orig.txt \
    #     -ref ${2}/gold_noxml.txt \
    #     -refx ${2}/gold_orig.txt \
    #     -t ${1} > ${2}/sacrebleu.txt


elif [ ${L} = "ko" ]; then
    cat ${LOC}/${T} | sh ${WAT_LOC}/remove-space.sh > ${LOC}/${T}.tmp
    python scripts/seg_ko.py ${LOC}/${T}.tmp > ${LOC}/${T}.eval
    cat ${LOC}/${G} | sh ${WAT_LOC}/remove-space.sh > ${LOC}/${G}.tmp
    python scripts/seg_ko.py ${LOC}/${G}.tmp > ${LOC}/${G}.eval
    cat ${LOC}/${T_S} | sh ${WAT_LOC}/remove-space.sh > ${LOC}/${T_S}.tmp
    python scripts/seg_ko.py ${LOC}/${T_S}.tmp > ${LOC}/${T_S}.eval
    cat ${LOC}/${G_S} | sh ${WAT_LOC}/remove-space.sh > ${LOC}/${G_S}.tmp
    python scripts/seg_ko.py ${LOC}/${G_S}.tmp > ${LOC}/${G_S}.eval
    python seg_ko.py ${2}/gold_orig.txt | perl -C -pe 's/^ +//; s/ +$//; s/ +/ /g;' | sed -e "s/< /</g" -e "s/< \/ /<\//g" -e "s/ >/>/g" -e "s/ = \" /=\"/g" -e "s/<\/ /<\//g" -e "s/ \" \/>/\"\/>/g" -e "s/ \">/\">/g" -e "s/\"\"//g" | sed  "s/=\" /=\"/g"|  sed "s/ =\"/=\"/g" | sed "s/ \"\/>/\"\/>/g" | sed "s/ - /-/g" | sed "s/ \" /\" /g" > ${2}/gold_orig_tok.txt.tmp 
    python fixatts.py ${2}/gold_orig_tok.txt.tmp > ${2}/gold_orig_tok.txt
    python seg_ko.py ${2}/trans_orig.txt | perl -C -pe 's/^ +//; s/ +$//; s/ +/ /g;' | sed -e "s/< /</g" -e "s/< \/ /<\//g" -e "s/ >/>/g" -e "s/ = \" /=\"/g" -e "s/<\/ /<\//g" -e "s/ \" \/>/\"\/>/g" -e "s/ \">/\">/g" -e "s/\"\"//g" | sed  "s/=\" /=\"/g"|  sed "s/ =\"/=\"/g" | sed "s/ \"\/>/\"\/>/g" | sed "s/ - /-/g" | sed "s/ \" /\" /g" > ${2}/trans_orig_tok.txt.tmp 
    python fixatts.py ${2}/trans_orig_tok.txt.tmp > ${2}/trans_orig_tok.txt
    sleep 10
    ./tools/mosesdecoder/scripts/training/strip-xml.perl < ${2}/gold_orig_tok.txt > ${2}/gold_noxml.txt
    ./tools/mosesdecoder/scripts/training/strip-xml.perl < ${2}/trans_orig_tok.txt > ${2}/trans_noxml.txt
    # echo "%%% Evaluation with SacreBLEU %%%"
    # python ./scripts/metrics.py \
    #     -hyp ${2}/trans_noxml.txt \
    #     -hypx ${2}/trans_orig_tok.txt \
    #     -ref ${2}/gold_noxml.txt \
    #     -refx ${2}/gold_orig_tok.txt \
    #     -t ${1} > ${2}/sacrebleu.txt
    

else
    perl ${MOSES_TOK} -l ${L} < ${LOC}/${T} > ${LOC}/${T}.eval
    perl ${MOSES_TOK} -l ${L} < ${LOC}/${G} > ${LOC}/${G}.eval

    perl ${MOSES_TOK} -l ${L} < ${LOC}/${T_S} > ${LOC}/${T_S}.eval
    perl ${MOSES_TOK} -l ${L} < ${LOC}/${G_S} > ${LOC}/${G_S}.eval
    ./tools/mosesdecoder/scripts/training/strip-xml.perl < ${2}/gold_orig.txt > ${2}/gold_noxml.txt
    ./tools/mosesdecoder/scripts/training/strip-xml.perl < ${2}/trans_orig.txt > ${2}/trans_noxml.txt
    # echo "%%% Evaluation with SacreBLEU %%%"
    # python ./scripts/metrics.py \
    #     -hyp ${2}/trans_noxml.txt \
    #     -hypx ${2}/trans_orig.txt \
    #     -ref ${2}/gold_noxml.txt \
    #     -refx ${2}/gold_orig.txt \
    #     -t ${1} > ${2}/sacrebleu.txt

fi

perl ${MULTI_BLEU} ${LOC}/${G}.eval < ${LOC}/${T}.eval > ${LOC}/bleu.txt
perl ${MULTI_BLEU} ${LOC}/${G_S}.eval < ${LOC}/${T_S}.eval > ${LOC}/bleu_struct.txt

cat ${2}/sacrebleu.txt

echo "%%% Evaluation with multi-bleu %%%"