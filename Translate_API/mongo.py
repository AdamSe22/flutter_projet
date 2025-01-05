from pymongo import MongoClient,DESCENDING

# Connect to MongoDB (without SSL)
client = MongoClient('mongodb://localhost:27017/')

# Select the database
db = client['Translate']

# Select the collection
collection = db['Translate_Api']

# Insert a document into the collection
"""document = {"source_lang": "ar_Ar","target_lang": "en_En","text": "zz","translated_text": "zz"}
result = collection.insert_one(document)"""
"""
documents = collection.find()
for doc in documents:
    print(doc['source_lang'], doc['target_lang'], doc['text'], doc['translated_text'])"""
documents = collection.find().sort('_id', DESCENDING).limit(3)
translations = []
for doc in documents:
    translations.append({
        "source_lang": doc['source_lang'],
        "target_lang": doc['target_lang'],
        "text": doc['text'],
        "translated_text": doc['translated_text']
    })

# Afficher les traductions
for translation in translations:
    print(translation) 