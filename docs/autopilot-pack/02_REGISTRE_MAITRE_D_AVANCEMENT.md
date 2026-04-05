# 02 - Registre maitre d'avancement

## 1. Objet

Ce registre rend visible l'etat reel du projet. Il sert de cockpit unique pour savoir :

- ce qui est fige ;
- ce qui existe ;
- ce qui manque ;
- ce qui bloque ;
- ce qui vient ensuite.

## 2. Legende des statuts

- **Vert** - defini et developpable ;
- **Orange** - defini partiellement, execute avec encadrement ;
- **Rouge** - manque bloquant ;
- **Bleu** - archive ou branche a raccorder ;
- **Gris** - hors perimetre courant.

## 3. Tableau directeur

| Bloc | Statut | Sens |
|---|---|---|
| Canon produit Pulseo 1.2 | Vert | Source de verite |
| Backlog lots 0-32 | Vert | Base developpable |
| Runtime VPS raccorde au canon | Orange | Partiel |
| App Android Play Store | Rouge | A specifier |
| Design system | Rouge | A construire |
| Pack execution junior | Orange | A materaliser |
| Bibliotheque semantique sandboxee | Orange | A formaliser |
| Cartographie archives / branches | Rouge | A consolider |
| QA / release / publishing | Rouge | A verrouiller |

## 4. Lecture par familles

### 4.1 Produit coeur

#### Etat
Vert.

#### Deja present
- lots produit ;
- principes non negociables ;
- architecture logique ;
- plan 30 jours ;
- priorisation P0/P1/P2.

#### Reste a faire
- convertir le coeur en livrables mobiles et design concrets.

### 4.2 Mobile Android

#### Etat
Rouge.

#### Deja present
- objectif implicite d'une app visible simple ;
- logique de modules UX ;
- runtime serveur en arriere-plan.

#### Reste a faire
- perimetre MVP mobile ;
- ecrans ;
- etats ;
- versioning ;
- auth ;
- offline ;
- publication store.

### 4.3 VPS / runtime

#### Etat
Orange.

#### Deja present
- branche auto-hebergee ;
- logique API / orchestration / sandbox ;
- base infra.

#### Reste a faire
- raccord canonique avec Pulseo 1.2 ;
- environnement de prod/staging ;
- healthchecks ;
- CI/CD ;
- monitoring ;
- budgets de performance.

### 4.4 Design

#### Etat
Rouge.

#### Deja present
- intention de simplicite ;
- ton calme et rassurant ;
- profondeur moteur invisible.

#### Reste a faire
- design tokens ;
- composants ;
- systeme de navigation ;
- ecrans ;
- motion ;
- accessibilite.

### 4.5 Pack junior

#### Etat
Orange.

#### Deja present
- kit de transmission mentionne ;
- monorepo cible ;
- contrats API/evts evoques ;
- runbooks evoques.

#### Reste a faire
- fichiers reels ;
- examples ;
- scripts bootstrap ;
- DoR / DoD ;
- definition de test.

### 4.6 Bibliotheque sandboxee

#### Etat
Orange.

#### Deja present
- Obscura, Nexus, Prisme, Forge ;
- Lot 32 ;
- archives conceptuelles riches.

#### Reste a faire
- lot 33 ;
- modele d'objets ;
- statuts de maturite ;
- flux d'incubation ;
- gates de promotion.

## 5. Blocages majeurs

### 5.1 Blocage 1 - On ne voit pas assez la cible mobile
Sans spec mobile, impossible de planifier une release store.

### 5.2 Blocage 2 - Le design n'est pas executable
Sans design system, l'equipe improvise l'interface.

### 5.3 Blocage 3 - Le pack junior n'existe pas encore en artefacts reels
Sans bootstrap, contrats et checklists, la transmission reste trop orale.

### 5.4 Blocage 4 - Les branches historiques ne sont pas classees
Sans index clair, le risque de re-melange documentaire reste fort.

## 6. Priorites de travail immediates

1. Mobile Release Spec
2. Design System Canon
3. Pack Execution Junior
4. Lot 33 Bibliotheque Sandboxee
5. Cartographie archives / branches

## 7. Registre des livrables manquants

| Livrable | Criticite | Etat |
|---|---|---|
| Mobile Release Spec | Haute | Manquant |
| Design System Spec | Haute | Manquant |
| Screen Flows | Haute | Manquant |
| OpenAPI reel | Haute | A faire |
| Event schemas reels | Haute | A faire |
| Bootstrap repo | Haute | A faire |
| QA release checklist | Haute | A faire |
| Lot 33 detaille | Haute | A faire |
| Index archives / canon | Moyenne | A faire |

## 8. Regle de mise a jour

Ce registre doit etre mis a jour a chaque fois qu'un livrable passe de :

- manquant -> brouillon ;
- brouillon -> valide ;
- valide -> implemente ;
- implemente -> teste ;
- teste -> livre.
