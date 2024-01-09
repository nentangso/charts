{{/*
Return the proper Spring Boot image name
*/}}
{{- define "spring.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "spring.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper sysctl image name
*/}}
{{- define "spring.sysctl.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.sysctl.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper caCerts initContainer image name
*/}}
{{- define "spring.caCerts.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.caCerts.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper sysctl image name
*/}}
{{- define "spring.metrics.jmx.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.metrics.jmx.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Container Image Registry Secret Names
*/}}
{{- define "spring.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image .Values.sysctl.image .Values.metrics.jmx.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "spring.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return true if a Spring Boot authentication credentials secret object should be created
*/}}
{{- define "spring.createSecret" -}}
{{- if or (not .Values.existingSecret) (and (not .Values.smtpExistingSecret) .Values.smtpPassword) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Spring Boot Secret Name
*/}}
{{- define "spring.secretName" -}}
{{- if .Values.existingSecret }}
    {{- printf "%s" (tpl .Values.existingSecret .) -}}
{{- else -}}
    {{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the SMTP Secret Name
*/}}
{{- define "spring.smtpSecretName" -}}
{{- if .Values.smtpExistingSecret }}
    {{- printf "%s" (tpl .Values.smtpExistingSecret .) -}}
{{- else -}}
    {{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Sysctl set a property if less than a given value
*/}}
{{- define "spring.sysctl.ifLess" -}}
CURRENT="$(sysctl -n {{ .key }})"
DESIRED="{{ .value }}"
if [[ "$DESIRED" -gt "$CURRENT" ]]; then
    sysctl -w {{ .key }}={{ .value }}
fi
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "spring.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "spring.validateValues.database" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{/* Validate values of Spring Boot - Database */}}
{{- define "spring.validateValues.database" -}}
{{- if and (not .Values.mysql.enabled) (or (empty .Values.externalDatabase.host) (empty .Values.externalDatabase.port) (empty .Values.externalDatabase.database)) -}}
spring: database
   You disable the MySQL installation but you did not provide the required parameters
   to use an external database. To use an external database, please ensure you provide
   (at least) the following values:

       externalDatabase.host=DB_SERVER_HOST
       externalDatabase.port=DB_SERVER_PORT
       externalDatabase.database=DB_NAME
{{- end -}}
{{- end -}}

{{/*
Set spring.jvmOpts
*/}}
{{- define "spring.jvmOpts" -}}
    {{- if and .Values.caCerts.enabled .Values.metrics.jmx.enabled -}}
        {{ printf "-Djavax.net.ssl.trustStore=/bitnami/spring/certs/cacerts -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=10443 -Dcom.sun.management.jmxremote.rmi.port=10444 %s" .Values.jvmCeOpts | trim | quote }}
    {{- else if .Values.caCerts.enabled -}}
        {{ printf "-Djavax.net.ssl.trustStore=/bitnami/spring/certs/cacerts %s" .Values.jvmCeOpts | trim | quote }}
    {{- else if .Values.metrics.jmx.enabled -}}
        {{ printf "-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=10443 -Dcom.sun.management.jmxremote.rmi.port=10444 %s" .Values.jvmCeOpts | trim | quote }}
    {{- else -}}
        {{ printf "" }}
    {{- end -}}
    {{- if .Values.jvmOpts -}}
        {{ printf "%s" .Values.jvmOpts }}
    {{- end -}}
    {{- if and .Values.metrics.datadog.enabled .Values.metrics.datadog.apmEnabled -}}
        {{ printf "%s" .Values.metrics.datadog.jvmAgentOpts }}
    {{- end -}}
    {{- if and .Values.metrics.opentelemetry.enabled -}}
        {{ printf "%s" .Values.metrics.opentelemetry.jvmAgentOpts }}
    {{- end -}}
{{- end -}}

{{/*
Set spring.jvmCEOpts
*/}}
{{- define "spring.jvmCEOpts" -}}
    {{- if .Values.caCerts.enabled -}}
        {{ printf "-Djavax.net.ssl.trustStore=/bitnami/spring/certs/cacerts %s" .Values.jvmCeOpts | trim | quote }}
    {{- else -}}
        {{ printf "" }}
    {{- end -}}
{{- end -}}

