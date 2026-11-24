USE [deskhub];
GO

SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.incidents', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.incidents (
        id INT IDENTITY(1, 1) NOT NULL,
        incident_number AS (
            'INC' + RIGHT('0000000' + CONVERT(VARCHAR(10), id), 7)
        ) PERSISTED,
        title NVARCHAR(200) NOT NULL,
        description NVARCHAR(MAX) NOT NULL,
        category NVARCHAR(100) NULL,
        impact TINYINT NOT NULL,
        urgency TINYINT NOT NULL,
        priority CHAR(2) NOT NULL,
        status VARCHAR(20) NOT NULL
            CONSTRAINT DF_incidents_status DEFAULT ('new'),
        requester_id INT NOT NULL,
        assignee_id INT NULL,
        resolution_notes NVARCHAR(MAX) NULL,
        created_at DATETIME2(0) NOT NULL
            CONSTRAINT DF_incidents_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL
            CONSTRAINT DF_incidents_updated_at DEFAULT (SYSUTCDATETIME()),
        resolved_at DATETIME2(0) NULL,
        closed_at DATETIME2(0) NULL,

        CONSTRAINT PK_incidents PRIMARY KEY (id),
        CONSTRAINT FK_incidents_requester
            FOREIGN KEY (requester_id) REFERENCES dbo.users(id),
        CONSTRAINT FK_incidents_assignee
            FOREIGN KEY (assignee_id) REFERENCES dbo.users(id),
        CONSTRAINT CK_incidents_title_not_blank
            CHECK (LEN(LTRIM(RTRIM(title))) > 0),
        CONSTRAINT CK_incidents_description_not_blank
            CHECK (LEN(LTRIM(RTRIM(description))) > 0),
        CONSTRAINT CK_incidents_impact
            CHECK (impact BETWEEN 1 AND 3),
        CONSTRAINT CK_incidents_urgency
            CHECK (urgency BETWEEN 1 AND 3),
        CONSTRAINT CK_incidents_priority
            CHECK (priority IN ('P1', 'P2', 'P3', 'P4')),
        CONSTRAINT CK_incidents_status
            CHECK (status IN (
                'new',
                'in_progress',
                'pending',
                'resolved',
                'closed',
                'cancelled'
            )),
        CONSTRAINT CK_incidents_resolved_at
            CHECK (
                status NOT IN ('resolved', 'closed')
                OR resolved_at IS NOT NULL
            ),
        CONSTRAINT CK_incidents_closed_at
            CHECK (status <> 'closed' OR closed_at IS NOT NULL),
        CONSTRAINT CK_incidents_resolution_dates
            CHECK (
                (resolved_at IS NULL OR resolved_at >= created_at)
                AND (closed_at IS NULL OR closed_at >= created_at)
            )
    );

    CREATE UNIQUE INDEX UX_incidents_incident_number
        ON dbo.incidents (incident_number);

    CREATE INDEX IX_incidents_status_priority
        ON dbo.incidents (status, priority);

    CREATE INDEX IX_incidents_requester_id
        ON dbo.incidents (requester_id);

    CREATE INDEX IX_incidents_assignee_id
        ON dbo.incidents (assignee_id)
        WHERE assignee_id IS NOT NULL;

    CREATE INDEX IX_incidents_created_at
        ON dbo.incidents (created_at DESC);

    PRINT 'Tabela dbo.incidents criada.';
END
ELSE
BEGIN
    PRINT 'Tabela dbo.incidents ja existe. Nenhuma alteracao foi feita.';
END;
GO
