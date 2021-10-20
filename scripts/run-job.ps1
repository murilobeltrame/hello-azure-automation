Write-Information "Starting Randomizing DB"

$SQLServer = 'tstrgdbserver.database.windows.net'
$SQLDatabase = 'tstrgdb'
$SQLCredential = Get-AutomationPSCredential -Name 'dbcredential'
$SQLUser = $SQLCredential.UserName
$SQLPassword = $SQLCredential.GetNetworkCredential().Password
$SQLConnection = New-Object System.Data.SqlClient.SqlConnection
$SQLConnection.ConnectionString = "Server=tcp:$SQLServer,1433;Initial Catalog=$SQLDatabase;Persist Security Info=False;User ID=$SQLUser;Password=$SQLPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

$SQLQuery = 'dbo.UspExampleProc'
Write-Information "Running $SQLQuery"
$SQLCommand = New-Object System.Data.SqlClient.SqlCommand($SQLQuery, $SQLConnection)
$SQLConnection.Open()
$SQLCommand.ExecuteScalar()
$SQLConnection.Close()

Write-Information "Finished Randomizing DB"