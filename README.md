# APInAIo (Its a mouthful)

> **Warning**  
> In heavy development. Help needed!

Ready to use docker enviroments for rapid development in text2img, img2img, text2video img2video pipelines using [Ollama](https://github.com/jmorganca/ollama) + [ComfyUI](https://github.com/comfyanonymous/ComfyUI) + [ffmpeg](https://ffmpeg.lav.io/) Docker images

## Features

- Lots of [LLMs](https://ollama.ai/library) available.
- Easy to use and update [ComfyUI packages](https://github.com/WASasquatch/comfyui-plugins)
- GPU enabled [ffmpeg](https://www.ffmpeg.org/) for all encoding/decoding needs.

## Configure

- `./config/ollama/entrypoint.sh` for downloading models and serving via [API](https://ollama.ai/library)
- `./config/ollama/modelfiles` for defining [custom models](https://github.com/jmorganca/ollama/blob/main/docs/modelfile.md)
- `./config/comfyui/provisioning.sh` for provisioning comfyui and its API
- `./config/comfyui/models.csv` is used by above for downloading/updating custom models. SDXL and AnimateDiff models included, rename to models.csv for use.
- `./config/comfyui/nodes.csv` is used by above for downloading/updating custom nodes. SDXL and AnimateDiff nodes included, rename to nodes.csv for use.

## Quickstart

Rename template.env to .env and then launch containers one by one (recommended)

```bash
docker-compose up ollama-api -d
docker-compose up comfyui-api -d
docker-compose up ffmpeg-api -d
```

Once they are running you can bring all of them down

```bash
docker compose down
```

And bring everything up when needed

```bash
docker compose up -d
```

On tested on Python 3.10 / Pytorch 2.0.1, NVIDIA CUDA (WSL)

## Whats Included?

## Ollama-API

TODO Update Description

### API examples

Check all the available models

```bash
curl http://localhost:11434/api/tags
```

Use midjourney prompt generator model

```bash
curl -X POST http://localhost:11434/api/generate -d '{
  "model": "mj:latest",
  "prompt": "a sports car in the mountains.",
  "stream": false}'
```

View model information

```bash
http://localhost:11434/api/show -d '{
  "name": "mj:latest"
}'
```

## ComfyUI

> **Warning**  
> Runs as root.

GUI is visible on port 8188. I usually drag and drop my workflows directly on the browser.
If Drive space is scarce, change volume mounting point.

## FFmpeg

> **Warning**  
> Runs as root.

TODO Update Description

### Example usage

Convert mp4 to png

```bash
docker exec -it ffmpeg-api ffmpeg -y -hwaccel cuvid -c:v h264_cuvid -resize 576x1024 -i /output/Dancing.mp4 -vf "scale_npp=format=yuv420p,hwdownload,format=yuv420p" -pix_fmt yuvj420p -color_range 2 /output/frame_%03d.jpg
```

Convert png to jpg

```bash
docker exec -it ffmpeg-api /bin/bash -c 'for image in /output/*.png; do ffmpeg -i "$image" "${image%.png}.jpg"; rm "$image"; echo "image $image converted to ${image%.png}.jpg "; done'
```

Convert images to mp4 video

```bash
docker exec -it ffmpeg-api ffmpeg -y -loglevel error -i '/output/frame_%03d.jpg' -r 30 -c:v hevc_nvenc -pix_fmt yuv420p -preset fast /output/final.mp4
```

## Open Ports

Some ports need to be exposed for the services to run or for certain features of the provided software to function

| Open Ports            | Service / Description     |
| --------------------- | ------------------------- |
| `11434`               | Ollama web server         |
| `8188`                | ComfyUI Interface         |

## Roadmap
* [ ] API Dashboard
* [ ] Example apps to showcase
* [ ] Tests
* [ ] Versioning
