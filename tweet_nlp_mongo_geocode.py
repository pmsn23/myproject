from __future__ import print_function
import tweepy
import json
from pymongo import MongoClient
from pycorenlp import StanfordCoreNLP
import datetime
import geocoder

# Require Java8 and StanfordCoreNLP
# Below comment to start NLP server
# java -mx4g -cp "*" edu.stanford.nlp.pipeline.StanfordCoreNLPServer -annotators "tokenize,ssplit,pos,lemma,parse,sentiment" -port 9000 -timeout 30000

nlp = StanfordCoreNLP('http://localhost:9000')
 
MONGO_HOST= 'mongodb://localhost/twitterdb'  # assuming you have mongoDB installed locally
                                             # and a database called 'twitterdb'
 
#WORDS = ['#bigdata', '#AI', '#datascience', '#machinelearning', '#ml', '#iot']

#WORDS = ['#hack', '#security', '#attack', '#network', '#integrity', '#availablity', '#confidentiality']

#WORDS = ['#jerry', '#seinfeld', '#elaine', '#george', '#kramer']

WORDS = ['#trump','#donaldtrump']

CONSUMER_KEY = ""
CONSUMER_SECRET = ""
ACCESS_TOKEN = ""
ACCESS_TOKEN_SECRET = ""
  
class StreamListener(tweepy.StreamListener):    
    #This is a class provided by tweepy to access the Twitter Streaming API. 
 
    def on_connect(self):
        # Called initially to connect to the Streaming API
        print("You are now connected to the streaming API.")
 
    def on_error(self, status_code):
        # On error - if an error occurs, display the error / status code
        print('An Error has occured: ' + repr(status_code))
        return False
 
    def on_data(self, data):
        #This is the meat of the script...it connects to your mongoDB and stores the tweet
        try:
            client = MongoClient(MONGO_HOST)
            
            # Use twitterdb database. If it doesn't exist, it will be created.
            db = client.twitterdb
    
            # Decode the JSON from Twitter
            datajson = json.loads(data)
            
            #grab the 'created_at' data from the Tweet to use for display
            created_at = datajson['created_at']
            
            # Pull important data from the tweet to store in the database.
            tweet_id = datajson['id_str']  # The Tweet ID from Twitter in string format
            username = datajson['user']['screen_name']  # The username of the Tweet author
            followers = datajson['user']['followers_count']  # The number of followers the Tweet author has
            text = datajson['text']  # The entire body of the Tweet
            hashtags = datajson['entities']['hashtags']  # Any hashtags used in the Tweet
            dt = datajson['created_at']  # The timestamp of when the Tweet was created
            language = datajson['lang']  # The language of the Tweet
            location = datajson['user']['location'] # User Location
            coordinates = datajson['coordinates'] # geographic location of this Tweet
            place = datajson['place'] # indicates that the tweet is associated
            
            created = datetime.datetime.strptime(dt, '%a %b %d %H:%M:%S +0000 %Y')
            
            # Python 2.7 require encoding.
            #encoded_text = text.encode("ascii", "ignore")
            
            res = nlp.annotate(text, 
                        properties={
                       'annotators': 'sentiment',
                       'outputFormat': 'json',
                       'timeout': 1000,
                   })
            # get geo location from twitter attribute location
            
            latlng=[]
            if location is None:
                pass
            else:
                encoded_location = location.encode("ascii", "ignore")
                g = geocoder.google(encoded_location)
                if g.ok:
                    latlng = g.latlng
            
            for s in res["sentences"]:
                tweet = {'ID':tweet_id, 
                         'Username':username, 
                         'Followers':followers, 
                         'Text':text, 
                         'Hashtags':hashtags, 
                         'Language':language, 
                         'Location':location,
                         'Created':created, 
                         'SentimentValue': s['sentimentValue'],
                         'Sentiment': s['sentiment'],
                         'Coordinates': coordinates,
                         'Place':place,
                         'lat_lng': latlng
                        }
            
            #print out a message to the screen that we have collected a tweet
            print("Tweet collected at " + str(created_at))
            
            #insert the data into the mongoDB into a collection called twitter_search
            #if twitter_search doesn't exist, it will be created.
            db.twitter_search.insert(tweet)
        except Exception as e:
           print(e)
 
auth = tweepy.OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)
auth.set_access_token(ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
#Set up the listener. The 'wait_on_rate_limit=True' is needed to help with Twitter API rate limiting.
listener = StreamListener(api=tweepy.API(wait_on_rate_limit=True)) 
streamer = tweepy.Stream(auth=auth, listener=listener)
print("Tracking: " + str(WORDS))
streamer.filter(track=WORDS)