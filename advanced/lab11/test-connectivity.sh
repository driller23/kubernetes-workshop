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
    local expected=$5

    # Get pod names from deployments
    local from_pod=$(get_pod_name ${from_ns} ${from_deploy})
    local to_pod=$(get_pod_name ${to_ns} ${to_deploy})
    
    echo -e "${YELLOW}Testing connectivity from ${from_ns}/${from_pod} to ${to_ns}/${to_pod}...${NC}"
    
    # Get the target pod's IP
    TARGET_IP=$(kubectl get pod -n ${to_ns} ${to_pod} -o jsonpath='{.status.podIP}')
    if [ -z "$TARGET_IP" ]; then
        echo -e "${RED}Failed to get IP for pod ${to_pod}${NC}"
        return 1
    fi

    # Use wget instead of curl as it's available in the nginx image
    result=$(kubectl exec -n ${from_ns} ${from_pod} -- wget -q -T 5 -O - http://${TARGET_IP} > /dev/null 2>&1)
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
    local test_phase=$1
    
    echo "Running connectivity tests - Phase: $test_phase"
    echo "----------------------------------------"
    
    # Wait for deployments to be ready
    wait_for_deployment "frontend" "frontend"
    wait_for_deployment "backend" "backend"
    
    # Small delay to ensure pods are fully ready
    sleep 5
    
    if [ "$test_phase" == "before" ]; then
        # Before applying network policies - everything should be allowed
        test_connectivity "frontend" "frontend" "backend" "backend" "allow"
        test_connectivity "backend" "backend" "frontend" "frontend" "allow"
    elif [ "$test_phase" == "after" ]; then
        # After applying network policies - test according to policy rules
        test_connectivity "frontend" "frontend" "backend" "backend" "allow"
        test_connectivity "backend" "backend" "frontend" "frontend" "deny"
    else
        echo "Invalid test phase. Use 'before' or 'after'"
        exit 1
    fi
}

# Check if test phase is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <before|after>"
    exit 1
fi

main "$1"
