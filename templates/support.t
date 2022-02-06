{{- define "gpg_key" -}}
{{- if eq . "3.9" -}}
    {{- /* gpg: key B26995E310250568: public key "\xc5\x81ukasz Langa (GPG langa.pl) <lukasz@langa.pl>" imported */ -}}
    E3FF2839C048B25C084DEBE9B26995E310250568
{{- else if eq . "3.10" -}}
    {{- /* gpg: key 64E628F8D684696D: public key "Pablo Galindo Salgado <pablogsal@gmail.com>" imported */ -}}
    A035C8C19219BA821ECEA86B64E628F8D684696D
{{- else if eq . "3.11" -}}
    {{- /* gpg: key 64E628F8D684696D: public key "Pablo Galindo Salgado <pablogsal@gmail.com>" imported */ -}}
    A035C8C19219BA821ECEA86B64E628F8D684696D
{{- end -}}
{{- end -}}