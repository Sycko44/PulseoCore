# Architecture courante Pulseo

Date: 20260426_143004

## Rôles

- GitHub: source de vérité cible
- VPS: exécuteur contrôlé
- Sandbox: zone d'essai
- Audit-VPS / PulseoOS: simulation, vérification, receipts
- Assistant: orchestration, génération, analyse

## Socle actif

Pulseo Minimum est actif via:

- systemd: pulseo-minimum.service
- bind applicatif: 127.0.0.1:8000
- proxy public: Nginx / https://pulseo.me
- LLM local: Ollama
- modèle lourd actuel: qwen3:14b
- modèle léger actuel: llama3.2:3b

## État legacy

Le legacy pulseo_chat / 7860 est archivé et ne doit pas redevenir persistant sans manifest validé.

## Règle d'évolution

Toute évolution future doit être traitée comme une greffe séparée:

1. intention humaine
2. manifest
3. simulation
4. sandbox
5. vérification
6. receipt
7. validation
8. promotion contrôlée

Ce document ne décrit que le socle courant.
