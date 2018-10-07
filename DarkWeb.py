import sys
import _mysql
import MySQLdb as mdb
import re
from nltk.tokenize.toktok import ToktokTokenizer
from nltk.corpus import stopwords
import nltk
from textblob import TextBlob
import csv
#nltk.download('stopwords')


DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = ')sZp27wh*f'
DB_NAME = 'DMProduct'

tokenizer = ToktokTokenizer()
stopword_list = nltk.corpus.stopwords.words('english')
stopword_list.remove('no')
stopword_list.remove('not')

def retrieve_onebyone():

    con = mdb.connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME)
    
    with con:
        cur = con.cursor()
        sql = "SELECT description FROM dnm_dream"
        cur.execute(sql)

        numrows = int(cur.rowcount)
        WordList=[]
        for i in range(numrows):
            row = cur.fetchone()
            text = remove_special_characters(str(row),remove_digits=True)
            token = remove_stopwords(text)
            textblob = TextBlob(token).words
            WordList.append(textblob)
            print (i)
        
    with open("output.csv",'w') as resultFile:
        wr = csv.writer(resultFile, dialect='excel')
        wr.writerows(WordList)
    
def remove_special_characters(text, remove_digits=False):
    pattern = r'[^a-zA-z0-9\s]' if not remove_digits else r'[^a-zA-z\s]'
    text = re.sub(pattern, '', text)
    return text
    
def remove_stopwords(text, is_lower_case=False):
    tokens = tokenizer.tokenize(text)
    tokens = [token.strip() for token in tokens]
    if is_lower_case:
        filtered_tokens = [token for token in tokens if token not in stopword_list]
    else:
        filtered_tokens = [token for token in tokens if token.lower() not in stopword_list]
    filtered_text = ' '.join(filtered_tokens)    
    return filtered_text
    
if __name__ == '__main__':
    retrieve_onebyone()