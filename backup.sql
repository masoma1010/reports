SET PAGESIZE 0 LINESIZE 220 FEEDBACK OFF
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';
SELECT
'<tr>' ||
'<td>' || d.DB_UNIQUE_NAME || '</td>' ||
'<td>' || b.START_TIME || '</td>' ||
'<td>' || b.END_TIME || '</td>' ||
'<td>' || b.INPUT_TYPE || '</td>' ||
'<td>' || b.STATUS || '</td>' ||
'<td>' || ROUND(b.ELAPSED_SECONDS/3600,2) || '</td></tr>'
FROM V$RMAN_BACKUP_JOB_DETAILS b,
v$database d
where (b.START_TIME > sysdate - 1 and b.INPUT_TYPE <> 'ARCHIVELOG')
or (b.START_TIME > sysdate - 1/24 and b.INPUT_TYPE = 'ARCHIVELOG')
or (b.START_TIME > sysdate - 1/24 and b.INPUT_TYPE = 'ARCHIVELOG' and b.STATUS <> 'COMPLETED')
/
exit
