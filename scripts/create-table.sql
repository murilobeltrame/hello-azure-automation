IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Example' AND xtype='U')
CREATE TABLE Example (
	Id int IDENTITY(0,1) NOT NULL,
	[Data] varchar(100) NOT NULL,
	Stamp datetime DEFAULT GETDATE() NOT NULL,
	PRIMARY KEY (Id)
);
