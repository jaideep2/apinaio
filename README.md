# apinaio

> **Warning**  
> Still in alpha.

Ready to host LLaMa2 + SD/AnimateDiff + ffmpeg API

## Start

declare your environment variables in .env and launch a container with docker compose.

You can also self-build from source by editing .env and running docker compose build.

Supported Python versions: 3.10

Supported Pytorch versions: 2.0.1

Supported Platforms: NVIDIA CUDA, AMD ROCm, CPU

## Environment Variables

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

## Security

By default, all exposed web services other than the port redirect page are protected by HTTP basic authentication.

The default username is `user` and the password is `password`.

You can set your credentials by passing environment variables as shown above.

The password is stored as a bcrypt hash. If you prefer not to pass a plain text password to the container you can pre-hash and use the variable `WEB_PASSWORD_HASH`.

If you are running the image locally on a trusted network, you may disable authentication by setting the environment variable `WEB_ENABLE_AUTH=false`.

## Provisioning script

It can be useful to perform certain actions when starting a container, such as creating directories and downloading files.

You can use the environment variable `PROVISIONING_SCRIPT` to specify the URL of a script you'd like to run.

The URL must point to a plain text file - GitHub Gists/Pastebin (raw) are suitable options.

If you are running locally you may instead opt to mount a script at `/opt/ai-dock/bin/provisioning.sh`.

>[!NOTE]  
>If configured, `sshd`, `caddy`, `cloudflared`, `rclone`, `port redirector` & `logtail` will be launched before provisioning; Any other processes will launch after.


>[!WARNING]  
>Only use scripts that you trust and which cannot be changed without your consent.

## Open Ports

Some ports need to be exposed for the services to run or for certain features of the provided software to function


| Open Port             | Service / Description     |
| --------------------- | ------------------------- |
| `22`                  | SSH server                |
| `1111`                | Port redirector web UI    |
| `1122`                | Log viewer web UI         |
| `8188`                | ComfyUI Interface         |
| `8888`                | Jupyter                   |
| `53682`               | Rclone interactive config |

