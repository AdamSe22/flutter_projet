import torch
from transformers import AutoModelForSpeechSeq2Seq, AutoProcessor, pipeline
from pydub import AudioSegment
import numpy as np

# Configurer le dispositif d'exécution (GPU ou CPU)
device = "cuda:0" if torch.cuda.is_available() else "cpu"
torch_dtype = torch.float16 if torch.cuda.is_available() else torch.float32

# Charger le modèle Whisper
model = AutoModelForSpeechSeq2Seq.from_pretrained("openai/whisper-large-v2", torch_dtype=torch_dtype, low_cpu_mem_usage=True)
model.to(device)

# Charger le processeur pour la reconnaissance vocale
processor = AutoProcessor.from_pretrained("openai/whisper-large-v2")

# Configurer le pipeline de reconnaissance vocale
pipe = pipeline(
    "automatic-speech-recognition",
    model=model,
    tokenizer=processor.tokenizer,
    feature_extractor=processor.feature_extractor,
    torch_dtype=torch_dtype,
    device=device,
)

# Charger un fichier audio .m4a et le convertir en tableau compatible
audio_file = r'D:\Emsi\5 em\Flutter\Projet\flutter_projet\Translate_API\Enregistrement.m4a'  # Mettez à jour le chemin du fichier audio
audio = AudioSegment.from_file(audio_file, format="m4a")
audio = audio.set_frame_rate(16000).set_channels(1)  # Ajuster à 16000 Hz, mono

# Convertir en tableau numpy
samples = np.array(audio.get_array_of_samples()).astype(np.float32) / 32768.0  # Normalisation [-1, 1]

# Transcrire l'audio
inputs = processor(samples, sampling_rate=16000, return_tensors="pt")
with torch.no_grad():
    predicted_ids = model.generate(inputs["input_features"].to(device))

# Décoder la transcription
transcription = processor.batch_decode(predicted_ids, skip_special_tokens=True)[0]
print("Transcription :", transcription)
