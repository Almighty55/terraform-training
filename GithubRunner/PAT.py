import uuid
import re
import random
import string
import requests

def generate_uuid():
    # Generate a unique identifier using uuid
    unique_id = str(uuid.uuid4())
    
    # Remove dashes from the unique_id and convert it to lowercase
    sanitized_id = unique_id.replace('-', '').lower()
    
    # Remove any special characters not allowed in branch and tag names
    sanitized_name = re.sub(r'[^a-z0-9._/-]', '', sanitized_id)
    
    # Ensure the name starts with a letter
    if sanitized_name[0].isdigit():
        # Generate a random letter
        random_letter = random.choice(string.ascii_lowercase)
        sanitized_name = random_letter + sanitized_name[1:]
    
    return sanitized_name

def trigger_workflow(repo, username, token, workflow_id, branch_name, payload):
    url = f"https://api.github.com/repos/{username}/{repo}/actions/workflows/{workflow_id}/dispatches"
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json", 
        "X-GitHub-Api-Version": "2022-11-28" #* https://docs.github.com/en/rest/overview/api-versions
    }
    data = {
        "ref": branch_name,
        "inputs": payload
    }

    response = requests.post(url, headers=headers, json=data)

    if response.status_code == 204:
        print(f"Workflow triggered successfully. tf_workspace: {tf_workspace_uuid}")
    else:
        print(f"Failed to trigger the workflow. tf_workspace: {tf_workspace_uuid}")
        print(response.json())  # Print the API response content for debugging purposes.

# Replace these variables with your actual GitHub repository details and access token
github_username = "CloudByteSolutions"
repository_name = "customer-instance"
access_token = ""
workflow_id = "terraform-apply.yml"
branch_name = "main"  # Replace with the branch you want to trigger the workflow on


#! TESTING
# tf_workspace_uuid = "bc8746a4e169448e9725a209e53cf523"
tf_workspace_uuid = generate_uuid()



# Sample dummy data for testing the workflow
payload = {
    "region": "us-east-1",
    "instance_type": "t2.medium",
    "availability_zone": "us-east-1b",
    "tf_workspace": tf_workspace_uuid
}

# Trigger the workflow with the sample dummy payload
trigger_workflow(repository_name, github_username, access_token, workflow_id, branch_name, payload)