#!/bin/bash
#+-----------------------------------------------+
#| Checklist Oracle                                              |
#| Marina S Mariano   |
#| @date: 18/06/2020                                         |
#+-----------------------------------------------+

cd /root/chk_compasso_db
USERNAME=UOLDIVEO_DBA
PASSWORD=`cat .secret.lck | openssl enc -base64 -d -aes-256-cbc -nosalt -pass pass:garbageKey`
SAIDA=/work-tmp/checklist_compasso/chk_serverb.html
STRING_LIST_INSTANCE=list_instance.lst
STRING_LIST_DATABASE=list_database.lst
STRING_LIST_ASM=list_asm.lst
STRING_LIST_CLUSTER=list_cluster.lst

## DECLARACAO DAS FUNCOES
function query_instances() {

  if [ $1 = "diskgroup.sql"  ]; then
    for conn in `sed '/^$/d' ${STRING_LIST_ASM} | sed '/^#/d'`; do
      host=`echo "${conn}" | awk 'BEGIN{FS=":"}{print $1}'`; export host
      port=`echo "${conn}" | awk 'BEGIN{FS=":"}{print $2}'`; export port
      service_name=`echo "${conn}" |  awk 'BEGIN{FS=":"}{print $3}'`; export service_name
      connection_string_mask="(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${host})(PORT=${port}))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=${service_name})))"
      /u01/app/11.2.0/grid/bin/sqlplus -s ${USERNAME}/${PASSWORD}@"${connection_string_mask}" @$1 >> ${SAIDA}
        if [ $? != 0 ]; then
          echo "${service_name} of ${host} failed!"
        else
          echo "${service_name} of ${host} is done!"
          fi
    done
  elif [ $1 = "jobs.sql" ] || [ $1 = "tablespace.sql" ] || [ $1 = "backup.sql" ] || [ $1 = "invalid.sql" ]  ; then
      for conn in `sed '/^$/d' ${STRING_LIST_DATABASE} | sed '/^#/d'`; do
        host=`echo "${conn}" | awk 'BEGIN{FS=":"}{print $1}'`; export host
        port=`echo "${conn}" | awk 'BEGIN{FS=":"}{print $2}'`; export port
        service_name=`echo "${conn}" |  awk 'BEGIN{FS=":"}{print $3}'`; export service_name
        connection_string_mask="(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${host})(PORT=${port}))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=${service_name})))"
        sqlplus -s ${USERNAME}/${PASSWORD}@"${connection_string_mask}" @$1 >> ${SAIDA}
            if [ $? != 0 ]; then
              echo "${service_name} of ${host} failed!"
            else
              echo "${service_name} of ${host} is done!"
            fi
      done
  else
      for conn in `sed '/^$/d' ${STRING_LIST_INSTANCE} | sed '/^#/d'`; do
        host=`echo "${conn}" | awk 'BEGIN{FS=":"}{print $1}'`; export host
        port=`echo "${conn}" | awk 'BEGIN{FS=":"}{print $2}'`; export port
        service_name=`echo "${conn}" |  awk 'BEGIN{FS=":"}{print $3}'`; export service_name
        connection_string_mask="(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${host})(PORT=${port}))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=${service_name})))"
        sqlplus -s ${USERNAME}/${PASSWORD}@"${connection_string_mask}" @$1 >> ${SAIDA}
            if [ $? != 0 ]; then
              echo "${service_name} of ${host} failed!"
            else
              echo "${service_name} of ${host} is done!"
            fi
      done

    fi

}

function close_table() {
cat >> ${SAIDA} << EOF
</table>
EOF
}

# INICIO DA EXECUCAO
## Remocao de arquivo antigo gerado pelo script
#CHECKING IF FILE EXISTIS
if [ -f ${SAIDA} ]; then
  rm ${SAIDA}
fi

### Incremento do arquivos html ###
cat > ${SAIDA} << EOF
From: compasso_uol@uolinc.com
Subject: Checklist SERVIDOR 
MIME-Version: 1.0
Content-Type: multipart/mixed;
        boundary="----_=_NextPart_000_01C5B90C.9F15F690"

------_=_NextPart_000_01C5B90C.9F15F690
Content-Type: text/html;
        charset="iso-8859-1"

<!DOCTYPE html PUBliC "-//W3C//DTD html 4.0 Transitional//EN">
<html>
<head>
        <meta charset='UTF-8'>
        <title>Checklist SERVIDOR</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
* {
        margin: 0;
        padding: 0;
}
body {
        font: 14px/1.4 Arial, Serif;
}
p {
        margin: 20px 0;
}

table {
                width: 90%;
                border-collapse: collapse;
        }
tr:nth-of-type(odd) {
                background: #eee;
        }
th {
                background: #333;
                color: white;
                font-weight: bold;
        }
td, th {
                padding: 6px;
                border: 1px solid #ccc;
                font: 12px/1.4 Arial, Serif;
                text-align: left;
        }
