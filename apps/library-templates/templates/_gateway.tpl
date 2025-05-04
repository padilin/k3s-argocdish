{{- define "library-templates._gateway.tpl" -}}
{{- range $appName, $appConfig := .Values.apps }}
{{- if $appConfig.ports }}
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
    name: {{ $appConfig.name }}-gateway
    namespace: {{ $.Release.Namespace }}
spec:
    gatewayClassName: cilium
    listeners:
    {{- range $portConfig := $appConfig.ports }}
    {{- if $portConfig.scheme }}
      - name: {{ $portConfig.name }}
        protocol: {{ $portConfig.scheme }}
        {{- if $portConfig.targetPort }}
        port: {{ $portConfig.targetPort }}
        {{- else }}
        port: {{ $portConfig.port }}
        {{- end }}
    {{- end }}
    {{- end }}
---
{{- end }}
{{- end }}
{{- end }}
