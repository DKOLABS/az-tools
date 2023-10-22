# Connect to Microsoft Graph
Connect-MgGraph -NoWelcome

# Fetch conditional access policies
$policies = Get-MgIdentityConditionalAccessPolicy

# Get the current date and time
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss K"

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
        .policy h3.session-controls {
            margin-top: 20px; /* Added margin for space */
        }
        .policy h3.raw-json {
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
                    <td>Description</td>
                    <td>$($policy.description)</td>
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
                    <tr>
                        <td>User Risk Levels</td>
                        <td>$($policy.conditions.userRiskLevels -join ', ')</td>
                    </tr>
                </table>
                <br>

                <!-- Applications Sub-section -->
                <h3 class="collapsed sub-header" onclick="toggleContent(this, event)">Applications</h3>
                <div class="content sub-section">
                    <table>
                        <tr>
                            <th>Attribute</th>
                            <th>Value</th>
                        </tr>
                        <tr>
                            <td>Included Applications</td>
                            <td>$($policy.conditions.applications.includeApplications -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Excluded Applications</td>
                            <td>$($policy.conditions.applications.excludeApplications -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Include Authentication Context Class References</td>
                            <td>$($policy.conditions.applications.includeAuthenticationContextClassReferences -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Include User Actions</td>
                            <td>$($policy.conditions.applications.includeUserActions -join ', ')</td>
                        </tr>
                    </table>
                </div>
                <br>

                <!-- Users Sub-Section -->
                <h3 class="collapsed sub-header" onclick="toggleContent(this, event)">Users</h3>
                <div class="content sub-section">
                    <table>
                        <tr>
                            <th>Attribute</th>
                            <th>Value</th>
                        </tr>
                        <tr>
                            <td>Included Users</td>
                            <td>$($policy.conditions.users.includeUsers -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Excluded Users</td>
                            <td>$($policy.conditions.users.excludeUsers -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Included Groups</td>
                            <td>$($policy.conditions.users.includeGroups -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Excluded Groups</td>
                            <td>$($policy.conditions.users.excludeGroups -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Included Roles</td>
                            <td>$($policy.conditions.users.includeRoles -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Excluded Roles</td>
                            <td>$($policy.conditions.users.excludeRoles -join ', ')</td>
                        </tr>
                    </table>
                </div>
                <br>

                <!-- Device Filter Sub-section -->
                <h3 class="collapsed sub-header" onclick="toggleContent(this, event)">Device Filter</h3>
                <div class="content sub-section">
                    <table>
                        <tr>
                            <th>Mode</th>
                            <th>Rule</th>
                        </tr>
                        <tr>
                            <td>$($policy.conditions.devices.deviceFilter.mode)</td>
                            <td>$($policy.conditions.devices.deviceFilter.rule)</td>
                        </tr>
                    </table>
                </div>
                <br>

                <!-- Locations Sub-section -->
                <h3 class="collapsed sub-header" onclick="toggleContent(this, event)">Locations</h3>
                <div class="content sub-section">
                    <table>
                        <tr>
                            <th>Attribute</th>
                            <th>Value</th>
                        </tr>
                        <tr>
                            <td>Included Locations</td>
                            <td>$($policy.conditions.locations.includeLocations -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Excluded Locations</td>
                            <td>$($policy.conditions.locations.excludeLocations -join ', ')</td>
                        </tr>
                    </table>
                </div>
                <br>

                <!-- Platforms Sub-section -->
                <h3 class="collapsed sub-header" onclick="toggleContent(this, event)">Platforms</h3>
                <div class="content sub-section">
                    <table>
                        <tr>
                            <th>Attribute</th>
                            <th>Value</th>
                        </tr>
                        <tr>
                            <td>Included Platforms</td>
                            <td>$($policy.conditions.platforms.includePlatforms -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Excluded Platforms</td>
                            <td>$($policy.conditions.platforms.excludePlatforms -join ', ')</td>
                        </tr>
                    </table>
                </div>
                <br>

                <!-- Client Applications Sub-section -->
                <h3 class="collapsed sub-header" onclick="toggleContent(this, event)">Client Applications</h3>
                <div class="content sub-section">
                    <table>
                        <tr>
                            <th>Attribute</th>
                            <th>Value</th>
                        </tr>
                        <tr>
                            <td>Included Service Principals</td>
                            <td>$($policy.conditions.clientApplications.includeServicePrincipals -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Excluded Service Principals</td>
                            <td>$($policy.conditions.clientApplications.excludeServicePrincipals -join ', ')</td>
                        </tr>
                    </table>
                </div>
                <br>

                <!-- ClientAppTypes Sub-section -->
                <h3 class="collapsed sub-header" onclick="toggleContent(this, event)">Client App Types</h3>
                <div class="content sub-section">
                    <ul>
                        $(foreach ($item in $policy.conditions.clientAppTypes) {
                        "<li>$($item)</li>"
                            }
                        )
                    </ul>
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
                        <td>Custom Authentication Factors</td>
                        <td>$($policy.grantControls.customAuthenticationFactors -join ', ')</td>
                    </tr>
                    <tr>
                        <td>Terms of Use</td>
                        <td>$($policy.grantControls.termsOfUse -join ', ')</td>
                    </tr>
                </table>
                <br>

                <!-- Authentication Strength Sub-section -->
                <h3 class="collapsed sub-header" onclick="toggleContent(this, event)">Authentication Strength</h3>
                <div class="content sub-section">
                    <table>
                        <tr>
                            <th>Attribute</th>
                            <th>Value</th>
                        </tr>
                        <tr>
                            <td>ID</td>
                            <td>$($policy.grantControls.authenticationStrength.id -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Disaply Name</td>
                            <td>$($policy.grantControls.authenticationStrength.displayName -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Description</td>
                            <td>$($policy.grantControls.authenticationStrength.description -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Policy Type</td>
                            <td>$($policy.grantControls.authenticationStrength.policyType -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Created Datetime</td>
                            <td>$($policy.grantControls.authenticationStrength.createdDateTime -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Modified Datetime</td>
                            <td>$($policy.grantControls.authenticationStrength.modifiedDateTime -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Allowed Combinations</td>
                            <td>$($policy.grantControls.authenticationStrength.allowedCombinations -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Combination Configurations</td>
                            <td>$($policy.grantControls.authenticationStrength.combinationConfigurations -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Requirements Satisfied</td>
                            <td>$($policy.grantControls.authenticationStrength.requirementsSatisfied -join ', ')</td>
                        </tr>

                    </table>
                </div>
                <br>
            </div>
            <br>

            <h3 class="collapsed session-controls" onclick="toggleContent(this)">Session Controls</h3>
            <div class="content">
                <table>
                    <tr>
                        <th>Attribute</th>
                        <th>Value</th>
                    </tr>
                    <tr>
                        <td>Application Enforced Restrictions</td>
                        <td>$($policy.sessionControls.applicationEnforcedRestrictions)</td>
                    </tr>
                    <tr>
                        <td>Cloud App Security</td>
                        <td>$($policy.sessionControls.cloudAppSecurity.isEnabled)</td>
                    </tr>
                    <tr>
                        <td>Disable Resilience Defaults</td>
                        <td>$($policy.sessionControls.disableResilienceDefaults)</td>
                    </tr>
                    <tr>
                        <td>Persistent Browser</td>
                        <td>$($policy.sessionControls.persistentBrowser.isEnabled)</td>
                    </tr>
                </table>
                <br>

                <!-- Sign In Frequency Sub-section -->
                <h3 class="collapsed sub-header" onclick="toggleContent(this, event)">Sign In Frequency</h3>
                <div class="content sub-section">
                    <table>
                        <tr>
                            <th>Attribute</th>
                            <th>Value</th>
                        </tr>
                        <tr>
                            <td>Authentication Type</td>
                            <td>$($policy.sessionControls.signInFrequency.authenticationType -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Frequency Interval</td>
                            <td>$($policy.sessionControls.signInFrequency.frequencyInterval -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Enabled</td>
                            <td>$($policy.sessionControls.signInFrequency.isEnabled -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Type</td>
                            <td>$($policy.sessionControls.signInFrequency.type -join ', ')</td>
                        </tr>
                        <tr>
                            <td>Value</td>
                            <td>$($policy.sessionControls.signInFrequency.value -join ', ')</td>
                        </tr>
                    </table>
                </div>
                <br>
            </div>
            <br>

            <h3 class="collapsed raw-json" onclick="toggleContent(this)">Raw JSON</h3>
            <div class="content">
                <pre>$($policy.ToJsonString())</pre>
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