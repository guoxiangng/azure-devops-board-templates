# PowerShell Script to Create AWS Infrastructure Template Board in Azure DevOps

<#
.SYNOPSIS
    Creates a streamlined template of AWS infrastructure work items in Azure DevOps
.DESCRIPTION
    Creates a core set of Epics, Issues, and Tasks representing key AWS infrastructure components
    that can serve as a starting template for teams to customize
.EXAMPLE
    .\aws-infra-template.ps1 -OrganizationName "YourOrg" -ProjectName "YourProject" -PersonalAccessToken "YourPAT"
#>

# Parameters
param(
    [Parameter(Mandatory=$true)]
    [string]$OrganizationName,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$true)]
    [string]$PersonalAccessToken
)

# Constants
$apiVersion = "7.1"
$baseUrl = "https://dev.azure.com/$OrganizationName/$ProjectName/_apis"

# Create Base64 encoded authorization header from PAT
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))
$headers = @{
    "Authorization" = "Basic $base64AuthInfo"
}

# Helper Function to create work items
function Create-WorkItem {
    param (
        [string]$WorkItemType,
        [string]$Title,
        [string]$Description = "",
        [string[]]$Tags = $null,
        [string]$ParentId = $null
    )
    
    $operations = @(
        @{
            op = "add"
            path = "/fields/System.Title"
            value = $Title
        }
    )
    
    if ($Description -ne "") {
        $operations += @{
            op = "add"
            path = "/fields/System.Description"
            value = $Description
        }
    }
    
    if ($Tags) {
        $operations += @{
            op = "add"
            path = "/fields/System.Tags"
            value = ($Tags -join "; ")
        }
    }
    
    if ($ParentId) {
        $operations += @{
            op = "add"
            path = "/relations/-"
            value = @{
                rel = "System.LinkTypes.Hierarchy-Reverse"
                url = "$baseUrl/wit/workItems/$ParentId"
            }
        }
    }
    
    $uri = "$baseUrl/wit/workitems/`$$WorkItemType" + "?api-version=$apiVersion"
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body ($operations | ConvertTo-Json -Depth 10) -ContentType "application/json-patch+json"
        return $response
    } catch {
        Write-Error "Failed to create $WorkItemType '$Title': $_"
        exit
    }
}

# Main Script Execution
Write-Host "Starting AWS Infrastructure Template Creation..." -ForegroundColor Green

