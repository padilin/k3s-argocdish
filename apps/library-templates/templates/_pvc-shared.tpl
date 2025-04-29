{{- define "library-templates._pvc.tpl" -}}
{{- range $appName, $appConfig := .Values.apps }}
{{- range $volName, $volConfig := $appConfig.storage }}
{{- if $volConfig.pvc }}
{{- if $volConfig.shared }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: arr-{{ $volName }}-pvc
  namespace: {{ $.Release.Namespace }}
  finalizers:
    - kubernetes.io/pvc-protection
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: {{ $volConfig.size }}
  storageClassName: longhorn-arr
  volumeMode: Filesystem
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
