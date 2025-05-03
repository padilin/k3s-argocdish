{{- define "library-templates._deployment.tpl" -}}
{{- range $appConfig := .Values.apps }} {{- /* Loop through each app defined in values */}}
{{- if $appConfig.enabled }}
{{- if eq $appConfig.kind "deployment" }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $.Values.name }}-{{ $appConfig.name }}
  namespace: {{ $.Release.Namespace }}
  labels:
    helm.sh/chart: {{ $.Values.name }}-{{ $.Chart.Version }}
    app.kubernetes.io/name: {{ $.Values.name }}-{{ $appConfig.name }}
    app.kubernetes.io/instance: {{ $.Release.Name }}
    {{- if $.Chart.AppVersion }}
    app.kubernetes.io/version: {{ $.Chart.AppVersion | quote }}
    {{- end }}
    app.kubernetes.io/managed-by: {{ $.Release.Service }}
    app.kubernetes.io/component: {{ $appConfig.name }}
spec:
  replicas: {{ $appConfig.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ $.Values.name }}-{{ $appConfig.name }}
      app.kubernetes.io/instance: {{ $.Release.Name }}
      app.kubernetes.io/component: {{ $appConfig.name }}
  strategy:
    type: Recreate
  revisionHistoryLimit: 3
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ $.Values.name }}-{{ $appConfig.name }}
        app.kubernetes.io/instance: {{ $.Release.Name }}
        app.kubernetes.io/component: {{ $appConfig.name }}
    spec:
      containers:
      {{- if $appConfig.gluetun }}
        - name: {{ $appConfig.name }}-gluetun
          image: qmcgaw/gluetun
          imagePullPolicy: Always
          ports:
            - name: http-proxy
              containerPort: 8888
              protocol: TCP
            - name: tcp-shadowsocks
              containerPort: 8388
              protocol: TCP
            - name: udp-shadowsocks
              containerPort: 8388
              protocol: UDP
          securityContext:
            runAsUser: 0
            capabilities:
              add: ["NET_ADMIN"]
          volumeMounts:
            - name: arr-{{ $appConfig.name }}-gluetun
              mountPath: /gluetun
          env:
            {{- range $envVar := $appConfig.gluetun.env }}
            - name: {{ $envVar.name }}
              {{- if $envVar.value }}
              value: {{ $envVar.value | quote }}
              {{- else if $envVar.valueFrom }}
              valueFrom:
                {{- toYaml $envVar.valueFrom | nindent 16 }}
              {{- end }}
            {{- end }}
        {{- end }}
        - name: {{ $appConfig.name }} # Container name based on the app key
          image: "{{ $appConfig.image.repository }}:{{ $appConfig.image.tag }}"
          imagePullPolicy: {{ $appConfig.image.pullPolicy }}
          {{- if $appConfig.root }}
          securityContext:
            runAsUser: 0
          {{- end }}
          {{- if $appConfig.resources }}
          resources:
            {{- toYaml $appConfig.resources | nindent 12 }}
          {{- end }}
          {{- if $appConfig.env }}
          env:
            {{- range $envVar := $appConfig.env }}
            - name: {{ $envVar.name }}
              {{- if $envVar.value }}
              value: {{ $envVar.value | quote }}
              {{- else if $envVar.valueFrom }}
              valueFrom:
                {{- toYaml $envVar.valueFrom | nindent 16 }}
              {{- end }}
            {{- end }}
          {{- end }}
          volumeMounts:
            {{- range $volumeConfig := $appConfig.storage }}
              {{- if $volumeConfig.shared }}
            - name: arr-shared-{{ $volumeConfig.name }}-pvc
              {{- else }}
            - name: arr-{{ $appConfig.name }}-{{ $volumeConfig.name }}-pvc
              {{- end }}
              mountPath: {{ $volumeConfig.path }}
              {{- if $volumeConfig.subPath }}
              subPath: {{ $volumeConfig.subPath }}
              {{- end }}
            {{- end }}
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
      affinity:
        {{- if $appConfig.affinity }}
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                - key: storage-type
                  operator: In
                  values:
                    - nvme
        {{- end }}
      volumes:
        {{- if $appConfig.gluetun }}
        - name: arr-{{ $appConfig.name }}-gluetun
          emptyDir:
        {{- end }}
        {{- range $volumeConfig := $appConfig.storage }}
        {{- if $volumeConfig.pvc }}
          {{- if $volumeConfig.shared }}
        - name: arr-shared-{{ $volumeConfig.name }}-pvc
          {{- else }}
        - name: arr-{{ $appConfig.name }}-{{ $volumeConfig.name }}-pvc
          {{- end }}
          persistentVolumeClaim:
            {{- if $volumeConfig.shared }}
            claimName: arr-shared-{{ $volumeConfig.name }}-pvc
            {{- else }}
            claimName: arr-{{ $appConfig.name }}-{{ $volumeConfig.name }}-pvc
            {{- end }}
        {{- else if $volumeConfig.hostPath }}
        - name: arr-{{ $appConfig.name }}-{{ $volumeConfig.name }}-pvc
          hostPath:
            path: {{ $volumeConfig.hostPath }}
        {{- end }}
        {{- end }}
---
{{- end }}
{{- end }}
{{- end }}
{{- end }}
