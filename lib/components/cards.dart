import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personcad/models/person.dart';
import 'package:personcad/repositories/person_repositories.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart';

class CardInfo extends StatefulWidget {
  CardInfo({
    super.key,
    required this.personInfo,
    required this.onUpdate,
    required this.onDelete,
  });

  final Person personInfo;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  @override
  State<CardInfo> createState() => _CardInfoState();
}

class _CardInfoState extends State<CardInfo> {
  late TextEditingController cpfController;
  late TextEditingController nameController;
  late TextEditingController imageController;
  XFile? photo; // Mover a variável para o escopo de classe

  @override
  void initState() {
    super.initState();
    cpfController = TextEditingController(text: widget.personInfo.cpf);
    nameController = TextEditingController(text: widget.personInfo.name);
    imageController = TextEditingController(text: widget.personInfo.image);
  }

  @override
  void dispose() {
    cpfController.dispose();
    nameController.dispose();
    imageController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: CircleAvatar(
        backgroundImage: imageController.text.isNotEmpty
            ? FileImage(File(imageController.text))
            : null,
        child: imageController.text.isEmpty
            ? Text(widget.personInfo.name?.substring(0, 2).toUpperCase() ?? '')
            : null,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Editar cadastro"),
                    content: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              keyboardType: TextInputType.text,
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
                                  await photo!.saveTo('$path/$name');
                                  imageController.text = '$path/$name';
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
                            Person editPerson = Person(
                              cpf: cpfController.text,
                              name: nameController.text,
                              image: imageController.text,
                              objectId: widget.personInfo.objectId,
                            );
                            await editItem(editPerson);
                            widget.onUpdate();
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Atualizar'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const FaIcon(FontAwesomeIcons.userPen),
          ),
          IconButton(
            onPressed: () async {
              await deleteItem(widget.personInfo.objectId ?? '');
              widget.onDelete();
            },
            icon: const FaIcon(FontAwesomeIcons.trashCan),
          ),
        ],
      ),
      title: Text(widget.personInfo.name ?? ''),
      subtitle: Text(widget.personInfo.cpf ?? ''),
    );
  }
}

Future<void> deleteItem(String personId) async {
  PersonRepositories repository = PersonRepositories();
  await repository.deletePerson(personId);
}

Future<void> editItem(Person person) async {
  PersonRepositories repository = PersonRepositories();
  await repository.updatePerson(person);
}
