USE [deskhub];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.users (
        id INT IDENTITY(1, 1) NOT NULL,
        name NVARCHAR(120) NOT NULL,
        email NVARCHAR(255) NOT NULL,
        role VARCHAR(20) NOT NULL
            CONSTRAINT DF_users_role DEFAULT ('requester'),
        created_at DATETIME2(0) NOT NULL
            CONSTRAINT DF_users_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL
            CONSTRAINT DF_users_updated_at DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_users PRIMARY KEY (id),
        CONSTRAINT UQ_users_email UNIQUE (email),
        CONSTRAINT CK_users_name_not_blank
            CHECK (LEN(LTRIM(RTRIM(name))) > 0),
        CONSTRAINT CK_users_email_not_blank
            CHECK (LEN(LTRIM(RTRIM(email))) > 0),
        CONSTRAINT CK_users_role
            CHECK (role IN ('requester', 'agent', 'admin'))
    );

    PRINT 'Tabela dbo.users criada.';
END
ELSE
BEGIN
    PRINT 'Tabela dbo.users ja existe. Nenhuma alteracao foi feita.';
END;
GO
