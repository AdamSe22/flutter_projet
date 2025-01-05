from flask import Flask, request, jsonify
from flask_cors import CORS
from transformers import MBartForConditionalGeneration, MBart50TokenizerFast
import torch
from transformers import AutoModelForSpeechSeq2Seq, AutoProcessor, pipeline
from pydub import AudioSegment
import numpy as np
from pymongo import MongoClient,DESCENDING

# Connect to MongoDB (without SSL)
client = MongoClient('mongodb://localhost:27017/')

# Select the database
db = client['Translate']

# Select the collection
collection = db['Translate_Api']


# Charger le modèle de traduction
model = MBartForConditionalGeneration.from_pretrained("facebook/mbart-large-50-many-to-many-mmt")
tokenizer = MBart50TokenizerFast.from_pretrained("facebook/mbart-large-50-many-to-many-mmt")

# Charger le modèle Whisper
device = "cuda:0" if torch.cuda.is_available() else "cpu"

torch_dtype = torch.float16 if torch.cuda.is_available() else torch.float32
speech_model = AutoModelForSpeechSeq2Seq.from_pretrained("openai/whisper-large-v2", torch_dtype=torch_dtype, low_cpu_mem_usage=True)
speech_model.to(device)


# Charger le processeur pour la reconnaissance vocale
processor = AutoProcessor.from_pretrained("openai/whisper-large-v2")

# Configurer le pipeline de reconnaissance vocale
pipe = pipeline(
    "automatic-speech-recognition",
    model=speech_model,
    tokenizer=processor.tokenizer,
    feature_extractor=processor.feature_extractor,
    torch_dtype=torch_dtype,
    device=device,
)

app = Flask(__name__)
CORS(app)

# Fonction de traduction
def translate(text, source_lang, target_lang):
    tokenizer.src_lang = source_lang
    encoded = tokenizer(text, return_tensors="pt")
    generated_tokens = model.generate(**encoded, forced_bos_token_id=tokenizer.lang_code_to_id[target_lang])
    return tokenizer.batch_decode(generated_tokens, skip_special_tokens=True)[0]

@app.route('/translate', methods=['POST'])
def translate_text():
    data = request.get_json()
    text = data.get("text")
    source_lang = data.get("source_lang")
    target_lang = data.get("target_lang")
    translated_text = translate(text, source_lang, target_lang)
    document = {
        "source_lang": source_lang,
        "target_lang": target_lang,
        "text": text,
        "translated_text": translated_text
    }
    collection.insert_one(document)
    return jsonify({"translated_text": translated_text})

@app.route('/translations', methods=['GET'])
def get_translations():
    documents = collection.find().sort('_id', DESCENDING).limit(3)
    translations = []
    for doc in documents:
        translations.append({
            "source_lang": doc['source_lang'],
            "target_lang": doc['target_lang'],
            "text": doc['text'],
            "translated_text": doc['translated_text']
        })
    return jsonify({"translations": translations})

@app.route('/transcribe', methods=['POST'])
def transcribe_audio():
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    audio = AudioSegment.from_file(file, format="wav")
    audio = audio.set_frame_rate(16000).set_channels(1)  # Ajuster à 16000 Hz, mono

    # Convertir en tableau numpy
    samples = np.array(audio.get_array_of_samples()).astype(np.float32) / 32768.0  # Normalisation [-1, 1]

    # Transcrire l'audio
    inputs = processor(samples, sampling_rate=16000, return_tensors="pt")
    with torch.no_grad():
        predicted_ids = speech_model.generate(inputs["input_features"].to(device))

    # Décoder la transcription
    transcription = processor.batch_decode(predicted_ids, skip_special_tokens=True)[0]
    return jsonify({"transcription": transcription})

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)