.red{
      color:red;
        font-weight:bold;
}
.green{
    color:green;
    font-weight:bold;
}
</style>
</head>
<body>
        <div id="page-wrap">
        <h3>Checklist Ambiente PRODUCAO (SERVERA e SERVERBB) </h3>

EOF
### CABECALHO FINAL ###
### Status da instancia
cat >> ${SAIDA} << EOF
<p></p><h5>Status das instancias:</h5>
EOF

cat >> ${SAIDA} <<EOF
<table>
<tr>
        <th>Instance</th>
        <th>Status</th>
        <th>Hostname</th>
        <th>Startup Time</th>
</tr>
EOF
query_instances startup.sql
close_table

### Status da execucao de jobs
cat >> ${SAIDA} << EOF
<p></p><h5>Jobs que apresentaram erro nas ultimas 24 horas: </h5>
EOF

cat >> ${SAIDA} <<EOF
<table>
<tr>
                        <th>Instance</th>
                        <th>Owner</th>
                        <th>Job</th>
                        <th>Start_time</th>
                        <th>Status</th>
</tr>
EOF
query_instances jobs.sql
close_table

cat >> ${SAIDA} << EOF
<p></p><h5>Indices unusable (indices e suas particoes): </h5>
<p></p><h5>O REBUILD SEMPRE DEVERA SER ONLINE (ambiente Enterprise): </h5>

EOF

cat >> ${SAIDA} <<EOF
<table>
<tr>
                        <th>Instance</th>
                        <th>Indice ou Particao a ser reconstruida</th>
</tr>
EOF
query_instances index.sql
cat /tmp/t.txt | grep ';</td></tr>'  >> ${SAIDA}
close_table

### Verificacao das tablespaces
cat >> ${SAIDA} << EOF
<p></p><h5>Tablespaces com ocupacao acima de 80%: </h5>
EOF

cat >> ${SAIDA} <<EOF
<table>
<tr>
                        <th>Database</th>
                        <th>Tablespace</th>
                        <th>Used_pct</th>
</tr>
EOF
query_instances tablespace.sql
close_table

### Verificacao dos diskgroups
cat >> ${SAIDA} << EOF
<p></p><h5>Diskgroups acima de 80% (para ambiente que utilizam ASM)</h5>
EOF

cat >> ${SAIDA} <<EOF
<table>
<tr>
                        <th>Diskgroup</th>
                        <th>Used_pct</th>
</tr>
EOF
query_instances diskgroup.sql
close_table

### Verificacao dos pontos de montagem
cat >> ${SAIDA} << EOF
<p></p><h5>SERVER A - Pontos de montagem Linux acima de 80% de ocupacao</5>
EOF

cat >> ${SAIDA} <<EOF
<table>
<tr>
                        <th>Hostname</th>
                        <th>Mount_Point</th>
                        <th>Pct_used</th>
</tr>
EOF

df -Pkh  | awk '{print $6","$5}' | sed 's:%/*::' > /tmp/mountp.txt
maxpct=80
vmountp=`hostname`
 while IFS=, read -r path pct;
 do
        if [[ $pct -gt $maxpct ]];
        then
          echo "<tr><td>" $vmountp "</td><td>" $path "</td><td>" $pct "% </td></tr>" >> ${SAIDA}
        fi;
done < /tmp/mountp.txt
close_table

cat /work-tmp/checklist_compasso/chk_serverb.html >> ${SAIDA}

### Verificacao quant objetos invalidos
cat >> ${SAIDA} << EOF
<p></p><h5>Quantidade de objetos invalidos por esquema</h5>
EOF

cat >> ${SAIDA} <<EOF
<table>
<tr>
                        <th>database</th>
                        <th>quant</th>
                        <th>object_type</th>
                        <th>owner</th>
                        <th>owner</th>
</tr>
EOF
query_instances invalid.sql
close_table

### Verificacao dos backups
cat >> ${SAIDA} << EOF
<p></p><h5>Acompanhamento dos jobs de backup das ultimas 24 horas: </h5>
EOF

cat >> ${SAIDA} <<EOF
<table>
<tr>
                        <th>Database</th>
                        <th>Start_time</th>
                        <th>End_time</th>
                        <th>Input_type</th>
                        <th>Status</th>
                        <th>Elapsed_HRS/th>
</tr>
EOF
query_instances backup.sql
close_table

### Verificacao dos alerts
cat >> ${SAIDA} << EOF
<p></p><h5>Acompanhamento do Alert das ultimas 24 horas: </h5>
EOF

cat >> ${SAIDA} <<EOF
<table>
<tr>
                        <th>Database</th>
                        <th>Date_time</th>
                        <th>Message</th>
</tr>
EOF
query_instances alerts.sql
close_table

cat >> ${SAIDA} << EOF
</div>
</body>
</html>
EOF

cat "${SAIDA}"  |  /usr/lib/sendmail masoma@gmail.com


chmod 777 ${SAIDA}

exit
