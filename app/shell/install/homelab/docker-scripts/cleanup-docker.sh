#!/bin/bash

echo "WARNING: This will remove ALL Docker containers, networks, volumes, and images!"
echo "This action cannot be undone!"
read -p "Are you sure you want to continue? (y/N) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Stop all running Docker containers
echo "Stopping all running Docker containers..."
docker stop $(docker ps -aq) 2>/dev/null || true

# Remove all Docker containers
echo "Removing all Docker containers..."
docker rm $(docker ps -aq) 2>/dev/null || true

# Remove all Docker networks
echo "Removing all Docker networks..."
docker network rm $(docker network ls -q) 2>/dev/null || true

# Remove all Docker volumes
echo "Removing all Docker volumes..."
docker volume rm $(docker volume ls -q) 2>/dev/null || true

# Remove all Docker images
echo "Removing all Docker images..."
docker rmi $(docker images -q) 2>/dev/null || true

echo "All Docker containers, networks, volumes, and images have been removed."

read -p "Do you also want to prune the system? This will remove all unused data. (y/N) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Pruning Docker system..."
    docker system prune -a --volumes --force
    echo "Docker system prune completed."
fi
