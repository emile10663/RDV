import '../models/client.dart';
import '../models/prestation.dart';
import '../models/rendez_vous.dart';

/// 🧪 Données fictives pour tester l'interface
/// ⚠️ TEMPORAIRE — sera remplacé par une vraie source de données plus tard
final List<Prestation> mockPrestations = [
  const Prestation(
    id: 'p1', nom: 'Coupe + Brushing',
    description: 'Coupe tendance + coiffage',
    duree: Duration(minutes: 60), prix: 45.0,
  ),
  const Prestation(
    id: 'p2', nom: 'Taille de barbe',
    description: 'Rasage traditionnel serviette chaude',
    duree: Duration(minutes: 30), prix: 25.0,
  ),
  const Prestation(
    id: 'p3', nom: 'Coupe enfant',
    description: 'Jusqu\'à 12 ans',
    duree: Duration(minutes: 45), prix: 30.0,
  ),
];

final List<RendezVous> mockRdvs = [
  RendezVous(
    id: 'r1',
    client: const Client(
      id: 'c1', nom: 'Martin', prenom: 'Sophie',
      telephone: '0612345678', email: 'sophie@mail.fr',
    ),
    prestation: mockPrestations[0],
    dateHeure: DateTime(2026, 9, 16, 9, 30),
    statut: StatutRdv.confirme,
  ),
  RendezVous(
    id: 'r2',
    client: const Client(
      id: 'c2', nom: 'Diallo', prenom: 'Amadou',
      telephone: '0698765432', email: 'amadou@mail.fr',
    ),
    prestation: mockPrestations[1],
    dateHeure: DateTime(2026, 9, 16, 10, 30),
    statut: StatutRdv.confirme,
  ),
  RendezVous(
    id: 'r3',
    client: const Client(
      id: 'c3', nom: 'Bernard', prenom: 'Lucas',
      telephone: '0655443322', email: 'lucas@mail.fr',
    ),
    prestation: mockPrestations[2],
    dateHeure: DateTime(2026, 9, 16, 11, 30),
  ),
];