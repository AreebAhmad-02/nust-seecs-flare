#!/bin/bash

# Build and package Docker container for FLARE25 Task 5
# Team: nust1flare

TEAM_NAME="nust1flare"
IMAGE_NAME="${TEAM_NAME}:latest"
TAR_NAME="${TEAM_NAME}.tar.gz"

echo "Building Docker image for team: $TEAM_NAME"
echo "Image name: $IMAGE_NAME"

# Build the Docker image
echo "Starting Docker build..."
docker build -t $IMAGE_NAME .

if [ $? -eq 0 ]; then
    echo "✓ Docker image built successfully!"
    
    # Show image size
    echo ""
    echo "Image details:"
    docker images $IMAGE_NAME
    
    # Save and compress the Docker image
    echo ""
    echo "Saving and compressing Docker image to $TAR_NAME..."
    docker save $IMAGE_NAME | gzip > $TAR_NAME
    
    # Check file size (should be < 35GB as per challenge requirements)
    echo ""
    echo "Compressed file details:"
    ls -lh $TAR_NAME
    
    # Check if file size is acceptable
    FILE_SIZE=$(stat -f%z "$TAR_NAME" 2>/dev/null || stat -c%s "$TAR_NAME" 2>/dev/null)
    MAX_SIZE=$((35 * 1024 * 1024 * 1024))  # 35GB in bytes
    
    if [ $FILE_SIZE -gt $MAX_SIZE ]; then
        echo "⚠️  WARNING: File size exceeds 35GB limit!"
        echo "   Current size: $(ls -lh $TAR_NAME | awk '{print $5}')"
        echo "   You may need to optimize your Docker image"
    else
        echo "✓ File size is within 35GB limit"
    fi
    
    echo ""
    echo "🎉 Docker container is ready for submission!"
    echo "📁 File: $TAR_NAME"
    echo ""
    
    # Test the container (optional but recommended)
    echo "🧪 Running container test..."
    mkdir -p test_inputs test_outputs
    
    # Create a dummy test file if test_inputs is empty
    if [ -z "$(ls -A test_inputs 2>/dev/null)" ]; then
        echo "Creating dummy test file for testing..."
        echo '{"test": "data"}' > test_inputs/dummy_test.json
    fi
    
    echo "Testing container with evaluation command..."
    docker run --gpus "device=0" -m 48G --name test_$TEAM_NAME --rm \
        -v $PWD/test_inputs/:/workspace/inputs/ \
        -v $PWD/test_outputs/:/workspace/outputs/ \
        $IMAGE_NAME /bin/bash -c "sh predict.sh"
    
    if [ $? -eq 0 ]; then
        echo "✓ Container test completed successfully!"
        echo "📂 Check test_outputs/ directory for results"
        ls -la test_outputs/
    else
        echo "❌ Container test failed!"
        echo "Please check your Docker setup and fix any issues before submission"
    fi
    
    echo ""
    echo "📋 SUBMISSION CHECKLIST:"
    echo "   ✓ Docker image built: $IMAGE_NAME"
    echo "   ✓ Compressed file created: $TAR_NAME"
    echo "   ✓ File size checked (must be < 35GB)"
    echo "   ✓ Container test run"
    echo ""
    echo "📧 EMAIL SUBMISSION DETAILS:"
    echo "   To: Mohammed Baharoon"
    echo "   CC: MICCAI.FLARE@aliyun.com"
    echo "   Subject: Task5-3D-nust1flare-[YourName]-[Validation/Testing] Submission"
    echo "   Attach: Download link to $TAR_NAME"
    echo "   Include: Sanity test video recording"
    echo ""
    
else
    echo "❌ Docker build failed!"
    echo "Please check the error messages above and fix any issues"
    exit 1
fi