import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personcad/components/Cards.dart';
import 'package:personcad/models/person.dart';
import 'package:personcad/repositories/person_repositories.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

PersonRepositories repositories = PersonRepositories();
List<Person> personInfoList = [];

class _HomePageState extends State<HomePage> {
  PersonRepositories personRepositories = PersonRepositories();

  TextEditingController cpfController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController imageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  XFile? photo; // Mover a variável para o escopo de classe

  @override
  void initState() {
    obterListaperson();
    super.initState();
  }

  Future<void> obterListaperson() async {
    try {
      var person = await personRepositories.returnPerson();
      setState(() {
        personInfoList = person;
      });
    } catch (e) {
      print('Erro ao obter a lista de person: $e');
    }
  }

  Future<void> UpdateList() async {
    await obterListaperson();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: personInfoList.length,
                itemBuilder: (context, index) {
                  final person = personInfoList[index];
                  return CardInfo(
                    personInfo: person,
                    onUpdate: UpdateList,
                    onDelete: UpdateList,
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text("Criar Pessoa"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Ajuste para o Form
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.text, // Ajuste no tipo de entrada
                        controller: nameController,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          hintText: "Nome",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o seu nome';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: cpfController,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          hintText: "CPF",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu CPF';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        onPressed: () async {
                          final ImagePicker _picker = ImagePicker();
                          photo = await _picker.pickImage(
                              source: ImageSource.gallery);
                          if (photo != null) {
                            String path = (await path_provider
                                    .getApplicationDocumentsDirectory())
                                .path;
                            String name = basename(photo!.path);
                            await photo!.saveTo('$path/$name'); // Aguarde a operação de salvamento
                            setState(() {});
                          }
                        },
                        icon: const FaIcon(FontAwesomeIcons.images),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Voltar'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      if (photo != null) {
                        Person person = Person(
                            cpf: cpfController.text,
                            image: photo!.path,
                            name: nameController.text);
                        await repositories.createPerson(person);
                        await UpdateList();
                        Navigator.pop(context);
                        cpfController.clear();
                        nameController.clear();
                        photo = null;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, selecione uma imagem.'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Criar'),
                ),
              ],
            ),
          );
        },
        tooltip: 'Adicionar',
        child: const FaIcon(FontAwesomeIcons.userPlus),
      ),
    );
  }
}
