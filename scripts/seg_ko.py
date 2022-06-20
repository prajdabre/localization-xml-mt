import MeCab 
import sys
import mecab_ko_dic

infile=open(sys.argv[1])

tagger = MeCab.Tagger(mecab_ko_dic.MECAB_ARGS)

for i in infile:
	print(" ".join(tagger.parse(i.strip()).split()[:-1][0::2]))
