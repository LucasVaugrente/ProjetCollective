import 'package:flutter/material.dart';

class PageSuccesQCM extends StatefulWidget {
  const PageSuccesQCM({super.key});

  @override
  State<PageSuccesQCM> createState() => _PageSuccesQCMState();
}

class _PageSuccesQCMState extends State<PageSuccesQCM> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Certification"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "Félicitations ! 🎉",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            const Text(
              "Vous avez obtenu 100% au QCM officiel.\nVeuillez renseigner vos informations pour générer votre certificat.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            _buildInput("Nom", nomController),
            _buildInput("Prénom", prenomController),
            _buildInput("Date de naissance (JJ/MM/AAAA)", dateController),
            _buildInput("Email", emailController),

            const SizedBox(height: 30),

            // --- BOUTON JAUNE IDENTIQUE AUX AUTRES ---
            GestureDetector(
              onTap: () {
                // TODO: action pour générer le certificat
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: const Center(
                  child: Text(
                    "Valider et générer le certificat",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
