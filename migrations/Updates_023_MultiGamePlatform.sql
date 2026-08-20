-- SpeedSaga Updates 023: Multi-game platform (Arrow, Car Parking, Tic Tac Toe)
SET NOCOUNT ON;
GO

IF COL_LENGTH('GameSessions', 'GameType') IS NULL
BEGIN
    ALTER TABLE GameSessions ADD GameType NVARCHAR(32) NOT NULL
        CONSTRAINT DF_GameSessions_GameType DEFAULT 'arrow';
END
GO

UPDATE GameSessions SET GameType = 'arrow' WHERE GameType IS NULL OR GameType = '';
GO

IF COL_LENGTH('MatchmakingQueue', 'GameType') IS NULL
BEGIN
    ALTER TABLE MatchmakingQueue ADD GameType NVARCHAR(32) NOT NULL
        CONSTRAINT DF_MatchmakingQueue_GameType DEFAULT 'arrow';
END
GO

UPDATE MatchmakingQueue SET GameType = 'arrow' WHERE GameType IS NULL OR GameType = '';
GO

IF OBJECT_ID('Games', 'U') IS NULL
BEGIN
    CREATE TABLE Games (
        GameId          NVARCHAR(32)    NOT NULL PRIMARY KEY,
        DisplayName     NVARCHAR(80)    NOT NULL,
        Description     NVARCHAR(300)   NULL,
        IconKey         NVARCHAR(40)    NULL,
        SortOrder       INT             NOT NULL DEFAULT 0,
        IsEnabled       BIT             NOT NULL DEFAULT 1,
        SupportsFreePlay BIT            NOT NULL DEFAULT 1,
        SupportsSinglePlayer BIT        NOT NULL DEFAULT 1,
        SupportsTwoPlayer BIT           NOT NULL DEFAULT 0,
        SupportsTournament BIT          NOT NULL DEFAULT 0,
        CreatedAt       DATETIME2       NOT NULL DEFAULT GETDATE()
    );

    INSERT INTO Games (GameId, DisplayName, Description, IconKey, SortOrder, SupportsTwoPlayer, SupportsTournament)
    VALUES
        ('arrow', 'Arrow Puzzle', 'Clear arrows from the board before time runs out.', 'arrow', 1, 1, 1),
        ('car_parking', 'Car Parking', 'Slide cars and free the red vehicle from the lot.', 'car', 2, 0, 0),
        ('tic_tac_toe', 'Tic Tac Toe', 'Classic 3x3 — play vs AI or challenge a friend.', 'grid', 3, 1, 0);
END
GO

CREATE OR ALTER PROCEDURE USP_MatchmakingJoin
    @PlayerId       UNIQUEIDENTIFIER,
    @FeePaise       BIGINT,
    @TimeSecs       INT,
    @ConnId         NVARCHAR(200),
    @GameType       NVARCHAR(32) = 'arrow',
    @SessionId      UNIQUEIDENTIFIER    OUTPUT,
    @IsNewSession   BIT                 OUTPUT,
    @OpponentId     UNIQUEIDENTIFIER    OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IsNewSession = 0; SET @OpponentId = NULL;
    IF @GameType IS NULL OR LTRIM(RTRIM(@GameType)) = '' SET @GameType = 'arrow';

    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @WaitId UNIQUEIDENTIFIER, @WaitPlayerId UNIQUEIDENTIFIER;
        SELECT TOP 1 @WaitId = QueueId, @WaitPlayerId = PlayerId
        FROM MatchmakingQueue WITH (UPDLOCK, ROWLOCK)
        WHERE EntryFeePaise = @FeePaise AND TimeLimitSecs = @TimeSecs
          AND GameType = @GameType
          AND Status = 'Waiting' AND PlayerId <> @PlayerId
          AND DATEDIFF(SECOND, JoinedAt, GETDATE()) < 60
        ORDER BY JoinedAt;

        IF @WaitPlayerId IS NOT NULL
        BEGIN
            SET @SessionId = NEWID();
            SET @OpponentId = @WaitPlayerId;

            INSERT INTO GameSessions (SessionId, Player1Id, Player2Id, GameMode, GameType, EntryFeePaise,
                RewardPaise, TimeLimitSecs, Status, StartedAt, SignalRGroupId)
            VALUES (@SessionId, @WaitPlayerId, @PlayerId, 'TwoPlayer', @GameType,
                @FeePaise, CAST(@FeePaise * 2 * 0.85 AS BIGINT), @TimeSecs,
                'Active', GETDATE(), CAST(@SessionId AS NVARCHAR(50)));

            UPDATE MatchmakingQueue
            SET Status = 'Matched', MatchedAt = GETDATE(), MatchedSessionId = @SessionId
            WHERE QueueId = @WaitId;

            INSERT INTO MatchmakingQueue (PlayerId, EntryFeePaise, TimeLimitSecs, SignalRConnId, GameType, Status, MatchedAt, MatchedSessionId)
            VALUES (@PlayerId, @FeePaise, @TimeSecs, @ConnId, @GameType, 'Matched', GETDATE(), @SessionId);
        END
        ELSE
        BEGIN
            SET @IsNewSession = 1;
            INSERT INTO MatchmakingQueue (PlayerId, EntryFeePaise, TimeLimitSecs, SignalRConnId, GameType, Status)
            VALUES (@PlayerId, @FeePaise, @TimeSecs, @ConnId, @GameType, 'Waiting');
        END

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK; THROW;
    END CATCH
END
GO
