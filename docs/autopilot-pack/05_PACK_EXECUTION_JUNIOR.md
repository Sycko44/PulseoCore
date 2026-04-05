# 05 - Pack d'execution junior

## 1. Objet

Transformer Pulseo 1.2 en kit de depart concret pour une equipe junior encadree.

## 2. But

Faire en sorte qu'une equipe puisse commencer a produire sans dependre d'arbitrages oraux permanents.

## 3. Contenu minimum du pack

### 3.1 Documentation de reference
- canon Pulseo 1.2 ;
- registre maitre d'avancement ;
- Mobile Release Spec ;
- Design System ;
- lot 33.

### 3.2 Contrats techniques
- `openapi.yaml` reel ;
- schemas evenements ;
- exemples payloads ;
- conventions erreurs ;
- auth flow.

### 3.3 Repo et bootstrap
- structure monorepo ;
- `README` setup ;
- `docker-compose` dev ;
- scripts bootstrap ;
- `.env.example` ;
- seed data ;
- commandes de test.

### 3.4 Delivery
- backlog par sprint ;
- Definition of Ready ;
- Definition of Done ;
- conventions PR ;
- conventions branches ;
- regles review ;
- checklist release.

### 3.5 Runtime
- deploy VPS ;
- staging ;
- prod ;
- monitoring ;
- rollback ;
- health checks ;
- sauvegardes.

## 4. Definition of Ready par ticket

Un ticket est pret si :

- son objectif est clair ;
- son perimetre est borné ;
- les dependances sont connues ;
- les maquettes ou exemples existent ;
- le contrat API est defini ;
- le critere d'acceptation est testable.

## 5. Definition of Done par ticket

Un ticket est fini si :

- le code est merge ;
- les tests critiques passent ;
- la doc associee est mise a jour ;
- les etats erreur sont geres ;
- le monitoring minimal est branche ;
- la QA manuelle critique est faite.

## 6. Rituels d'equipe recommandes

- point de pilotage hebdo ;
- revue de dependances ;
- revue design/tech commune ;
- verification des blocages ;
- mise a jour du registre maitre.

## 7. Ordre de livraison conseille

### Sprint 1
- bootstrap repo ;
- auth de base ;
- environnements ;
- accueil squelette ;
- setup monitoring.

### Sprint 2
- check-in ;
- cravings ;
- Phoenix base ;
- API de base ;
- modele de donnees.

### Sprint 3
- SOS ;
- rituels ;
- notifications ;
- historiques ;
- QA renforcée.

### Sprint 4
- stabilisation ;
- release prep ;
- consentements ;
- publication interne ;
- checklist Play Store.

## 8. Fichiers a exiger reellement

- `openapi.yaml`
- `events/*.json`
- `.env.example`
- `docker-compose.yml`
- `README.setup.md`
- `README.release.md`
- `CHECKLIST_QA.md`
- `CHECKLIST_RELEASE.md`
- `ADR/`
- `SEEDS/`
- `SCRIPTS/bootstrap.*`

## 9. Risques si le pack n'existe pas

- interpretations divergentes ;
- dependance orale ;
- re-travail ;
- drift entre mobile, VPS et design ;
- ralentissement fort de l'equipe.
