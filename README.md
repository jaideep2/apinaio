# apinaio

> **Warning**  
> In development phase. Help is needed!

Ready to host [Ollama](https://github.com/jmorganca/ollama) + [ComfyUI](https://github.com/comfyanonymous/ComfyUI) + [ffmpeg](https://ffmpeg.lav.io/) Docker images

## Features

One click deployment of [most LLMs](https://ollama.ai/library), most [ComfyUI packages](https://github.com/WASasquatch/comfyui-plugins) and [ffmpeg](https://www.ffmpeg.org/) for all your text2video needs. All three can be configured under config folder. For example:

- config/ollama/entrypoint.sh for downloading models and serving via [API]()
- config/ollama/modelfiles for defining [custom models]()
- config/comfyui/provisioning.sh for installing custom packages and nodes
- config/comfyui/models.csv for defining [custom models]()
- config/comfyui/nodes.csv for defining [custom nodes]()

## Start

Rename template.env to .env and define all the environment variables there then launch one or all three containers with docker compose.

Supported Python versions: 3.10

Supported Pytorch versions: 2.0.1

Supported Platforms: NVIDIA CUDA, CPU (Have not tested others yet)

## Open Ports

Some ports need to be exposed for the services to run or for certain features of the provided software to function


| Open Port             | Service / Description     |
| --------------------- | ------------------------- |
| `8188`                | ComfyUI Interface         |
| `11434`               | Ollama web server         |
| `3000`                | FFmpeg-api web server     |
<!--
| `22`                  | SSH server                |
| `1111`                | Port redirector web UI    |
| `1122`                | Log viewer web UI         |
| `53682`               | Rclone interactive config |
-->

## ComfyUI

### Environment Variables (still updating..)

| Variable              | Description |
| --------------------- | ----------- |
| `CF_TUNNEL_TOKEN`     | Cloudflare zero trust tunnel token - See [documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/). |
| `CF_QUICK_TUNNELS`    | Create ephemeral Cloudflare tunnels for web services (default `false`) |
| `COMFYUI_BRANCH`      | ComfyUI branch/commit hash. Defaults to `master` |
| `COMFYUI_FLAGS`       | Startup flags. eg. `--gpu-only --highvram` |
| `COMFYUI_PORT`        | ComfyUI interface port (default `8188`) |
| `GPU_COUNT`           | Limit the number of available GPUs |
| `PROVISIONING_SCRIPT` | URL of a remote script to execute on init. See [note](#provisioning-script). |
| `RCLONE_*`            | Rclone configuration - See [rclone documentation](https://rclone.org/docs/#config-file) |
| `SKIP_ACL`            | Set `true` to skip modifying workspace ACL |
| `SSH_PORT`            | Set a non-standard port for SSH (default `22`) |
| `SSH_PUBKEY`          | Your public key for SSH |
| `WEB_ENABLE_AUTH`     | Enable password protection for web services (default `true`) |
| `WEB_USER`            | Username for web services (default `user`) |
| `WEB_PASSWORD`        | Password for web services (default `password`) |
| `WORKSPACE`           | A volume path. Defaults to `/workspace/` |
| `WORKSPACE_SYNC`      | Move mamba environments and services to workspace if mounted (default `true`) |

### Security

By default, all exposed web services other than the port redirect page are protected by HTTP basic authentication.

The default username is `user` and the password is `password`.

You can set your credentials by passing environment variables as shown above.

The password is stored as a bcrypt hash. If you prefer not to pass a plain text password to the container you can pre-hash and use the variable `WEB_PASSWORD_HASH`.

If you are running the image locally on a trusted network, you may disable authentication by setting the environment variable `WEB_ENABLE_AUTH=false`.

### Provisioning script

It can be useful to perform certain actions when starting a container, such as creating directories and downloading files.

You can use the environment variable `PROVISIONING_SCRIPT` to specify the URL of a script you'd like to run.

The URL must point to a plain text file - GitHub Gists/Pastebin (raw) are suitable options.

If you are running locally you may instead opt to mount a script at `/opt/ai-dock/bin/provisioning.sh`.

>[!NOTE]  
>If configured, `sshd`, `caddy`, `cloudflared`, `rclone`, `port redirector` & `logtail` will be launched before provisioning; Any other processes will launch after.


>[!WARNING]  
>Only use scripts that you trust and which cannot be changed without your consent.

## Ollama

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

# Docker Register
Coming soon
