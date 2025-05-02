{{- define "library-template._service.tpl" }}
{{- range $appName, $appConfig := .Values.apps }}
{{- if $appConfig.ports }}
---
apiVersion: v1
kind: Service
metadata:
    name: {{ $appName }}-svc
spec:
  selector:
    app.kubernetes.io/name: {{ $.Values.name }}-{{ $appConfig.name }}
  ports:
  {{- range $portConfig := $appConfig.ports }}
    - protocol: {{ $portConfig.protocol }}
      port: {{ $portConfig.port }}
      targetPort: {{ $port.targetPort }}
  {{- end }}
---
{{- end }}
{{- end }}
{{- end }}
