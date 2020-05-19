import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:peliculas/src/models/pelicula_model.dart';

class PeliculasProvider {
  String _apikey = '266c94c87f7265bfde3d274d210c5ae1';
  String _url = 'api.themoviedb.org';
  String _language = 'es-ES';

  int _popularesPage = 0;
  bool _cargando = false;

  List<Pelicula> _populares = new List();

  final _popularStreamController = StreamController<List<Pelicula>>.broadcast();

  Function(List<Pelicula>) get popularesSink =>
      _popularStreamController.sink.add;
  Stream<List<Pelicula>> get popularesStream => _popularStreamController.stream;

  void disposeStreams() {
    _popularStreamController?.close();
  }

  Future<List<Pelicula>> getEnCines() async {
    final url = Uri.https(_url, '3/movie/now_playing',
        {'api_key': _apikey, 'language': _language});
    return await _procesarRespuesta(url);
  }

  Future<List<Pelicula>> getPopulares() async {
    if (_cargando) {
      return []; // Caso contrario dispara muchas llamadas http
    }
    _cargando = true;
    _popularesPage++;
    final url = Uri.https(_url, '3/movie/popular', {
      'api_key': _apikey,
      'language': _language,
      'page': _popularesPage.toString(),
    });
    final resp = await _procesarRespuesta(url);
    _populares.addAll(resp);
    popularesSink(_populares);
    _cargando = false;
    return resp;
  }

  Future<List<Pelicula>> _procesarRespuesta(Uri url) async {
    final resp = await http.get(url);
    final decodedData = json.decode(resp.body);
    final peliculas = new Peliculas.fromJsonList(decodedData['results']);
    return peliculas.items;
  }
}
