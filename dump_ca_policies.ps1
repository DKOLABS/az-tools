$ClientSecretCredential = Get-Credential -Credential ""
Connect-MgGraph -TenantId "" -ClientSecretCredential $ClientSecretCredential -NoWelcome
# Fetch conditional access policies
$policies = Get-MgIdentityConditionalAccessPolicy

# Get the current date and time
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Start the HTML content
$htmlContent = @"
<html>
<head>
    <title>Conditional Access Policies Report</title>
    <style>
        body { font-family: Arial, sans-serif; }
        table { border-collapse: collapse; width: 100%; margin-top: 10px; }
        th, td { border: 1px solid black; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .policy {
            background-color: #f2f2f2;
            border-radius: 15px; /* Bubbled border */
            padding: 10px;
            margin-top: 10px;
        }
        .policy h3 {
            color: #333; /* Adjusted the color */
            padding: 5px;
            border-radius: 5px;
            margin: 0;
            display: inline-block;
            cursor: pointer;
        }
        .policy h3.conditions {
            margin-top: 20px; /* Added margin for space */
        }
        .policy h3.grant-controls {
            margin-top: 20px; /* Added margin for space */
        }
        .policy h3.collapsed::before {
            content: '\002B'; /* Plus sign when collapsed */
            margin-right: 10px;
        }
        .policy h3.expanded::before {
            content: '\2212'; /* Minus sign when expanded */
            margin-right: 10px;
        }
        .policy table {
            margin-top: 10px;
        }
        .content {
            padding: 0 18px;
            display: none;
            overflow: hidden;
            background-color: #f9f9f9;
            border-radius: 15px; /* Bubbled border for the content */
            border: 1px solid #f2f2f2;
        }
        .sub-section {
            margin-left: 20px;
        }
        .sub-header {
            margin-top: 10px;
            cursor: pointer;
        }
    </style>
</head>
<body>
<h2>Conditional Access Policies Report</h2>
<p>Report generated on: $timestamp</p>
<script>
    function toggleContent(element) {
        var content = element.nextElementSibling;
        if (content.style.display === "block") {
            content.style.display = "none";
            element.classList.remove("expanded");
            element.classList.add("collapsed");
        } else {
            content.style.display = "block";
            element.classList.remove("collapsed");
            element.classList.add("expanded");
        }
        // Prevent the event from bubbling up to parent elements
        if (event) {
            event.stopPropagation();
        }
    }
</script>
"@

# Loop through each policy to build the HTML content
foreach ($policy in $policies) {
    $htmlContent += @"
    <div class="policy">
        <h3 class="collapsed" onclick="toggleContent(this)">$($policy.displayName)</h3>
        <div class="content">
            <table>
                <tr>
                    <th>Attribute</th>
                    <th>Value</th>
                </tr>
                <tr>
                    <td>ID</td>
                    <td>$($policy.id)</td>
                </tr>
                <tr>
                    <td>Created Date Time</td>
                    <td>$($policy.createdDateTime)</td>
                </tr>
                <tr>
                    <td>Modified Date Time</td>
                    <td>$($policy.modifiedDateTime)</td>
                </tr>
                <tr>
                    <td>State</td>
                    <td>$($policy.state)</td>
                </tr>
            </table>
            <h3 class="collapsed conditions" onclick="toggleContent(this)">Conditions</h3>
            <div class="content">
                <table>
                    <tr>
                        <th>Condition Type</th>
                        <th>Details</th>
                    </tr>
                    <tr>
                        <td>Client App Types</td>
                        <td>$($policy.conditions.clientAppTypes -join ', ')</td>
                    </tr>
                    <tr>
                        <td>Service Principal Risk Levels</td>
                        <td>$($policy.conditions.servicePrincipalRiskLevels -join ', ')</td>
                    </tr>
                    <tr>
                        <td>Sign-in Risk Levels</td>
                        <td>$($policy.conditions.signInRiskLevels -join ', ')</td>
                    </tr>
                </table>
                <br>
                <h3 class="collapsed sub-header" onclick="toggleContent(this, event)">Users</h3>
                <div class="content sub-section">
                    <table>
                        <tr>
                            <th>Attribute</th>
                            <th>Value</th>
                        </tr>
                        <tr>
                            <td>Include Users</td>
                            <td>$($policy.conditions.users.includeUsers -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Exclude Users</td>
                            <td>$($policy.conditions.users.excludeUsers -join ', ')</td>
                        </tr>
                        <!-- You can continue with other attributes of 'conditions.users' as needed -->
                    </table>
                </div>
            </div>
            <br>
            <h3 class="collapsed grant-controls" onclick="toggleContent(this)">Grant Controls</h3>
            <div class="content">
                <table>
                    <tr>
                        <th>Attribute</th>
                        <th>Value</th>
                    </tr>
                    <tr>
                        <td>Operator</td>
                        <td>$($policy.grantControls.operator)</td>
                    </tr>
                    <tr>
                        <td>Built-In Controls</td>
                        <td>$($policy.grantControls.builtInControls -join ', ')</td>
                    </tr>
                    <tr>
                        <td>Custom Controls</td>
                        <td>$($policy.grantControls.customControls -join ', ')</td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
"@
}

# End the HTML content
$htmlContent += @"
</body>
</html>
"@

# Save the generated HTML content to a file
$htmlContent | Out-File "report.html"

# Open the HTML report in the default web browser
Start-Process "report.html"