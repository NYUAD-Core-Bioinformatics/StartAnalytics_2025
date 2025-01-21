# StartAnalytics_2025
data analysis with Python and R for beginners

In this workshop, we will be using Docker to create a consistent and isolated environment for all participants. Please follow the steps below to prepare your laptop.

### Step 1: Install Docker

1. Download and install Docker Desktop for your operating system (Windows/macOS/Linux).
2. After installation, verify Docker is running by opening a terminal and typing:


### Step 2: Download the Workshop Image

1. Open your terminal and pull the workshop Docker image using this command:

```
docker pull nyuadcorebio/jupyterlab-workshop:latest
```

### Step 3: Start the Docker Container

1. To run the workshop environment, use the following command:

```
docker run -p 8889:8888 nyuadcorebio/jupyterlab-workshop:latest
```

2. Open the browser and go to 
[http://localhost:8889/lab](http://localhost:8889/lab)