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
Return the proper install_plugins initContainer image name
*/}}
{{- define "spring.plugins.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.plugins.image "global" .Values.global) }}
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
Create a default fully qualified app name for MySQL
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "spring.mysql.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "mysql" "chartValues" .Values.mysql "context" $) -}}
{{- end -}}

{{/*
Create a default fully qualified app name
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "spring.redis.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $) -}}
{{- end -}}

{{/*
Return the Database Hostname
*/}}
{{- define "spring.datasource.host" -}}
{{- ternary (include "spring.mysql.fullname" .) .Values.externalDatabase.host .Values.mysql.enabled -}}
{{- end -}}


{{/*
Return the Database parameter
*/}}
{{- define "spring.datasource.parameter" -}}
{{- if not .Values.postgres.enabled -}}
{{- printf "%s" "?useUnicode=true&characterEncoding=utf8&useSSL=false&useLegacyDatetimeCode=false&serverTimezone=UTC&createDatabaseIfNotExist=true" -}}
{{- else -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database architecture
*/}}
{{- define "spring.datasource.architecture" -}}
{{- if .Values.postgres.enabled -}}
{{- printf "%s" "postgresql" -}}
{{- else -}}
{{- printf "%s" "mysql" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database Port
*/}}
{{- define "spring.datasource.port" -}}
{{- ternary "5432" .Values.externalDatabase.port .Values.mysql.enabled -}}
{{- end -}}

{{/*
Return the Database Name
*/}}
{{- define "spring.datasource.database" -}}
{{- if .Values.mysql.enabled }}
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
Return the Database User
*/}}
{{- define "spring.datasource.username" -}}
{{- if .Values.mysql.enabled }}
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
Return the Database Secret Name
*/}}
{{- define "spring.datasource.secretName" -}}
{{- if .Values.mysql.enabled }}
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
Return the Spring Datasource URL
*/}}
{{- define "spring.datasource.url" -}}
jdbc:{{ include "spring.datasource.architecture" . }}://{{ include "spring.datasource.host" . }}:{{ include "spring.datasource.port" . }}/{{ include "spring.datasource.database" . }}{{ include "spring.datasource.parameter" . }}
{{- end -}}

{{/*
Return the Spring r2dbc URL
*/}}
{{- define "spring.r2dbc.url" -}}
r2dbc:mariadb://{{ include "spring.datasource.host" . }}:{{ include "spring.datasource.port" . }}/{{ include "spring.datasource.database" . }}?useUnicode=true&characterEncoding=utf8&useSSL=false&useLegacyDatetimeCode=false&serverTimezone=UTC&createDatabaseIfNotExist=true
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
Return the Redis&reg; server
*/}}
{{- define "spring.redis.server" -}}
{{- printf "redis://" -}}
{{- if or (and .Values.redis.enabled .Values.redis.auth.enabled) (and (not .Values.redis.enabled) (or .Values.externalRedis.password .Values.externalRedis.existingSecret)) }}
{{- printf ":%s@" "$(SPRING_REDIS_PASSWORD)" -}}
{{- end -}}
{{- include "spring.redis.host" . -}}
{{- printf ":" -}}
{{- include "spring.redis.port" . -}}
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

# value for keycloak

{{- define "spring.keycloak.provider.oidc.issuer-uri" -}}
{{- printf "%s" .Values.externalKeycloak.provider.oidc.issuerUri -}}
{{- end -}}

{{- define "spring.keycloak.registration.oidc.client" -}}
{{- printf "%s" .Values.externalKeycloak.registration.oidc.client -}}
{{- end -}}

{{- define "spring.keycloak.registration.oidc.client-secret" -}}
{{- printf "%s" .Values.externalKeycloak.registration.oidc.clientSecret -}}
{{- end -}}

{{- define "spring.keycloak.registration.oidc.scope" -}}
{{- printf "%s" .Values.externalKeycloak.registration.oidc.scope -}}
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
Return true if a redis secret object should be created
*/}}
{{- define "spring.redis.createSecret" -}}
{{- if and (not .Values.redis.enabled) (not .Values.externalRedis.existingSecret) .Values.externalRedis.password }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a keycloak secret object should be created
*/}}
{{- define "spring.keycloak.registration.oidc.createSecret" -}}
{{- if and (not .Values.keycloak.enabled) (not .Values.externalKeycloak.registration.oidc.existingSecretName) .Values.externalKeycloak.registration.oidc.clientSecret }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the keycloak secret name
*/}}
{{- define "spring.keycloak.registration.oidc.secretName" -}}
{{- if .Values.keycloak.enabled }}
    {{- printf "%s" (include "spring.keycloak.fullname" .) -}}
{{- else if .Values.externalKeycloak.registration.oidc.existingSecretName }}
    {{- printf "%s" .Values.externalKeycloak.registration.oidc.existingSecretName -}}
{{- else -}}
    {{- printf "%s-keycloak" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the keycloak secret key
*/}}
{{- define "spring.keycloak.registration.oidc.clientSecretKey" -}}
{{- if .Values.keycloak.enabled -}}
    {{- print "oidc-client-secret" -}}
{{- else -}}
    {{- if .Values.externalKeycloak.registration.oidc.existingSecretName -}}
        {{- default "oidc-client-secret" .Values.externalKeycloak.registration.oidc.existingSecretKey }}
    {{- else -}}
        {{- print "oidc-client-secret" -}}
    {{- end -}}
{{- end -}}
{{- end -}}
