SET PAGESIZE 0 LINESIZE 220 FEEDBACK OFF
column MESSAGE_TEXT format A60
select
'<tr>' ||
'<td>' || i.instance_name || '</td>' ||
'<td>' || TO_CHAR(a.ORIGINATING_TIMESTAMP, 'DD/MM/YY HH24:MI:SS') || '</td>' ||
'<td>' || a.MESSAGE_TEXT || '</td></tr>'
from    v$diag_alert_ext a, v$instance i
where a.ORIGINATING_TIMESTAMP > sysdate - 1
and  (a.MESSAGE_TEXT like '%ORA-%'
and upper(a.MESSAGE_TEXT) like '%ERROR%'
and a.MESSAGE_TEXT not like 'TNS-12518%'
and a.MESSAGE_TEXT not like 'cacatua%'
and a.MESSAGE_TEXT not like 'Fatal NI%'
and a.MESSAGE_TEXT not like 'Tns error%')
/
exit
