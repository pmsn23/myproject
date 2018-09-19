from flask import Flask
from flask_pymongo import PyMongo
from flask_restplus import Api, Resource, fields

app = Flask(__name__)
api = Api(app, version='1.0', title='Twitter-Mongo Api', description='An Api for Twitter Stream')

app.config['MONGO_DBNAME'] = 'twitterdb'
app.config['MONGO_URI'] = 'mongodb://localhost:27017/twitterdb'

mongo = PyMongo(app)

# Get all tweets by sentiment
@api.route('/tweetby/<sentiment>')
class tbsen(Resource):
    def get(self,sentiment):
        tweet = mongo.db.twitter_search
        output = []
        for t in tweet.find({'Sentiment': sentiment}):
            output.append({'Text' : t['Text'], 'Location': t['Location'], 'Sentiment': t['Sentiment'], 'Value': t['SentimentValue']})
        return output

# Get all tweets by SentimentValue Greater than or equal
@api.route('/tweet_by/<value>')
class tbsval(Resource):
    def get(self, value):
        tweet = mongo.db.twitter_search
        output = []
        for t in tweet.find({'SentimentValue': {"$gte": value}}):
            output.append({'Text' : t['Text'], 'Location': t['Location'], 'Sentiment': t['Sentiment'], 'Value': t['SentimentValue']})
        return output

# Get one tweet by location
@api.route('/tweet/<location>')
class tweet(Resource):
    def get(self, location):
        tweet = mongo.db.twitter_search
        output = []
        t = tweet.find_one({'Location': location})
        if t:
            output = {'Name': t['Username'], 'Text' : t['Text'], 'Location': t['Location']}
        else:
            output = 'No Results Found'
        return output

# Get all tweets User and Text
@api.route('/tweet')
class AllTweets(Resource):
    def get(self):
        tweet = mongo.db.twitter_search    
        output = []
        for t in tweet.find():
            output.append({'Name' : t['Username'], 'Text' : t['Text']})
        return output

if __name__ == '__main__':
    app.run(debug=True)