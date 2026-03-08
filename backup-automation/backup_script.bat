@echo off

REM Get current date
for /f "tokens=1-3 delims=/ " %%a in ("%date%") do (
set day=%%a
set month=%%b
set year=%%c
)

set folder=%year%/%month%/%day%

echo Creating database backup...

sqlite3 orders.db ".dump" > backup.sql

echo Compressing backup...

powershell Compress-Archive backup.sql backup.zip -Force

echo Uploading backup to S3...

aws s3 cp backup.zip s3://raheem-de-backup-datalake-2026/backups/postgres/%folder%/backup.zip

echo Backup uploaded successfully

echo Applying retention policy...

aws s3 rm s3://raheem-de-backup-datalake-2026/backups/postgres/ --recursive --exclude "*" --include "*backup.zip" --dryrun