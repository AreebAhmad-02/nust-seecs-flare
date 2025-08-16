# FLARE25 Task 5 Submission Guide - Team nust1flare

## Final Setup Steps

### 1. Organize Your Project Directory
```
nust1flare-submission/
├── Dockerfile                    # Use the corrected version
├── predict.sh                   # Use the corrected version        
├── build_docker.sh              # Updated with your team name
├── infer.py                     # Your existing script (works fine)
├── requirements.txt             # Your existing requirements
├── model/                       # Your trained Phi-3 model weights
│   ├── pytorch_model.bin
│   ├── config.json
│   ├── tokenizer.json
│   └── ...
├── FLARE25-MLLM3D/             # Your baseline repository
│   ├── LaMed/
│   ├── GREEN/
│   ├── requirements.txt
│   └── ...
└── utils/
    ├── create_test_manifest.py     # New script for dynamic input handling           
```

### 2. Build and Test Your Docker Container

```bash
# Make build script executable
chmod +x build_docker.sh

# Build the container
./build_docker.sh

# This will create: nust1flare.tar.gz
```

### 3. Test Your Container Locally

```bash
# Create test data
mkdir -p test_inputs test_outputs

# Put some .nii.gz files in test_inputs/ for testing
# (Use some validation data from your training)

# Test with the exact evaluation command from the challenge
docker run --gpus "device=0" -m 48G --name test_nust1flare --rm \
    -v $PWD/test_inputs/:/workspace/inputs/ \
    -v $PWD/test_outputs/:/workspace/outputs/ \
    nust1flare:latest /bin/bash -c "sh predict.sh"
```

### 4. Record Sanity Test Video

You need to record a video showing:
1. Your Docker container running on validation examples
2. The prediction process completing successfully  
3. Output files being generated
4. Runtime should be within 1.5x baseline runtime

**Recording suggestions:**
- Use screen recording software (OBS, QuickTime, etc.)
- Show the terminal with the docker run command
- Show the progress/output during inference
- Show the final output directory with results
- Keep video under 10 minutes

## Submission Details

### For Validation Submission:

**Email Details:**
- **To:** Mohammed Baharoon  
- **CC:** MICCAI.FLARE@aliyun.com
- **Subject:** `Task5-3D-nust1flare-[YourLeaderName]-Validation Submission`

**Email Content Template:**
```
Dear FLARE25 Organizers,

Please find our validation submission for Task 5 (3D MLLM) below:

Team Name: nust1flare
Team Leader: [Your Name]
Submission Type: Validation

Docker Container: [Download Link to nust1flare.tar.gz]
Sanity Test Video: [Link to video file]

Model Details:
- Base Model: Phi-3-mini-4k-instruct
- Vision Tower: 3D ViT
- Training Data: [Brief description]
- Key Features: [Brief description of your approach]

Technical Specifications:
- Docker Image Size: [Size from build output]
- Expected Runtime: [Estimated time per case]
- GPU Memory Usage: [Approximate VRAM usage]

Please let us know if you need any additional information.

Best regards,
[Your Name]
[Your Institution]
[Contact Information]
```

### For Testing Submission (Final):

Same format but change:
- **Subject:** `Task5-3D-nust1flare-[YourLeaderName]-Testing Submission`
- **Note:** Only ONE testing submission allowed!

## Pre-Submission Checklist

- [ ] Docker image builds successfully
- [ ] Container size < 35GB (`nust1flare.tar.gz`)
- [ ] Local test runs without errors
- [ ] Output files are generated in `/workspace/outputs/`
- [ ] Runtime is reasonable (within 1.5x baseline)
- [ ] Sanity test video recorded
- [ ] All model weights included in Docker image
- [ ] Upload `nust1flare.tar.gz` to cloud storage (Google Drive, Dropbox, etc.)
- [ ] Test download link works

## Common Issues & Solutions

### Docker Build Issues:
```bash
# If you get permission errors:
sudo docker build -t nust1flare:latest .

# If you get out of space errors:
docker system prune -a
```

### Size Issues:
```bash
# Check what's taking space in your image:
docker history nust1flare:latest --human --format "table {{.CreatedBy}}\t{{.Size}}"

# Remove unnecessary files from Dockerfile:
# - Remove .git directories
# - Remove __pycache__ directories  
# - Remove unnecessary data files
```

### Runtime Issues:
```bash
# If inference is too slow:
# - Reduce batch size in your inference script
# - Use mixed precision (fp16/bf16)
# - Consider model quantization

# If GPU memory issues:
# - Reduce image resolution if possible
# - Use gradient checkpointing
# - Clear cache between samples
```

## File Upload Recommendations

For uploading your `nust1flare.tar.gz` file:

1. **Google Drive:** Create shareable link, set permissions to "Anyone with link can view"
2. **Dropbox:** Use Dropbox Transfer for large files
3. **OneDrive:** Use shareable link
4. **WeTransfer:** Good for temporary large file sharing
5. **Institutional storage:** If your university provides large file sharing

**Important:** Test the download link before submitting!

## Timeline Reminders

- **Validation Phase:** 2025.4.15 - 8.01
- **Testing Phase:** 2025.8.01 - 8.15  
- **You can submit 3 times per month during validation**
- **Only 1 submission allowed for testing!**

Good luck with your submission! 🚀