# Cost-Efficient Backup Strategy for PostgreSQL

## Scenario

A SaaS platform runs a PostgreSQL production database with the following characteristics:

- Database Size: 100 GB
- Data Growth: 2 GB per day
- Compliance Requirement: Data retention for 30–90 days
- Goal: Minimise cloud cost while maintaining reliable backups and restore capability

---

# Approach 1: Daily Full Backup to Amazon S3

## Backup Strategy
A full database backup is taken daily using `pg_dump`.  
The backup file is compressed and uploaded to Amazon S3.

Example workflow:

pg_dump → gzip → upload to S3

## Retention Strategy
Backups are stored in S3 for 30 days.  
Older backups are automatically deleted using a lifecycle policy or scheduled cleanup script.

## Restore Process
To restore the database:
1. Download the latest backup file from S3
2. Decompress the backup
3. Restore using PostgreSQL restore tools

Example:

psql database < backup.sql

## Advantages
- Simple to implement
- Easy to automate
- Straightforward restore process

## Disadvantages
- Higher storage cost due to full backup every day
- Larger data transfer during restore

---

# Approach 2: Weekly Full Backup + Daily Incremental Backup

## Backup Strategy
A full backup is taken once per week.  
Daily incremental backups capture only changes since the last backup using WAL (Write Ahead Logs).

Example workflow:

Weekly Full Backup + Daily WAL/Incremental Backups

## Retention Strategy
- Weekly full backups retained for up to 90 days
- Incremental backups retained for the same retention period
- Old backups automatically deleted after retention period

## Restore Process

To restore the database:

1. Restore the latest full backup
2. Apply incremental backups (WAL logs)
3. Recover database to the desired point in time

## Advantages

- Much lower storage usage
- Faster recovery to recent point in time
- More efficient for large databases

## Disadvantages

- More complex backup management
- Restore process requires multiple steps

---

# Comparison

| Factor        | Daily Full Backup | Weekly Full + Incremental |
| Cost          | Higher storage usage | Lower storage usage   |
| Restore Speed | Moderate          | Faster                   |
| Operational Complexity | Simple   | Moderate                 |

---

# Recommendation

The recommended strategy is **Weekly Full Backup with Daily Incremental Backups**.

This approach provides the best balance between storage cost, recovery speed, and operational efficiency.  
Since only changed data is stored daily, long-term storage costs are significantly reduced while still allowing reliable recovery of the production database.
