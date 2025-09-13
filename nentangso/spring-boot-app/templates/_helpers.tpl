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
{{- define "spring.datasource.jdbcUrl" -}}
{{- .Values.spring.datasource.jdbcUrl -}}
{{- end -}}

{{/*
Return the Spring r2dbc URL
*/}}
{{- define "spring.datasource.r2dbcUrl" -}}
{{- .Values.spring.datasource.r2dbcUrl -}}
{{- end -}}

{{/*
Return the Database User
*/}}
{{- define "spring.datasource.username" -}}
{{- .Values.spring.datasource.username -}}
{{- end -}}

{{/*
Return true if a db secret object should be created
*/}}
{{- define "spring.datasource.createSecret" -}}
{{- if and .Values.spring.datasource.enabled .Values.spring.datasource.password (not .Values.spring.datasource.existingSecret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database Secret Name
*/}}
{{- define "spring.datasource.secretName" -}}
{{- default (printf "%s-spring-datasource" (include "common.names.fullname" .)) (tpl .Values.spring.datasource.existingSecret $) -}}
{{- end -}}

{{/*
Return the Redis&reg; hostname
*/}}
{{- define "spring.redis.host" -}}
{{- default "localhost" .Values.spring.redis.host -}}
{{- end -}}

{{/*
Return the Redis&reg; port
*/}}
{{- define "spring.redis.port" -}}
{{- default "6379" .Values.spring.redis.port -}}
{{- end -}}

{{/*
Return true if a redis secret object should be created
*/}}
{{- define "spring.redis.createSecret" -}}
{{- if and .Values.spring.redis.enabled .Values.spring.redis.password (not .Values.spring.redis.existingSecret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis&reg; secret name
*/}}
{{- define "spring.redis.secretName" -}}
{{- if .Values.spring.redis.existingSecret }}
    {{- printf "%s" .Values.spring.redis.existingSecret -}}
{{- else -}}
    {{- printf "%s-spring-redis" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis&reg; secret key
*/}}
{{- define "spring.redis.secretPasswordKey" -}}
{{- if .Values.spring.redis.existingSecret -}}
    {{- default "redis-password" .Values.spring.redis.existingSecretPasswordKey }}
{{- else -}}
    {{- print "redis-password" -}}
{{- end -}}
{{- end -}}

{{/*
Return whether Redis&reg; uses password authentication or not
*/}}
{{- define "spring.redis.auth.enabled" -}}
{{- if or .Values.spring.redis.password .Values.spring.redis.existingSecret }}
    {{- true -}}
{{- end -}}
{{- end -}}
