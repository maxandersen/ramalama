#!/bin/bash

# List of models to generate Containerfiles for
declare -A models=(
  ["granite/3b"]="ibm-granite/granite-3b-code-instruct-GGUF granite-3b-code-instruct.Q4_K_M.gguf"
  ["t5/3b"]="google/t5-3b-GGUF t5-3b.Q4_K_M.gguf"
  ["t5/11b"]="google/t5-11b-GGUF t5-11b.Q4_K_M.gguf"
  ["llama3/8b"]="bartowski/Llama-3-8B-Instruct-Gradient-1048k-GGUF Llama-3-8B-Instruct-Gradient-1048k-IQ1_M.gguf"
)

# Function to create directory and Containerfile
generate_containerfile() {
  local model_dir="$(echo $1 | tr '[:upper:]' '[:lower:]')"
  local hf_repo=$2
  local model_file=$3

  mkdir -p "container-images/$model_dir"

  cat <<EOF > "container-images/$model_dir/Containerfile"
FROM podman-llm

RUN llama-cpp-main --hf-repo $hf_repo -m $model_file

ENTRYPOINT llama-cpp-main --instruct -m /$model_file 2> /dev/null
EOF
}

# Iterate over the models and generate Containerfiles
for model_dir in "${!models[@]}"; do
  IFS=' ' read -r -a model_info <<< "${models[$model_dir]}"
  hf_repo=${model_info[0]}
  model_file=${model_info[1]}

  generate_containerfile "$model_dir" "$hf_repo" "$model_file"
done

echo "Containerfiles have been generated successfully."

