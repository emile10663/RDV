# Mon Coiffeur

Application Flutter de gestion de rendez-vous pour un salon de coiffure / barbier.

## Fonctionnalités

- **Planning** : rendez-vous triés et regroupés par jour (Aujourd'hui, Demain…)
- **Nouveau rendez-vous** : client, prestation, date et heure, avec contrôle des créneaux passés et des chevauchements
- **Suivi** : marquer un rendez-vous comme terminé ou l'annuler (avec confirmation)
- **Statistiques** : chiffre d'affaires du jour et total, nombre de rendez-vous du jour
- **Sauvegarde locale** : les données restent sur l'appareil (`shared_preferences`)

## Captures d'écran

_À ajouter : planning, nouveau rendez-vous, statistiques._

## Lancer le projet

```bash
git clone https://github.com/emile10663/RDV.git
cd RDV/mon_application
flutter pub get
flutter run
```

Tests : `flutter test`

## Structure

```
lib/
├── data/       données de démonstration (prestations)
├── models/     Client, Prestation, RendezVous
├── screens/    planning, booking, stats, profile
├── services/   sauvegarde locale
├── theme/      couleurs et thème Material 3
└── widgets/    composants réutilisables (CardRdv…)
```

## Pistes d'amélioration

- Gestion des prestations depuis l'application
- Rappels / notifications
- Backend pour synchroniser plusieurs appareils