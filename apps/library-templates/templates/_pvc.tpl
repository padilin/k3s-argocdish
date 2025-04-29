{{- define "library-templates._pvc.tpl" -}}
{{- range $appConfig := .Values.apps }}
{{- range $volumeConfig := $appConfig.storage }}
{{- if eq $volumeConfig.pvc true }}
{{- if eq $volumeConfig.shared false }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ $.Values.name }}-{{ $volumeConfig.name }}-pvc
  namespace: {{ $.Release.Namespace }}
  finalizers:
    - kubernetes.io/pvc-protection
spec:
  accessModes:
    - ReadWriteOncePod
  resources:
    requests:
      storage: {{ $volConfig.size }}
  storageClassName: longhorn-arr
  volumeMode: Filesystem
---
{{- end }}
{{- end }}
{{- end }}
{{- end }}
