# Socle minimal protégé Pulseo

Date: 20260426_143004

## Principe

Aucune nouvelle application ne modifie directement le socle.

Flux obligatoire:

1. intention humaine
2. manifest
3. simulation
4. sandbox
5. vérification
6. receipt
7. validation
8. promotion contrôlée

## Services essentiels

- nginx.service
- ollama.service
- pulseo-minimum.service

## Exposition réseau attendue

Public:
- 22 SSH
- 80 HTTP
- 443 HTTPS

Local uniquement:
- 8000 Pulseo Minimum
- 8200 Vault
- 11434 Ollama

## Hors périmètre

Ce socle ne contient pas:

- nouvelle application
- logique métier future
- endpoint applicatif futur
- automatisation de déploiement
- routage applicatif spécialisé

## Statut

Le socle minimal protégé sert uniquement de base stable.
Toute greffe applicative doit être conçue plus tard, séparément, avec son propre manifest et sa propre validation.
