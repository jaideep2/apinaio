#!/bin/false

# This file will be sourced in init.sh
printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
function download() {
    wget -q --show-progress -e dotbytes="${3:-4M}" -O "$2" "$1"
    printf "\n"
}

# Set paths
nodes_dir=/opt/ComfyUI/custom_nodes
models_dir=/opt/ComfyUI/models
checkpoints_dir=${models_dir}/checkpoints
vae_dir=${models_dir}/vae
embeddings_dir=${models_dir}/embeddings
controlnet_dir=${models_dir}/controlnet
loras_dir=${models_dir}/loras
upscale_dir=${models_dir}/upscale_models
animated_models_dir=${nodes_dir}/ComfyUI-AnimateDiff-Evolved/models
animated_motion_lora_dir=${nodes_dir}/ComfyUI-AnimateDiff-Evolved/motion_lora

# Install custom nodes
count=$(awk 'END { print NR }' ${NODES_CSV_FILE})
printf "Found ${count} possible custom nodes\n"
for (( i=1; i<=$count; i++ ))
{
    # Check if not commented
    first_char=$(awk 'NR=='$i' {print substr($0,0,1)}' "${NODES_CSV_FILE}")
    if [[ ${first_char} != "#" ]]; then
        node_name=$(awk -F ',' 'NR=='$i' {print $1}' "${NODES_CSV_FILE}")
        node_url=$(awk -F ',' 'NR=='$i' {print $2}' "${NODES_CSV_FILE}")
        node_pip=$(awk -F ',' 'NR=='$i' {print $3}' "${NODES_CSV_FILE}")
        node_dir=${nodes_dir}/${node_name}
        if [[ ! -d ${node_dir} ]]; then
            printf "[$i/$count] Installing ${node_name}...\n"
            git clone ${node_url} $node_dir
        else
            printf "[$i/$count] ${node_name} exists, updating...\n"
            (cd $node_dir && git pull)
            if [[ ${node_pip} == "pip" ]]; then
                micromamba run -n comfyui ${PIP_INSTALL} -r $node_dir/requirements.txt
            fi
        fi
    else
        printf "[$i/$count] Skipping commented...\n"
    fi
}

# Install models
count=$(awk 'END { print NR }' ${MODELS_CSV_FILE})
printf "Found ${count} possible models\n"
for (( i=1; i<=$count; i++ ))
{
    # Check if not commented
    first_char=$(awk 'NR=='$i' {print substr($0,0,1)}' "${MODELS_CSV_FILE}")
    if [[ ${first_char} != "#" ]]; then
        model_name=$(awk -F ',' 'NR=='$i' {print $1}' "${MODELS_CSV_FILE}")
        model_url=$(awk -F ',' 'NR=='$i' {print $2}' "${MODELS_CSV_FILE}")
        model_dir=$(awk -F ',' 'NR=='$i' {print $3}' "${MODELS_CSV_FILE}")
        model_file=${!model_dir}/${model_name}
        if [[ ! -e ${model_file} ]]; then
            printf "[$i/$count] Downloading ${model_name}...\n"
            download ${model_url} ${model_file}
        else
            printf "[$i/$count] ${model_name} exists, skipping...\n"
        fi
    fi
}