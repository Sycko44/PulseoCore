# Pulseo infra pack clean

Créé le: 20260426_143015

Ce pack prépare GitHub comme source de vérité pour le socle Pulseo.

## Contenu

- infra/scripts: scripts socle
- infra/manifests: manifests de validation
- infra/systemd: unité systemd actuelle
- infra/docs: documentation socle
- .github/workflows: validation CI uniquement

## Exclusions volontaires

Ce pack ne contient pas:
- nouvelle application
- routeur LLM applicatif
- endpoints futurs
- logique métier sensible
- déploiement automatique

## Règle

Validation uniquement.
Aucune promotion automatique.
Aucune modification directe du socle.
