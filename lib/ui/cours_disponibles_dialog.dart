import 'package:flutter/material.dart';
import 'api_service.dart';

class CoursDisponiblesDialog extends StatefulWidget {
  const CoursDisponiblesDialog({super.key});

  @override
  State<CoursDisponiblesDialog> createState() => _CoursDisponiblesDialogState();
}

class _CoursDisponiblesDialogState extends State<CoursDisponiblesDialog> {
  final ApiService _apiService = ApiService();
  List<CoursDistant>? _coursDisponibles;
  bool _isLoading = false;
  String? _errorMessage;
  Set<int> _coursEnCoursDeTelechargement = {};

  @override
  void initState() {
    super.initState();
    _chargerCoursDisponibles();
  }

  Future<void> _chargerCoursDisponibles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cours = await _apiService.getCoursDisponibles();
      setState(() {
        _coursDisponibles = cours;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _telechargerCours(CoursDistant cours) async {
    setState(() {
      _coursEnCoursDeTelechargement.add(cours.id);
    });

    try {
      // Récupérer le cours complet avec ses pages
      final coursComplet = await _apiService.getCoursComplet(cours.id);

      // TODO: Sauvegarder le cours dans la base de données locale
      // Vous devrez implémenter cette partie selon votre architecture

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cours "${cours.titre}" téléchargé avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _coursEnCoursDeTelechargement.remove(cours.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cours disponibles',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _isLoading ? null : _chargerCoursDisponibles,
                      tooltip: 'Rafraîchir',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des cours...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de connexion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _chargerCoursDisponibles,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_coursDisponibles == null || _coursDisponibles!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun cours disponible',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _coursDisponibles!.length,
      itemBuilder: (context, index) {
        final cours = _coursDisponibles![index];
        final estEnCoursDeTelechargement = _coursEnCoursDeTelechargement.contains(cours.id);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 236, 187, 139),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.school,
                color: Colors.white,
                size: 30,
              ),
            ),
            title: Text(
              cours.titre,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: cours.description.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                cours.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            )
                : null,
            trailing: estEnCoursDeTelechargement
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : IconButton(
              icon: const Icon(Icons.download),
              color: Colors.green,
              onPressed: () => _telechargerCours(cours),
              tooltip: 'Télécharger',
            ),
          ),
        );
      },
    );
  }
}