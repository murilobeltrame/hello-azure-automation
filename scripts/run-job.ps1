Write-Information "Starting Randomizing DB"

$SQLServer = 'tstrgdbserver.database.windows.net'
$SQLDatabase = 'tstrgdb'
$SQLUser = '4dm1n157r470r'
$SQLPassword = '4-v3ry-53cr37-p455w0rd'
$SQLConnection = New-Object System.Data.SqlClient.SqlConnection
$SQLConnection.ConnectionString = "Server=tcp:$SQLServer,1433;Initial Catalog=$SQLDatabase;Persist Security Info=False;User ID=$SQLUser;Password=$SQLPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

$SQLQuery = 'dbo.UspExampleProc'
Write-Information "Running $SQLQuery"
$SQLCommand = New-Object System.Data.SqlClient.SqlCommand($SQLQuery, $SQLConnection)
$SQLConnection.Open()
$SQLCommand.ExecuteScalar()
$SQLCommand.Close()

Write-Information "Finished Randomizing DB"