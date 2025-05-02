{{- define "library-templates._pvc-shared.tpl" -}}
{{- range $appName, $appConfig := .Values.apps }}
{{- range $volumeName, $volumeConfig := $appConfig.storage }}
{{- if $volumeConfig.pvc }}
{{- if $volumeConfig.shared }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: arr-shared-{{ $volumeConfig.name }}-pvc
  namespace: {{ $.Release.Namespace }}
  finalizers:
    - kubernetes.io/pvc-protection
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: {{ $volumeConfig.size }}
  storageClassName: longhorn-arr
  volumeMode: Filesystem
---
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
