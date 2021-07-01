SET PAGESIZE 0 LINESIZE 220 FEEDBACK OFF

select
  '<tr>' ||
  '<td>' || d.name || '</td>' ||
  '<td>' || count(*)  || '</td>' ||
  '<td>' || o.object_type || '</td>' ||
  '<td>' ||  o.owner || '</td>' ||
  '<td>' ||  o.status || '</td></tr>'
from
    dba_objects o, v$database d
where
   o.status <> 'VALID' group by o.object_type, o.status, o.owner, d.name
/
exit
