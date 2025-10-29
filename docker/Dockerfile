# Use the official cytopia/ansible image as a base
FROM cytopia/ansible:latest-tools


# Copy the requirements file into the image
COPY config-ansible/requirements.txt /tmp/requirements.txt

# Install Python dependencies for the dynamic inventory script
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Install yq for YAML processing
RUN apk add --no-cache yq
