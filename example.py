import gradio as gr
import requests
from requests.exceptions import HTTPError
import json
import re

def process(topic, progress=gr.Progress()):
    progress(0.2, desc="Generating Script")
    script = get_script(topic)
    
    progress(0.4, desc="Generating Image Prompts")
    image_prompts = get_image_prompts(script)
    print(image_prompts)
    images_loc = []
    for i,prompt in enumerate(image_prompts):
        progress(0.6, desc="Generating Image #"+str(i+1))
        #images_loc.append(get_images(prompt))
        get_images(prompt,i+1)

    progress(1, desc="Done!")
    return "Done"

def get_script(topic):
    url = "http://localhost:11434/api/generate"
    payload = json.dumps({
        "model": "es:latest",
        "prompt": f"Write a short 30 second essay on the topic - {topic}",
	    "stream": False
    })

    headers = {
        'Content-Type': 'application/json'
    }

    try:
        result = requests.request("POST", url, headers=headers, data=payload)
        result_json = result.json()
        return result_json['response']
    except HTTPError as http_err:
        print(f'HTTP error occurred: {http_err}')
    except Exception as err:
        print(f'Other error occurred: {err}')

def get_image_prompts(script):
    url = "http://localhost:11434/api/generate"
    payload = json.dumps({
        "model": "sd:latest",
        "prompt": f"Write 5 Image Prompts based on the following Natural Language Summary - {script}",
	    "stream": False
    })

    headers = {
        'Content-Type': 'application/json'
    }

    try:
        result = requests.request("POST", url, headers=headers, data=payload)
        result_json = result.json()
        #print(result_json['response'])
        result_pruned = result_json['response'].strip().replace("\"","'")
        result_pruned = re.sub(r"(\d[.)]\s)", "", result_pruned)
        result_pruned = result_pruned.splitlines()
        result_pruned = list(filter(None, result_pruned))
        return result_pruned
    except HTTPError as http_err:
        print(f'HTTP error occurred: {http_err}')
    except Exception as err:
        print(f'Other error occurred: {err}')

def get_images(prompt, i):
    prompt_text = """
    {
        "4": {
            "inputs": {
            "ckpt_name": "sd_xl_base_1.0.safetensors"
            },
            "class_type": "CheckpointLoaderSimple"
        },
        "5": {
            "inputs": {
            "width": 1024,
            "height": 1024,
            "batch_size": 1
            },
            "class_type": "EmptyLatentImage"
        },
        "6": {
            "inputs": {
            "text": "",
            "clip": [
                "4",
                1
            ]
            },
            "class_type": "CLIPTextEncode"
        },
        "7": {
            "inputs": {
            "text": "text, watermark",
            "clip": [
                "4",
                1
            ]
            },
            "class_type": "CLIPTextEncode"
        },
        "10": {
            "inputs": {
            "add_noise": "enable",
            "noise_seed": 721897303308196,
            "steps": 25,
            "cfg": 8,
            "sampler_name": "euler",
            "scheduler": "normal",
            "start_at_step": 0,
            "end_at_step": 20,
            "return_with_leftover_noise": "enable",
            "model": [
                "4",
                0
            ],
            "positive": [
                "6",
                0
            ],
            "negative": [
                "7",
                0
            ],
            "latent_image": [
                "5",
                0
            ]
            },
            "class_type": "KSamplerAdvanced"
        },
        "11": {
            "inputs": {
            "add_noise": "disable",
            "noise_seed": 0,
            "steps": 25,
            "cfg": 8,
            "sampler_name": "euler",
            "scheduler": "normal",
            "start_at_step": 20,
            "end_at_step": 10000,
            "return_with_leftover_noise": "disable",
            "model": [
                "12",
                0
            ],
            "positive": [
                "15",
                0
            ],
            "negative": [
                "16",
                0
            ],
            "latent_image": [
                "10",
                0
            ]
            },
            "class_type": "KSamplerAdvanced"
        },
        "12": {
            "inputs": {
            "ckpt_name": "sd_xl_refiner_1.0.safetensors"
            },
            "class_type": "CheckpointLoaderSimple"
        },
        "15": {
            "inputs": {
            "text": "",
            "clip": [
                "12",
                1
            ]
            },
            "class_type": "CLIPTextEncode"
        },
        "16": {
            "inputs": {
            "text": "text, watermark",
            "clip": [
                "12",
                1
            ]
            },
            "class_type": "CLIPTextEncode"
        },
        "17": {
            "inputs": {
            "samples": [
                "11",
                0
            ],
            "vae": [
                "12",
                2
            ]
            },
            "class_type": "VAEDecode"
        },
        "19": {
            "inputs": {
            "filename_prefix": "",
            "images": [
                "17",
                0
            ]
            },
            "class_type": "SaveImage"
        }
    }
    """
    prompt_json = json.loads(prompt_text)
    #set the text prompt for our positive CLIPTextEncode
    prompt_json["6"]["inputs"]["text"] = prompt
    prompt_json["15"]["inputs"]["text"] = prompt
    prompt_json["19"]["inputs"]["filename_prefix"] = "ComfyUI_SDXL_"+str(i)
    #Benefits of drinking coffee
    p = {"prompt": prompt_json}
    payload = json.dumps(p).encode('utf-8')

    url = "http://localhost:8188/prompt"
    headers = {
        'Content-Type': 'application/json'
    }
    result = requests.request("POST", url, headers=headers, data=payload)
    result_json = result.json()
    print(result_json)

def merge_video():
    pass #3000

demo = gr.Interface(process, gr.Textbox(lines=1, placeholder="Benefits of drinking coffee"), gr.Text())
demo.launch()