#!/bin/bash
set -e


echo "Starting FLARE25 Task 5 prediction..."
echo "Input directory: /workspace/inputs/"
echo "Output directory: /workspace/outputs/"

# Create output directory if it doesn't exist
mkdir -p /workspace/outputs/


# Run inference
echo "Running preprocessing on images..."
python /workspace/Data/process/process_ct.py \
      --json_in /workspace/inputs/test.json \
      --nifti_dir /workspace/inputs/images \
      --out_dir /workspace/inputs/test_preprocessed \
      --out_json /workspace/inputs



echo "running inference on preprocessed .npy file"
python /workspace/infer.py \
    --model_name_or_path /workspace/results/baseline \
    --json_path /workspace/inputs/test_processed.json \
    --data_root /workspace/inputs/test_preprocessed \
    --model_max_length 768 \
    --prompt "simple" \
    --proj_out_num 256


echo "running inference for infer_vqa for"
python /workspace/infer_vqa.py \
  --model_name_or_path /workspace/results/baseline \
  --json_path /workspace/inputs/test_processed.json \
  --output_path /workspace/outputs \
  --model_max_length 512 \
  --data_root /workspace/inputs/test_preprocessed \
  --proj_out_num 256

echo "running final vqa json for "
python /workspace/eval_vqa.py \
  --pred_csv /workspace/outputs/predictions.csv \
  --val_json /workspace/inputs/test_processed.json \
  --out_json /workspace/outputs/vqa.json

echo "Prediction completed!"
echo "Output files:"
ls -la /workspace/outputs/