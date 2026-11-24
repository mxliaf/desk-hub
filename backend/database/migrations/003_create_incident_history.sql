USE [deskhub];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.incident_history', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.incident_history (
        id BIGINT IDENTITY(1, 1) NOT NULL,
        incident_id INT NOT NULL,
        change_type VARCHAR(30) NOT NULL,
        field_name NVARCHAR(50) NULL,
        old_value NVARCHAR(MAX) NULL,
        new_value NVARCHAR(MAX) NULL,
        changed_by INT NOT NULL,
        created_at DATETIME2(0) NOT NULL
            CONSTRAINT DF_incident_history_created_at
            DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_incident_history PRIMARY KEY (id),
        CONSTRAINT FK_incident_history_incident
            FOREIGN KEY (incident_id) REFERENCES dbo.incidents(id),
        CONSTRAINT FK_incident_history_changed_by
            FOREIGN KEY (changed_by) REFERENCES dbo.users(id),
        CONSTRAINT CK_incident_history_change_type
            CHECK (change_type IN (
                'created',
                'field_updated',
                'status_changed',
                'assigned',
                'resolved',
                'closed',
                'cancelled'
            )),
        CONSTRAINT CK_incident_history_field_name
            CHECK (
                change_type = 'created'
                OR LEN(LTRIM(RTRIM(field_name))) > 0
            )
    );

    CREATE INDEX IX_incident_history_incident_created_at
        ON dbo.incident_history (incident_id, created_at DESC);

    CREATE INDEX IX_incident_history_changed_by
        ON dbo.incident_history (changed_by);

    PRINT 'Tabela dbo.incident_history criada.';
END
ELSE
BEGIN
    PRINT 'Tabela dbo.incident_history ja existe. Nenhuma alteracao foi feita.';
END;
GO