{{/*
Set spring.javaOpts
*/}}
{{- define "spring.javaOpts" -}}
    {{- if .Values.minHeapSize -}}
        {{ printf "-Xms%s " .Values.minHeapSize }}
    {{- end -}}
    {{- if .Values.maxHeapSize -}}
        {{ printf "-Xmx%s " .Values.maxHeapSize }}
    {{- end -}}
    {{ include "spring.jvmOpts" . }}
    {{ include "spring.jvmCEOpts" . }}
{{- end -}}

{{/*
Return the Spring Datasource URL
*/}}
{{- define "spring.datasource.jdbc_url" -}}
{{ include "spring.datasource.jdbc_protocol" . }}{{ include "spring.datasource.host" . }}:{{ include "spring.datasource.port" . }}/{{ include "spring.datasource.database" . }}{{ include "spring.datasource.parameters" . }}
{{- end -}}

{{/*
Return the Database jdbc protocol
*/}}
{{- define "spring.datasource.jdbc_protocol" -}}
jdbc:{{ include "spring.datasource.type" . }}://
{{- end -}}

{{/*
Return the Database type
*/}}
{{- define "spring.datasource.type" -}}
{{- if .Values.externalDatabase.type -}}
{{- printf "%s" .Values.externalDatabase.type -}}
{{- else -}}
{{- printf "%s" "mysql" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database Hostname
*/}}
{{- define "spring.datasource.host" -}}
{{- if eq "mysql" .Values.externalDatabase.type -}}
{{- ternary (include "spring.mysql.fullname" .) .Values.externalDatabase.host .Values.mysql.enabled -}}
{{- else -}}
{{- printf "%s" .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name for MySQL
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "spring.mysql.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "mysql" "chartValues" .Values.mysql "context" $) -}}
{{- end -}}

{{/*
Return the Database Port
*/}}
{{- define "spring.datasource.port" -}}
{{- if eq "mysql" .Values.externalDatabase.type -}}
{{- ternary "3306" .Values.externalDatabase.port .Values.mysql.enabled -}}
{{- else -}}
{{- printf "%d" .Values.externalDatabase.port -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database Name
*/}}
{{- define "spring.datasource.database" -}}
{{- if and (eq "mysql" .Values.externalDatabase.type) .Values.mysql.enabled }}
    {{- if .Values.global.mysql }}
        {{- if .Values.global.mysql.auth }}
            {{- coalesce .Values.global.mysql.auth.database .Values.mysql.auth.database -}}
        {{- else -}}
            {{- .Values.mysql.auth.database -}}
        {{- end -}}
    {{- else -}}
        {{- .Values.mysql.auth.database -}}
    {{- end -}}
{{- else -}}
    {{- .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database parameters
*/}}
{{- define "spring.datasource.parameters" -}}
{{- if eq "mysql" .Values.externalDatabase.type -}}
{{- printf "%s" "?useUnicode=true&characterEncoding=utf8&useSSL=false&useLegacyDatetimeCode=false&serverTimezone=UTC&createDatabaseIfNotExist=true" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database User
*/}}
{{- define "spring.datasource.username" -}}
{{- if and (eq "mysql" .Values.externalDatabase.type) .Values.mysql.enabled }}
    {{- if .Values.global.mysql }}
        {{- if .Values.global.mysql.auth }}
            {{- coalesce .Values.global.mysql.auth.username .Values.mysql.auth.username -}}
        {{- else -}}
            {{- .Values.mysql.auth.username -}}
        {{- end -}}
    {{- else -}}
        {{- .Values.mysql.auth.username -}}
    {{- end -}}
{{- else -}}
    {{- .Values.externalDatabase.user -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a db secret object should be created
*/}}
{{- define "spring.db.createSecret" -}}
{{- if and (not .Values.mysql.enabled) (not .Values.externalDatabase.existingSecret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database Secret Name
*/}}
{{- define "spring.datasource.secretName" -}}
{{- if and (eq "mysql" .Values.externalDatabase.type) .Values.mysql.enabled }}
    {{- if .Values.global.mysql }}
        {{- if .Values.global.mysql.auth }}
            {{- if .Values.global.mysql.auth.existingSecret }}
                {{- tpl .Values.global.mysql.auth.existingSecret $ -}}
            {{- else -}}
                {{- default (include "spring.mysql.fullname" .) (tpl .Values.mysql.auth.existingSecret $) -}}
            {{- end -}}
        {{- else -}}
            {{- default (include "spring.mysql.fullname" .) (tpl .Values.mysql.auth.existingSecret $) -}}
        {{- end -}}
    {{- else -}}
        {{- default (include "spring.mysql.fullname" .) (tpl .Values.mysql.auth.existingSecret $) -}}
    {{- end -}}
{{- else -}}
    {{- default (printf "%s-externaldb" (include "common.names.fullname" .)) (tpl .Values.externalDatabase.existingSecret $) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Spring r2dbc URL
*/}}
{{- define "spring.datasource.r2dbc_url" -}}
{{ include "spring.datasource.r2dbc_protocol" . }}{{ include "spring.datasource.host" . }}:{{ include "spring.datasource.port" . }}/{{ include "spring.datasource.database" . }}{{ include "spring.datasource.parameters" . }}
{{- end -}}

{{/*
Return the Database r2dbc protocol
*/}}
{{- define "spring.datasource.r2dbc_protocol" -}}
{{- if eq "mysql" .Values.externalDatabase.type -}}
r2dbc:mariadb://
{{- else -}}
r2dbc:{{ include "spring.datasource.type" . }}://
{{- end -}}
{{- end -}}

{{/*
Return the Redis&reg; server
*/}}
{{- define "spring.redis.server" -}}
{{- if .Values.redis.tls.enabled -}}
{{- printf "rediss://" -}}
{{- else -}}
{{- printf "redis://" -}}
{{- end -}}
{{- if or (and .Values.redis.enabled .Values.redis.auth.enabled) (and (not .Values.redis.enabled) (or .Values.externalRedis.password .Values.externalRedis.existingSecret)) }}
{{- printf ":%s@" "$(SPRING_REDIS_PASSWORD)" -}}
{{- end -}}
{{- include "spring.redis.host" . -}}
{{- printf ":" -}}
{{- include "spring.redis.port" . -}}
{{- end -}}

{{/*
Return the Redis&reg; hostname
*/}}
{{- define "spring.redis.host" -}}
{{- ternary (printf "%s-master" (include "spring.redis.fullname" .)) .Values.externalRedis.host .Values.redis.enabled -}}
{{- end -}}

{{/*
Return the Redis&reg; port
*/}}
{{- define "spring.redis.port" -}}
{{- ternary "6379" .Values.externalRedis.port .Values.redis.enabled -}}
{{- end -}}

{{/*
Create a default fully qualified app name
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "spring.redis.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $) -}}
{{- end -}}

{{/*
Return true if a redis secret object should be created
*/}}
{{- define "spring.redis.createSecret" -}}
{{- if and (not .Values.redis.enabled) (not .Values.externalRedis.existingSecret) .Values.externalRedis.password }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis&reg; secret name
*/}}
{{- define "spring.redis.secretName" -}}
{{- if .Values.redis.enabled }}
    {{- if .Values.redis.auth.existingSecret }}
        {{- printf "%s" .Values.redis.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" (include "spring.redis.fullname" .) -}}
    {{- end -}}
{{- else if .Values.externalRedis.existingSecret }}
    {{- printf "%s" .Values.externalRedis.existingSecret -}}
{{- else -}}
    {{- printf "%s-redis" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis&reg; secret key
*/}}
{{- define "spring.redis.secretPasswordKey" -}}
{{- if .Values.redis.enabled -}}
    {{- print "redis-password" -}}
{{- else -}}
    {{- if .Values.externalRedis.existingSecret -}}
        {{- default "redis-password" .Values.externalRedis.existingSecretPasswordKey }}
    {{- else -}}
        {{- print "redis-password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return whether Redis&reg; uses password authentication or not
*/}}
{{- define "spring.redis.auth.enabled" -}}
{{- if or (and .Values.redis.enabled .Values.redis.auth.enabled) (and (not .Values.redis.enabled) (or .Values.externalRedis.password .Values.externalRedis.existingSecret)) }}
    {{- true -}}
{{- end -}}
{{- end -}}
