import 'package:flutter/material.dart';

class PageSuccesQCM extends StatefulWidget {
  const PageSuccesQCM({super.key});

  @override
  State<PageSuccesQCM> createState() => _PageSuccesQCMState();
}

class _PageSuccesQCMState extends State<PageSuccesQCM> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomCtrl = TextEditingController();
  final TextEditingController prenomCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Certification"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Félicitations ! 🎉\nVous avez obtenu 100% au QCM officiel.\n"
                    "Veuillez renseigner vos informations pour générer votre certificat.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),

              SizedBox(height: 30),

              TextFormField(
                controller: nomCtrl,
                decoration: const InputDecoration(
                  labelText: "Nom",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Veuillez entrer votre nom" : null,
              ),

              SizedBox(height: 20),

              TextFormField(
                controller: prenomCtrl,
                decoration: const InputDecoration(
                  labelText: "Prénom",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? "Veuillez entrer votre prénom"
                    : null,
              ),

              SizedBox(height: 20),

              TextFormField(
                controller: dateCtrl,
                decoration: const InputDecoration(
                  labelText: "Date de naissance (JJ/MM/AAAA)",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? "Veuillez entrer votre date de naissance"
                    : null,
              ),

              SizedBox(height: 20),

              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Veuillez entrer un email";
                  }
                  if (!v.contains("@")) {
                    return "Email invalide";
                  }
                  return null;
                },
              ),

              SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Ici tu feras la génération du certificat plus tard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Informations validées !"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  "Valider et générer le certificat",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
