{{/*
Return the full name of the chart
*/}}
{{- define "mychart.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Short name (optional)
*/}}
{{- define "mychart.name" -}}
{{- .Chart.Name -}}
{{- end -}}
