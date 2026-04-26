# RUNBOOK VPS Pulseo

## Principe

Le VPS est un exécuteur contrôlé.
GitHub devient la source de vérité.
Le socle actif ne doit pas être modifié directement.

## Flux cible

1. Pull request GitHub
2. validation CI
3. manifest
4. simulation sandbox
5. vérification
6. receipt
7. validation humaine
8. promotion contrôlée

## Services critiques

- nginx.service
- ollama.service
- pulseo-minimum.service

## Ports attendus

Public:
- 22 SSH
- 80 HTTP
- 443 HTTPS

Local:
- 8000 Pulseo Minimum
- 8200 Vault
- 11434 Ollama

## Legacy

Le port 7860 / pulseo_chat est archivé.
Il ne doit pas être relancé sans manifest validé.

## Règle de protection

Aucune nouvelle application ne doit être ajoutée dans ce pack.
Ce pack sert uniquement à figer, auditer et valider le socle minimal.
