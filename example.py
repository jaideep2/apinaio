import gradio as gr
import requests
import json
import os

def process(topic):
    script = get_script(topic)
    return "Done"

def get_script(): pass #11434

def get_images(): pass #8188

def merge_video(): pass #3000

demo = gr.Interface(
    fn=process,
    inputs=["text"],
    outputs=["text"],
)
demo.launch()