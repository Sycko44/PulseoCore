# 03 - Specification Mobile Release reliée au VPS

## 1. Objet

Ce document decrit la premiere release Android de Pulseo, destinee a etre publiee sur le Play Store et connectee a un VPS pour son fonctionnement applicatif.

## 2. Objectif produit

Livrer une application Android stable, simple et rassurante, qui expose le coeur visible de Pulseo tout en deleguant la logique profonde au backend heberge sur le VPS.

## 3. Perimetre MVP mobile

### 3.1 Inclus dans la premiere release

- onboarding ;
- creation de compte / connexion ;
- consentements ;
- accueil ;
- check-in rapide ;
- suivi cravings ;
- bouton SOS ;
- rituels ;
- tableau Phoenix ;
- historique personnel minimal ;
- parametres ;
- notifications utiles.

### 3.2 Exclus de la premiere release

- studio creatif complet ;
- marketplace ;
- bundles complexes ;
- B2B ;
- creation avancee de jeux ;
- simulation lourde visible utilisateur ;
- moderation avancée cote mobile.

## 4. Repartition mobile / VPS / admin

### 4.1 Mobile

Le mobile gere :
- l'interface ;
- la session utilisateur ;
- le cache local ;
- l'affichage des contenus ;
- les soumissions de check-ins et d'actions ;
- le mode degrade offline.

### 4.2 VPS

Le VPS gere :
- l'API ;
- l'auth ;
- la logique d'etat ;
- la memoire ;
- les regles ;
- les recommandations ;
- la revue ;
- la sandbox ;
- les journaux ;
- la persistance ;
- les notifications serveur.

### 4.3 Admin / Studio

Le web admin gere :
- edition de contenus ;
- review ;
- publication ;
- suivi ;
- analytics ;
- administration des policies.

## 5. Exigences de connexion au VPS

### 5.1 API

- HTTPS obligatoire ;
- version d'API explicite ;
- timeouts definis ;
- codes d'erreur stabilises ;
- payloads versionnes.

### 5.2 Authentification

- login email ou equivalent ;
- refresh token securise ;
- reauth si expiration critique ;
- deconnexion distante possible.

### 5.3 Resilience reseau

- cache local pour dernier etat utile ;
- reprise sur reconnexion ;
- messages d'etat reseau ;
- file de synchronisation pour actions compatibles ;
- politique claire pour les actions non syncables offline.

### 5.4 Environnements

- `dev` ;
- `staging` ;
- `prod`.

Le client doit pouvoir pointer proprement vers chaque environnement.

## 6. Parcours clés

### 6.1 Onboarding

- ecran de bienvenue ;
- promesse claire ;
- creation de compte ;
- consentements ;
- premier check-in ;
- arrivee sur l'accueil.

### 6.2 Check-in

- acces en un geste depuis l'accueil ;
- humeur / energie / cravings / sommeil ;
- validation ;
- retour visuel ;
- mise a jour du tableau Phoenix.

### 6.3 SOS

- acces toujours visible ;
- action immediate ;
- protocole court ;
- sortie claire ;
- log cote serveur.

### 6.4 Rituels

- suggestions ;
- details ;
- lancement ;
- complet / abandon ;
- feedback.

## 7. Ecrans requis

- splash ;
- bienvenue ;
- connexion ;
- creation compte ;
- consentements ;
- accueil ;
- check-in ;
- cravings ;
- SOS ;
- rituels ;
- Phoenix ;
- historique ;
- profil ;
- parametres ;
- etat offline / erreur.

## 8. Etats a specifier pour chaque ecran

- vide ;
- chargement ;
- succes ;
- erreur ;
- offline ;
- acces refuse ;
- contenu en attente ;
- version obsolete.

## 9. Critères non fonctionnels

- demarrage ressenti rapide ;
- navigation fluide ;
- crash rate tres faible ;
- taille d'app maitrisée ;
- textes lisibles ;
- gestes clairs ;
- compatibilite Android ciblee explicitement ;
- journaux de crash et monitoring relies au VPS/outillage.

## 10. Publication Play Store

### 10.1 A fournir

- icone ;
- screenshots ;
- politique de confidentialite ;
- descriptif store ;
- classification ;
- package name stable ;
- signature release ;
- version code / version name.

### 10.2 Conditions avant soumission

- MVP complet ;
- auth stable ;
- consentements visibles ;
- messages d'erreur corrects ;
- monitoring branche ;
- QA release passee ;
- backend prod pret.

## 11. Definition of Done de la Mobile Release

La release est consideree prete quand :

- tous les ecrans MVP existent ;
- les parcours critiques sont testes ;
- le mobile parle correctement au VPS prod ;
- le mode degrade est defini ;
- les consentements sont integres ;
- la publication Play Store est techniquement possible.
