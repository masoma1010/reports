SET PAGESIZE 0 LINESIZE 220 FEEDBACK OFF

select
  '<tr>' ||
  '<td>' ||  a.name  || '</td>' ||
  '<td>' ||  concat(to_char(round(((total_mb-free_mb)/total_mb)*100,2),'99.99'),'%') || '</td></tr>'
from
    v$asm_diskgroup a,
    v$instance b,
    v$parameter c
where
   c.name='db_name'
   and ((total_mb-free_mb)/total_mb)*100>90
/
exit

