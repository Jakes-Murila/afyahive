$ErrorActionPreference = 'Stop'
$base = 'http://localhost/afyahive/api.php?route='
$results = [System.Collections.Generic.List[object]]::new()

function Invoke-AfyaApi {
    param([string]$Name, [string]$Method, [string]$Route, $Payload, [string]$Token)
    try {
        $params = @{ Uri = "$base$Route"; Method = $Method; ContentType = 'application/json'; ErrorAction = 'Stop' }
        if ($null -ne $Payload) { $params.Body = $Payload | ConvertTo-Json -Depth 5 -Compress }
        if ($Token) { $params.Headers = @{ Authorization = "Bearer $Token" } }
        $response = Invoke-RestMethod @params
        if (-not $response.success) { throw $response.message }
        $results.Add([pscustomobject]@{ endpoint = $Name; status = 'PASS'; message = $response.message })
        return $response.data
    } catch {
        $results.Add([pscustomobject]@{ endpoint = $Name; status = 'FAIL'; message = $_.Exception.Message })
        return $null
    }
}

Invoke-AfyaApi 'GET /health' 'GET' 'health' $null $null | Out-Null
$login = Invoke-AfyaApi 'POST /v1/auth/login' 'POST' 'v1/auth/login' @{ email = 'jakesmreal6@gmail.com'; password = '1234' } $null
if ($null -eq $login) { $results | ConvertTo-Json; exit 1 }
$testEmail = "api-verification-$(Get-Date -Format yyyyMMddHHmmss)@example.test"
$testSession = Invoke-AfyaApi 'POST /v1/auth/register' 'POST' 'v1/auth/register' @{ firstname = 'API'; lastname = 'Verification'; email = $testEmail; password = 'SecureTest123!' } $null
if ($null -eq $testSession) { $results | ConvertTo-Json; exit 1 }
$token = $testSession.accessToken

Invoke-AfyaApi 'GET /v1/profile' 'GET' 'v1/profile' $null $token | Out-Null
Invoke-AfyaApi 'PUT /v1/profile' 'PUT' 'v1/profile' @{ gender = 'Other'; date_of_birth = '1992-06-15'; height_cm = 172.5; current_weight = 68.2; target_weight = 65.0 } $token | Out-Null
Invoke-AfyaApi 'GET /v1/dashboard' 'GET' 'v1/dashboard' $null $token | Out-Null
Invoke-AfyaApi 'GET /v1/vitals' 'GET' 'v1/vitals&range=week' $null $token | Out-Null
$vital = Invoke-AfyaApi 'POST /v1/vitals' 'POST' 'v1/vitals' @{ type = 'heart_rate'; value = 72; unit = 'bpm'; source = 'test' } $token
if ($vital) { & C:\xampp\mysql\bin\mysql.exe -u root afyahive --execute "DELETE FROM vital_readings WHERE id = $($vital.id)" }

$resources = @(
    @{ route = 'activities'; body = @{ activity_type = 'Walking'; duration_minutes = 30; calories_burned = 120; distance_km = 2.4; activity_date = '2026-08-13'; notes = 'Test' }; patch = @{ notes = 'Updated' } },
    @{ route = 'workouts'; body = @{ workout_name = 'Test'; workout_type = 'Cardio'; duration_burned = 25; calories_burned = 190; intensity = 'Medium'; workout_dates = '2026-08-13'; notes = 'Test' }; patch = @{ intensity = 'High' } },
    @{ route = 'fitness-goals'; body = @{ goal_type = 'Maintain Weight'; target_weight = 65; target_steps = 7000; target_calories = 500; start_date = '2026-08-13'; end_date = '2026-12-31'; status = 'Active' }; patch = @{ status = 'Completed' } },
    @{ route = 'progress-logs'; body = @{ weight_kg = 68.2; bmi = 23.1; log_date = '2026-08-13' }; patch = @{ bmi = 23.2 } },
    @{ route = 'appointments'; body = @{ provider_name = 'Dr Test'; specialty = 'General'; scheduled_at = '2026-09-01 09:00:00'; location = 'Test Clinic'; mode = 'in_person'; status = 'scheduled'; notes = 'Test' }; patch = @{ status = 'cancelled' } },
    @{ route = 'reminders'; body = @{ medication_name = 'Vitamin D'; dosage = '1 tablet'; schedule_time = '09:00:00'; frequency = 'daily'; is_active = $true; notes = 'Test' }; patch = @{ is_active = $false } },
    @{ route = 'emergency-contacts'; body = @{ name = 'Test Contact'; relationship = 'Friend'; phone = '+254700000000'; is_primary = $true }; patch = @{ is_primary = $false } },
    @{ route = 'medical-records'; body = @{ record_type = 'document'; title = 'Test Record'; details = 'Test-only'; issued_at = '2026-08-13' }; patch = @{ title = 'Updated Test Record' } },
    @{ route = 'telemedicine'; body = @{ provider_name = 'Dr Video'; scheduled_at = '2026-09-02 10:00:00'; meeting_url = 'https://example.test/meeting'; status = 'scheduled' }; patch = @{ status = 'cancelled' } },
    @{ route = 'community-posts'; body = @{ body = 'Temporary test post'; is_anonymous = $true }; patch = @{ is_anonymous = $false } }
)

foreach ($resource in $resources) {
    Invoke-AfyaApi "GET /v1/$($resource.route)" 'GET' "v1/$($resource.route)" $null $token | Out-Null
    $item = Invoke-AfyaApi "POST /v1/$($resource.route)" 'POST' "v1/$($resource.route)" $resource.body $token
    if ($item) {
        Invoke-AfyaApi "GET /v1/$($resource.route)/id" 'GET' "v1/$($resource.route)/$($item.id)" $null $token | Out-Null
        Invoke-AfyaApi "PATCH /v1/$($resource.route)/id" 'PATCH' "v1/$($resource.route)/$($item.id)" $resource.patch $token | Out-Null
        Invoke-AfyaApi "DELETE /v1/$($resource.route)/id" 'DELETE' "v1/$($resource.route)/$($item.id)" $null $token | Out-Null
    }
}

Invoke-AfyaApi 'GET /v1/ai/conversations' 'GET' 'v1/ai/conversations' $null $token | Out-Null
$conversation = Invoke-AfyaApi 'POST /v1/ai/conversations' 'POST' 'v1/ai/conversations' @{ title = 'Temporary test' } $token
if ($conversation) {
    Invoke-AfyaApi 'GET /v1/ai/conversations/id' 'GET' "v1/ai/conversations/$($conversation.id)" $null $token | Out-Null
    Invoke-AfyaApi 'POST /v1/ai/conversations/id' 'POST' "v1/ai/conversations/$($conversation.id)" @{ content = 'Temporary test message' } $token | Out-Null
    & C:\xampp\mysql\bin\mysql.exe -u root afyahive --execute "DELETE FROM ai_conversations WHERE id = $($conversation.id)"
}
Invoke-AfyaApi 'POST /v1/auth/logout' 'POST' 'v1/auth/logout' @{} $token | Out-Null
& C:\xampp\mysql\bin\mysql.exe -u root afyahive --execute "DELETE FROM users WHERE email = '$testEmail'"
$results | ConvertTo-Json -Depth 3
if (@($results | Where-Object status -eq 'FAIL').Count -gt 0) { exit 1 }
