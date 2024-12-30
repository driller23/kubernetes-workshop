#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to get the first pod name from a deployment
get_pod_name() {
    local namespace=$1
    local deployment=$2
    
    pod_name=$(kubectl get pods -n ${namespace} -l app=${deployment} -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [ -z "$pod_name" ]; then
        echo "Error: No pods found for deployment ${deployment} in namespace ${namespace}" >&2
        exit 1
    fi
    echo ${pod_name}
}

# Function to test pod connectivity
test_connectivity() {
    local from_ns=$1
    local from_deploy=$2
    local to_ns=$3
    local to_deploy=$4
    local port=$5
    local expected=$6

    # Get pod names from deployments
    local from_pod=$(get_pod_name ${from_ns} ${from_deploy})
    local to_service="${to_deploy}.${to_ns}.svc.cluster.local"
    
    echo -e "${YELLOW}Testing connectivity from ${from_ns}/${from_pod} to ${to_service}:${port}...${NC}"
    
    # Use netcat to test TCP connectivity
    result=$(kubectl exec -n ${from_ns} ${from_pod} -- nc -zv -w 5 ${to_service} ${port} 2>&1)
    exit_code=$?
    
    if [ ${exit_code} -eq 0 ]; then
        if [ "$expected" == "allow" ]; then
            echo -e "${GREEN}SUCCESS${NC} (Expected: allowed, Got: allowed)"
            return 0
        else
            echo -e "${RED}FAILED${NC} (Expected: denied, Got: allowed)"
            return 1
        fi
    else
        if [ "$expected" == "deny" ]; then
            echo -e "${GREEN}SUCCESS${NC} (Expected: denied, Got: denied)"
            return 0
        else
            echo -e "${RED}FAILED${NC} (Expected: allowed, Got: denied)"
            return 1
        fi
    fi
}

# Function to wait for deployment to be ready
wait_for_deployment() {
    local namespace=$1
    local deployment=$2
    local timeout=60

    echo "Waiting for deployment ${deployment} in namespace ${namespace} to be ready..."
    kubectl wait --for=condition=available deployment/${deployment} -n ${namespace} --timeout=${timeout}s
    if [ $? -ne 0 ]; then
        echo -e "${RED}Timeout waiting for deployment ${deployment}${NC}"
        exit 1
    fi
}

# Main test scenarios
main() {
    echo "Running advanced policy tests"
    echo "----------------------------------------"
    
    # Create monitoring namespace if it doesn't exist
    kubectl create namespace monitoring 2>/dev/null || true
    
    # Apply advanced deployments
    kubectl apply -f manifests/advanced-deployments.yaml
    
    # Wait for all deployments to be ready
    wait_for_deployment "database" "database"
    wait_for_deployment "monitoring" "monitoring"
    
    # Small delay to ensure pods are fully ready
    sleep 10
    
    echo "Testing multi-tier connectivity..."
    
    # Test frontend to backend connectivity (allowed)
    test_connectivity "frontend" "frontend" "backend" "backend" "80" "allow"
    
    # Test backend to database connectivity (allowed)
    test_connectivity "backend" "backend" "database" "database" "5432" "allow"
    
    # Test frontend to database connectivity (denied)
    test_connectivity "frontend" "frontend" "database" "database" "5432" "deny"
    
    # Test monitoring access
    test_connectivity "monitoring" "monitoring" "backend" "backend" "9090" "allow"
}

# Run the tests
main
