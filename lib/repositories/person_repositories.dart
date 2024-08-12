import 'package:dio/dio.dart';
import 'package:personcad/models/person.dart';

class PersonRepositories {
  var _dio = Dio();

  PersonRepositories() {
    _dio.options.headers["X-Parse-Application-Id"] =
        "rDL1n3Jj5oph6s6enttyes9Z7im95GzZNtKvvhI9";
    _dio.options.headers["X-Parse-REST-API-Key"] =
        "o92oYnza4WSb9xBkKaaTHOLFbLmbWPiN7uT9Plqa";
    _dio.options.headers["content-type"] = "application/json";
    _dio.options.baseUrl = 'https://parseapi.back4app.com/classes';
  }

  Future<void> createPerson(Person person) async {
    final data = {
      "name": person.name ?? '',
      "cpf": person.cpf ?? '',
      "image": person.image ?? '',
    };
    final response = await _dio.post(
      '/person',
      data: data,
    );
  }

  Future<void> updatePerson(Person person) async {
    var url = '/person/${person.objectId}';
    var data = {
      'cpd': person.cpf,
      'image': person.image,
      'name': person.name,
    };
    var result = await _dio.put(url, data: data);
    if (result.statusCode != 200) {
      throw Exception('Erro ao atualizar o CEP: ${result.data}');
    }
  }

  Future<void> deletePerson(String objectId) async {
    var url = '/person/$objectId';
    var result = await _dio.delete(url);
    if (result.statusCode != 200) {
      throw Exception('Erro ao deletar o CEP: ${result.data}');
    }
  }

  Future<List<Person>> returnPerson() async {
    try {
      final response = await _dio.get('/person');
      final data = response.data['results'] as List;
      return data.map((json) => Person.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao obter a lista de CEPs: $e');
      return [];
    }
  }
}
