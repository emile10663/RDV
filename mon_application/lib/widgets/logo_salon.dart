import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// 💈 Le logo du salon (image enregistrée en texte base64 dans Firestore).
/// Sans logo, on affiche les ciseaux.
class LogoSalon extends StatefulWidget {
  final String? logo;
  final double taille;
  final bool rond;
  final Color? fond;
  final Gradient? degrade;
  final Color couleurIcone;
  final Color? bordure;
  final double largeurBordure;

  const LogoSalon({
    super.key,
    required this.logo,
    required this.taille,
    required this.couleurIcone,
    this.rond = true,
    this.fond,
    this.degrade,
    this.bordure,
    this.largeurBordure = 2,
  });

  @override
  State<LogoSalon> createState() => _LogoSalonState();
}

class _LogoSalonState extends State<LogoSalon> {
  Uint8List? _octets;

  @override
  void initState() {
    super.initState();
    _decoder();
  }

  @override
  void didUpdateWidget(LogoSalon ancien) {
    super.didUpdateWidget(ancien);
    if (ancien.logo != widget.logo) _decoder();
  }

  /// On décode une seule fois (pas à chaque affichage)
  void _decoder() {
    final texte = widget.logo;
    if (texte == null || texte.isEmpty) {
      _octets = null;
      return;
    }
    try {
      _octets = base64Decode(texte);
    } catch (_) {
      _octets = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.taille;
    final rayon = BorderRadius.circular(widget.rond ? t / 2 : t * 0.3);

    final icone = Center(
      child: Icon(Icons.content_cut, size: t * 0.42, color: widget.couleurIcone),
    );

    final contenu = _octets == null
        ? icone
        : ClipRRect(
            borderRadius: rayon,
            child: Image.memory(
              _octets!,
              width: t,
              height: t,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => icone,
            ),
          );

    return Container(
      width: t,
      height: t,
      decoration: BoxDecoration(
        color: widget.degrade == null ? widget.fond : null,
        gradient: widget.degrade,
        borderRadius: rayon,
        border: widget.bordure == null
            ? null
            : Border.all(color: widget.bordure!, width: widget.largeurBordure),
      ),
      child: contenu,
    );
  }
}