// ⚙️ Réglages généraux de l'appli

/// Adresse où l'appli est en ligne (sans "/" à la fin).
/// À changer quand vous la mettez en ligne (Firebase Hosting, etc.).
const String urlApp = 'https://mon-coiffeur-3c71f.web.app';

/// Lien de réservation d'un salon : ouvre directement la page du salon.
String lienSalon(String salonId) => '$urlApp/?salon=$salonId';