# Copyright 2020, Salesforce.com, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import json
import os
import re
import random

import lxml
from lxml import etree

import argparse

def convertToXML(string: str):
    try:
        return etree.fromstring(string)
    except:
        return None

def matchXML(trans: lxml.etree._Element,
             gold: lxml.etree._Element):
    if trans.tag != gold.tag:
        return False

    trans = list(trans.iterchildren())
    gold = list(gold.iterchildren())

    if len(trans) != len(gold):
        return False

    for (t, g) in zip(trans, gold):
        if not matchXML(t, g):
            return False

    return True

def notcontainsEMPTY(trans: lxml.etree._Element):
    # print(trans.tag, trans.text)
    if trans.text is None:
        return False

    trans = list(trans.iterchildren())
    
    
    for t in trans:
        if not notcontainsEMPTY(t):
            return False

    return True

def getattribtags(trans: lxml.etree._Element):
    # print(trans)
    translist = list(trans.iterchildren())
    # print(translist)
    # print(len(translist) == 0, trans.text is None)
    if len(translist) == 0 and trans.text is None:
        # print("1")
        attrs = (" ".join([i+"=\""+j+"\""+" " for i,j in trans.attrib.iteritems()])).strip()
        if attrs != "": 
            return ["<" + trans.tag + " " + attrs +"/>"]
        else:
            return []
    elif len(translist) == 0 and trans.text is not None:
        # print("2")
        return []
    else:
        # print("3")
        final = []
        for t in translist:
            final += getattribtags(t)
        return final

eng_regex = r'[.,\'/:a-zA-Z$]*[A-Z]+[.,\'/:a-zA-Z$]*'
num_regex = r'[0-9.,\'/:]*[0-9]+[0-9.,\'/:]*'
def num_tech_eval(translation: str,
                  target: str,
                  total_trans: int,
                  total_gold: int,
                  correct_trans: int,
                  correct_gold: int,
                  english_term: list):
    
    trans_num = re.findall(num_regex, translation)
    gold_num = re.findall(num_regex, target)

    trans_english_term = []
    gold_english_term = []

    for elm in re.findall(eng_regex, translation):
        if elm in english_term:
            trans_english_term.append(elm)
    for elm in re.findall(eng_regex, target):
        if elm in english_term:
            gold_english_term.append(elm)

    trans = trans_num+trans_english_term
    gold = gold_num+gold_english_term

    total_trans += len(trans)
    total_gold += len(gold)

    def convert(list):
        res = set()
        check = {}

        for n in list:
            if n in check:
                index = check[n]
            else:
                index = 1
            res.add(n+'__'+str(index))
            check[n] = index+1

        return res

    trans = convert(trans)
    gold = convert(gold)

    for n in trans:
        if n in gold:
            correct_trans += 1

    for n in gold:
        if n in trans:
            correct_gold += 1

    return total_trans, correct_trans, total_gold, correct_gold

def de_escape(string: str):
    string = string.replace('&amp;', '&')
    string = string.replace('&lt;', '<')
    string = string.replace('&gt;', '>')
    return string

