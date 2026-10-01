import 'package:flutter_test/flutter_test.dart';
import 'package:mon_application/models/client.dart';
import 'package:mon_application/models/prestation.dart';
import 'package:mon_application/models/rendez_vous.dart';

void main() {
  const client = Client(
    id: 'c1',
    nom: 'Martin',
    prenom: 'Sophie',
    telephone: '0612345678',
    email: '',
  );
  const coupe = Prestation(
    id: 'p1',
    nom: 'Coupe',
    description: '',
    duree: Duration(minutes: 60),
    prix: 45,
  );

  RendezVous rdvA(DateTime d) => RendezVous(
        id: d.toIso8601String(),
        client: client,
        prestation: coupe,
        dateHeure: d,
      );

  test('nomComplet assemble prénom et nom', () {
    expect(client.nomComplet, 'Sophie Martin');
  });

  test('deux RDV qui se chevauchent sont détectés', () {
    final a = rdvA(DateTime(2026, 10, 5, 9, 0)); // 9h00 → 10h00
    final b = rdvA(DateTime(2026, 10, 5, 9, 30));
    expect(a.chevauche(b), isTrue);
  });

  test('des RDV qui se suivent ne se chevauchent pas', () {
    final a = rdvA(DateTime(2026, 10, 5, 9, 0)); // finit à 10h00
    final b = rdvA(DateTime(2026, 10, 5, 10, 0));
    expect(a.chevauche(b), isFalse);
  });

  test('toJson puis fromJson redonne le même RDV', () {
    final original = rdvA(DateTime(2026, 10, 5, 9, 0))
        .copyWith(statut: StatutRdv.confirme);
    final copie = RendezVous.fromJson(original.toJson());
    expect(copie.id, original.id);
    expect(copie.statut, StatutRdv.confirme);
    expect(copie.dateHeure, original.dateHeure);
    expect(copie.client.nomComplet, 'Sophie Martin');
  });
}