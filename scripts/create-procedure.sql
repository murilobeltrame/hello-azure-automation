CREATE OR ALTER PROCEDURE UspExampleProc
AS
BEGIN

	DECLARE @size INT
	SET @size = 1000


	DECLARE @i INT
	BEGIN
		SET @i = 1;
		WHILE @i <= @size
		BEGIN
			INSERT INTO Example ([Data])
			VALUES (NEWID());
			SET @i = @i + 1;
		END
	END

	DELETE FROM Example WHERE Id NOT IN (
		SELECT TOP (@size) Id FROM Example ORDER BY [Data] DESC
	);

	SELECT * FROM Example ORDER BY Stamp DESC;
END;
