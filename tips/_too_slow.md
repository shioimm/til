# サイトが重い場合
## DB要因
- RDSのPerformance Insightsを確認

#### 現在進行系で長時間実行されているクエリが存在していないかを確認

```sql
select * from pg_stat_activity where usename = '<username>' order by query_start;
```

#### 当該時間帯にautovacuum / autoanalyzeしていなかったかを確認

```sql
-- vacuum / analyze履歴
select relname, seq_scan, last_vacuum, last_autovacuum, last_autoanalyze, autovacuum_count, analyze_count, autoanalyze_count from pg_stat_all_tables order by last_autoanalyze desc nulls last, last_autovacuum desc nulls last limit 10;
```
