{{- define "library-templates._httproute.tpl" -}}
{{- range $appName, $appConfig := .Values.apps }}
{{- if $appConfig.ports }}
{{- range $portConfig := $appConfig.ports }}
{{- if $portConfig.scheme }}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ $appConfig.name }}-route
  namespace: {{ $.Release.Namespace }}
spec:
  parentRefs:
    - name: {{ $appConfig.name }}-gateway
      namespace: {{ $.Release.Namespace }}
  hostnames:
    - "{{ $portConfig.name }}.local.gatheringhub.lan"
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: "/"
      backendRefs:
        - name: {{ $appConfig.name }}-svc
          port: {{ $portConfig.port }}
---
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
