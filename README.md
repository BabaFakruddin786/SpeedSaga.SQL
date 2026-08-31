# SpeedSaga.SQL

SQL Server database scripts for the SpeedSaga platform.

## Requirements

- SQL Server 2019 or later
- Default database name: `SpeedSagaDB`

## Fresh install

Run the full bootstrap script in SSMS or `sqlcmd`:

```sql
-- File: SpeedSagaDB.sql
```

This creates the database, tables, indexes, stored procedures, and seed data.

## Existing database upgrades

If you already have an older SpeedSaga database, apply migration scripts in order:

1. `migrations/Updates_002_UnityFeatures.sql`
2. `migrations/Updates_003_FixUniqueNulls.sql`
3. `migrations/Updates_004_PlayablePuzzles.sql`
4. `migrations/Updates_005_AllFeatures.sql`
5. `migrations/Updates_006_LevelAllocationAndMoves.sql`
6. `migrations/Updates_007_ScaleIndexes.sql`
7. `migrations/Updates_008_HardDifficulty.sql`
8. `migrations/Updates_009_ComplexPuzzleTiers.sql`
9. `migrations/Updates_010_ArrowCountTiers.sql`
10. `migrations/Updates_011_ArrowCountTiersV2.sql`
11. `migrations/Updates_012_KycVerification.sql`
12. `migrations/Updates_013_OtpMessaging.sql`
13. `migrations/Updates_014_LaunchFeatures.sql`
14. `migrations/Updates_015_GameHistoryTimeLimit.sql`
15. `migrations/Updates_016_RegisterValidation.sql`
16. `migrations/Updates_017_RestoreLevelTiers.sql`
17. `migrations/Updates_018_ExcludePracticeFromHistory.sql`
18. `migrations/Updates_019_WithdrawOnlyGeoblock.sql`
19. `migrations/Updates_020_AppThemes.sql`
20. `migrations/Updates_021_ThemePaletteRefresh.sql`
21. `migrations/Updates_022_LinkPlayerContact.sql`
22. `migrations/Updates_023_MultiGamePlatform.sql`
23. `migrations/Updates_024_GamePlayConfig.sql`
24. `migrations/Updates_025_FreePlayTimeModes.sql`
25. `migrations/Updates_026_GamePlayLives.sql`
26. `migrations/Updates_027_KycDocumentReview.sql`
27. `migrations/Updates_028_SupportChat.sql`
28. `migrations/Updates_029_ProfileKycCompletion.sql`
29. `migrations/Updates_030_AppSupportConfig.sql`
30. `migrations/Updates_031_AppTickerConfig.sql`
31. `migrations/Updates_032_GameType.sql`
32. `migrations/Updates_033_AdminConsole.sql`
33. `migrations/Updates_034_AdminUsers.sql`

Each script is idempotent where possible and safe to re-run on partially updated databases.

## Development only

`dev/Dev_ClearAllPlayerData.sql` wipes player-related data for local testing. **Do not run in production.**

## Related repositories

- API: [SpeedSaga.API](https://github.com/BabaFakruddin786/SpeedSaga.API)
- Unity client: [SpeedSaga.Unity](https://github.com/BabaFakruddin786/SpeedSaga.Unity)