def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("--target",
                        default="",
                        type=str,
                        required=True,
                        help="JSON file path to the target (reference) text")

    parser.add_argument("--translation",
                        default="",
                        type=str,
                        required=True,
                        help="JSON file path to the translation text")

    parser.add_argument("--english_term",
                        default="",
                        type=str,
                        required=False,
                        help="JSON file path to English terms for the entity evaluation")

    parser.add_argument("--lang",
                        default="",
                        type=str,
                        help="The language in case input files are sentence level files")

    parser.add_argument("--is_sent",
                        action='store_true',
                        help="Do we have json input files or sentence level files?")
    
    args = parser.parse_args()

    assert os.path.exists(args.target)
    assert os.path.exists(args.translation)

    if args.is_sent:
        jsn_target = {"lang":args.lang, "type":"target", "text":{}}
        jsn_translation = {"lang":args.lang, "type":"translation", "text":{}}
        
        for idx, line in enumerate(open(args.target, 'r')):
            jsn_target["text"][idx] = line.strip()

        for idx, line in enumerate(open(args.translation, 'r')):
            jsn_translation["text"][idx] = line.strip()
    else:
        jsn_target = json.load(open(args.target, 'r'))
        jsn_translation = json.load(open(args.translation, 'r'))

    if os.path.exists(args.english_term):
        english_term = json.load(open(args.english_term, 'r'))
        english_term = set(english_term)

        total_trans = 0
        total_gold = 0
        correct_trans = 0
        correct_gold = 0
    else:
        english_term = None
        
    assert jsn_target['lang'] == jsn_translation['lang']
    lang = jsn_target['lang']

    assert jsn_target['type'] == 'target'
    assert jsn_translation['type'] == 'translation'

    xml_acc = 0
    xml_match = 0

    tagTypeList = ['ph', 'xref', 'uicontrol', 'b', 'codeph', 'parmname', 'i', 'title',
                   'menucascade', 'varname', 'userinput', 'filepath', 'term',
                   'systemoutput', 'cite', 'li', 'ul', 'p', 'note', 'indexterm', 'u', 'fn']
    tagTypeList +=  ["sap-icon-font-character", "i", "sap-technical-name", "uinolabel", "pname", "sap-icon-font-description", "key", "uicontrol", "cite", "xref", "field", "shipped_quantity", "q", "alt", "sap-icon-font-size", "image", "emphasis", "userinput", "dg_basic_description", "sap-icon-font", "menucascade", "sap-icon-background-color", "name", "sap-icon-font-color", "keys", "systemoutput"]
    tagBegList = ['<'+t+'>' for t in tagTypeList]
    tagEndList = ['</'+t+'>' for t in tagTypeList]
    tagList = tagBegList + tagEndList

    DUMMY = '####DUMMY###SEPARATOR###DUMMY###'

    suffix = str(random.randint(0, 100000000000000))
    assert not os.path.exists(suffix)
    os.mkdir(suffix)
    f_trans_without_tags = open(os.path.join(suffix, 'trans.txt'), 'w')
    f_trans_with_tags = open(os.path.join(suffix, 'trans_struct.txt'), 'w')
    f_gold_without_tags = open(os.path.join(suffix, 'gold.txt'), 'w')
    f_gold_with_tags = open(os.path.join(suffix, 'gold_struct.txt'), 'w')
    skippedcount=0
    unskippedcount=0
    examples_with_tags = 0
    examples_with_tags_matched = 0
    for target_id in jsn_target['text']:
        assert target_id in jsn_translation['text']

        target = jsn_target['text'][target_id].strip()
        translation = jsn_translation['text'][target_id].strip()
        # print(target, "###", translation)
            
        # XML structure evaluation
        xml_elm_target = convertToXML('<ROOT>{}</ROOT>'.format(target))
        xml_elm_translation = convertToXML('<ROOT>{}</ROOT>'.format(translation))
        # assert xml_elm_target is not None

        if xml_elm_target is None:
            # print("Erroneous sentence:", target)
            skippedcount+=1
            continue
        
        if len(list(xml_elm_target.iterchildren())) > 0: 
            examples_with_tags += 1
        
        # if not notcontainsEMPTY(xml_elm_target):
        #     print("Sentence with empty tags:", target)
        #     skippedcount+=1
        #     skipped_examples_with_tags+=1
        #     continue
        
        unskippedcount+=1

        match = False
        if xml_elm_translation is not None:
            xml_acc += 1

            if matchXML(xml_elm_translation, xml_elm_target):
                xml_match += 1
                match = True
                if len(list(xml_elm_target.iterchildren())) > 0:
                    examples_with_tags_matched += 1
            
                empty_tags_target = getattribtags(xml_elm_target)
                empty_tags_translation = getattribtags(xml_elm_translation)
        

        for tag in tagList:
            target = target.replace(tag, DUMMY)
            translation = translation.replace(tag, DUMMY)
        for tag in empty_tags_target:
            target = target.replace(tag, DUMMY)
        
        for tag in empty_tags_translation:
            translation = translation.replace(tag, DUMMY)
        target = de_escape(target)
        translation = de_escape(translation)

        target = target.split(DUMMY)
        translation = translation.split(DUMMY)
        
        # NE&NUM evaluation
        if english_term is not None:
            total_trans, correct_trans, total_gold, correct_gold = num_tech_eval(''.join(translation), ''.join(target),
                                                                                 total_trans, total_gold, correct_trans, correct_gold,
                                                                                 english_term)

        f_trans_without_tags.write(''.join(translation) + '\n')
        f_gold_without_tags.write(''.join(target) + '\n')

        # print(target, "###", translation)
        if match:
            # print(target, "###", translation)
            assert len(target) == len(translation)
            for i in range(len(target)):
                f_trans_with_tags.write(translation[i] + '\n')
                f_gold_with_tags.write(target[i] + '\n')
        else:
            for i in range(len(target)):
                f_trans_with_tags.write('\n')
                f_gold_with_tags.write(target[i] + '\n')            
                
    print('XML structure accuracy: {} %'.format(100*xml_acc/len(jsn_target['text'])))
    print('XML matching accuracy:  {} %'.format(100*xml_match/len(jsn_target['text'])))

    if english_term is not None:
        print('NE&NUM precision: {} %'.format(100*correct_trans/total_trans))
        print('NE&NUM recall:    {} %'.format(100*correct_gold/total_gold))

    f_trans_without_tags.close()
    f_trans_with_tags.close()
    f_gold_without_tags.close()
    f_gold_with_tags.close()

    os.system("./scripts/calc_bleu.sh {} {} 2> {}".format(lang, suffix, os.path.join(suffix, 'TMP')))
    
    f_trans = open(os.path.join(suffix, 'bleu.txt'), 'r')
    for line in f_trans:
        bleu = float(line.split()[2][0:-1])
        break
    f_trans.close()

    f_trans = open(os.path.join(suffix, 'bleu_struct.txt'), 'r')
    for line in f_trans:
        bleu_struct = float(line.split()[2][0:-1])
        break
    f_trans.close()

    totalcount = unskippedcount + skippedcount
    print("BLEU:", bleu)
    print("XML BLEU:", bleu_struct)
    print("Total examples skipped:", skippedcount, "out of", totalcount)
    print("Total tagged examples with matched structures:", examples_with_tags_matched, "out of", examples_with_tags)
    print("Total XML matches:", xml_match, "out of", len(jsn_target['text']))
    os.system('rm -r ./{}*'.format(suffix))
    
if __name__ == "__main__":
    main()
    
