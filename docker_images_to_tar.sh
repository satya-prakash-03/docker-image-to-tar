#!/bin/bash

# Define the output directory
output_dir="docker_images_tar"

echo "Processing ..."

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

docker images >> "$output_dir/docker_image.txt"

# Initialize a counter
counter=1

# Loop through each Docker image and save it as a tar file in the output directory
docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | while read -r image_id; do
    # Extract image name and tag
    image_name=$(echo "$image_id" | awk '{print $1}')
    image_tag=$(echo "$image_id" | awk '{print $2}')
    
    # Skip images with <none> as the tag
    if [[ "$image_tag" == "<none>" ]]; then
        image_tag="untagged"
    fi

    # Replace special characters in the image name with underscores for file compatibility
    save_image_name=$(echo "$image_name" | sed 's/[^a-zA-Z0-9._-]/_/g')
    
    # Save the Docker image to a tar file with a counter prefix
    tar_file_name="${counter}_${save_image_name}_${image_tag}.tar"
    docker save -o "$output_dir/$tar_file_name" "$image_name"
    echo "Saving $image_name to $output_dir/$tar_file_name"
    
    # Increment the counter
    counter=$((counter + 1))
done
