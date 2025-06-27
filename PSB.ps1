param(
    [switch]$RetainBackupDir
)

# === Handling configs ===
try {
    $configPath = Join-Path $PSScriptRoot "config.json"
    $credPath   = Join-Path $PSScriptRoot "portainer.cred"
    $config = Get-Content $configPath | ConvertFrom-Json
    $portainerUrl = $config.PortainerUrl
    $username     = $config.Username
    $backupDir    = $config.BackupDir
    if ($RetainBackupDir) {
        $now = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupDir = Join-Path $backupDir $now
    }    
    $securePassword = Get-Content $credPath | ConvertTo-SecureString
    $credential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)
    $passwordPlain = $credential.GetNetworkCredential().Password
}
catch {
    Write-Error "An error occurred handling configs: $_"
    exit 1
}

# === Handling backup folder ===
try {
    if (Test-Path $backupDir) {
        Write-Host "Cleaning backup folder: $backupDir"
        Get-ChildItem -Path $backupDir -Recurse -Force | Remove-Item -Recurse -Force
    } else {
        Write-Host "Create backup folder: $backupDir"
        New-Item -ItemType Directory -Path $backupDir | Out-Null
    }
}
catch {
    Write-Error "An error occurred handling backup folder: $_"
    exit 1
}

# === Getting data from Portainer ===
try {
    $authBody = @{
        Username = $username
        Password = $passwordPlain
    } | ConvertTo-Json
    $response = Invoke-RestMethod -Method Post -Uri "$portainerUrl/api/auth" `
        -ContentType "application/json" -Body $authBody
    $token = $response.jwt
    $headers = @{
        Authorization = "Bearer $token"
    }
    $stacks = Invoke-RestMethod -Uri "$portainerUrl/api/stacks" -Headers $headers
}
catch {
    Write-Error "An error occurred getting data from Portainer: $_"
    exit 1
}

# === Handling Stacks ===
try {
    foreach ($stack in $stacks) {
        $stackName = $stack.Name
        $stackId = $stack.Id
        $filePath = Join-Path $backupDir "$stackName.yaml"
        Write-Host "Handling: $stackName (ID: $stackId)"
        $response = Invoke-RestMethod -Uri "$portainerUrl/api/stacks/$stackId/file" `
            -Headers $headers
        $yamlContent = $response.StackFileContent
        $yamlContent | Out-File -FilePath $filePath -Encoding UTF8
    }
}
catch {
    Write-Error "An error occurred handling retrieved stacks: $_"
    exit 1
}

Write-Host "Operation finished"
exit 0