# Define the Streamlined AWS Infrastructure Template Structure
# This is a deliberate subset focused on the most critical infrastructure elements
$epics = @(
    @{
        Title = "Account & Identity Foundation"
        Description = "Establish the core AWS Organization structure with proper identity, access management, and security controls"
        Tags = @("aws", "foundation")
        Issues = @(
            @{
                Title = "AWS Organization Setup"
                Description = "Establish multi-account AWS Organization with proper OU structure and guardrails"
                Tags = @("security", "new-infrastructure")
                Tasks = @(
                    @{
                        Title = "Implement AWS Control Tower"
                        Description = "Deploy AWS Control Tower with organizational unit structure for Production, Development, and Shared Services"
                        Tags = @("security", "implementation")
                    }
                )
            },
            @{
                Title = "Identity & Access Management"
                Description = "Implement centralized identity and access management solutions"
                Tags = @("security", "new-infrastructure")
                Tasks = @(
                    @{
                        Title = "Configure AWS SSO"
                        Description = "Set up AWS SSO integrated with corporate identity provider"
                        Tags = @("security", "implementation")
                    }
                )
            }
        )
    },
    @{
        Title = "Network Infrastructure"
        Description = "Build secure network infrastructure across accounts and environments"
        Tags = @("aws", "networking")
        Issues = @(
            @{
                Title = "VPC Architecture"
                Description = "Implement production-ready VPC architecture with proper segmentation"
                Tags = @("networking", "new-infrastructure")
                Tasks = @(
                    @{
                        Title = "Implement Transit Gateway"
                        Description = "Deploy Transit Gateway for inter-VPC and hybrid connectivity"
                        Tags = @("networking", "implementation")
                    }
                )
            },
            @{
                Title = "Network Security"
                Description = "Implement network security controls and inspection"
                Tags = @("networking", "security", "new-infrastructure")
                Tasks = @(
                    @{
                        Title = "Deploy Network Firewall"
                        Description = "Set up AWS Network Firewall with traffic inspection policies"
                        Tags = @("networking", "security", "implementation")
                    }
                )
            }
        )
    },
    @{
        Title = "Compute Platforms"
        Description = "Establish standardized compute platforms for various workload types"
        Tags = @("aws", "compute")
        Issues = @(
            @{
                Title = "Container Platform"
                Description = "Implement Amazon EKS with appropriate security and operational controls"
                Tags = @("compute", "new-infrastructure")
                Tasks = @(
                    @{
                        Title = "Deploy EKS Clusters"
                        Description = "Deploy EKS clusters with proper configuration for multi-tenant workloads"
                        Tags = @("compute", "implementation")
                    }
                )
            },
            @{
                Title = "Serverless Platform"
                Description = "Establish serverless computing environment with AWS Lambda"
                Tags = @("compute", "new-infrastructure")
                Tasks = @(
                    @{
                        Title = "Set up Lambda Environment"
                        Description = "Deploy Lambda execution environment with appropriate IAM roles and VPC connectivity"
                        Tags = @("compute", "implementation")
                    }
                )
            }
        )
    },
    @{
        Title = "Security & Compliance"
        Description = "Implement comprehensive security controls and monitoring"
        Tags = @("aws", "security")
        Issues = @(
            @{
                Title = "Security Monitoring"
                Description = "Implement security monitoring and detection controls"
                Tags = @("security", "new-infrastructure")
                Tasks = @(
                    @{
                        Title = "Set up GuardDuty and Security Hub"
                        Description = "Enable GuardDuty threat detection and Security Hub for compliance monitoring"
                        Tags = @("security", "implementation")
                    }
                )
            },
            @{
                Title = "Data Protection"
                Description = "Implement data protection measures for storage and databases"
                Tags = @("security", "new-infrastructure")
                Tasks = @(
                    @{
                        Title = "Implement Encryption Strategy"
                        Description = "Deploy KMS keys and encryption policies for data at rest and in transit"
                        Tags = @("security", "implementation")
                    }
                )
            }
        )
    },
    @{
        Title = "Operations & Monitoring"
        Description = "Establish operational excellence and monitoring capabilities"
        Tags = @("aws", "operations")
        Issues = @(
            @{
                Title = "Centralized Logging"
                Description = "Implement centralized logging solution across all accounts"
                Tags = @("operations", "new-infrastructure")
                Tasks = @(
                    @{
                        Title = "Configure CloudWatch Logs"
                        Description = "Set up centralized CloudWatch Logs aggregation"
                        Tags = @("operations", "implementation")
                    }
                )
            },
            @{
                Title = "Alerting and Incident Response"
                Description = "Establish alerting and incident response framework"
                Tags = @("operations", "new-infrastructure")
                Tasks = @(
                    @{
                        Title = "Set up CloudWatch Alarms"
                        Description = "Configure CloudWatch Alarms for critical infrastructure components"
                        Tags = @("operations", "implementation")
                    }
                )
            }
        )
    }
)

# Create the work items
foreach ($epic in $epics) {
    # Create Epic
    Write-Host "Creating Epic: $($epic.Title)" -ForegroundColor Cyan
    $epicItem = Create-WorkItem -WorkItemType "Epic" -Title $epic.Title -Description $epic.Description -Tags $epic.Tags
    Write-Host "Created Epic ID: $($epicItem.id)" -ForegroundColor Green
    
    # Sleep briefly to avoid rate limiting
    Start-Sleep -Milliseconds 500
    
    foreach ($issue in $epic.Issues) {
        # Create Issue
        Write-Host "  Creating Issue: $($issue.Title)" -ForegroundColor Yellow
        $issueItem = Create-WorkItem -WorkItemType "Issue" -Title $issue.Title -Description $issue.Description -Tags $issue.Tags -ParentId $epicItem.id
        Write-Host "  Created Issue ID: $($issueItem.id)" -ForegroundColor Green
        
        # Sleep briefly to avoid rate limiting
        Start-Sleep -Milliseconds 500
        
        foreach ($task in $issue.Tasks) {
            # Create Task
            Write-Host "    Creating Task: $($task.Title)" -ForegroundColor Magenta
            $taskItem = Create-WorkItem -WorkItemType "Task" -Title $task.Title -Description $task.Description -Tags $task.Tags -ParentId $issueItem.id
            Write-Host "    Created Task ID: $($taskItem.id)" -ForegroundColor Green
            
            # Sleep briefly to avoid rate limiting
            Start-Sleep -Milliseconds 500
        }
    }
}

Write-Host "`nAWS Infrastructure Template Creation Completed Successfully!" -ForegroundColor Green
Write-Host "Created 5 Epics, 10 Issues, and 10 Tasks organized in a hierarchy" -ForegroundColor Green
Write-Host "This template provides a starting point that covers the most critical AWS infrastructure components." -ForegroundColor Green
Write-Host "Teams can customize this template by adding additional items specific to their environment." -ForegroundColor Green
