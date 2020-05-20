import 'package:flutter/material.dart';
import 'package:peliculas/src/models/pelicula_model.dart';
import 'package:peliculas/src/providers/peliculas_provider.dart';

class MovieSearch extends SearchDelegate {
  final peliculasProvider = new PeliculasProvider();
  String seleccion = '';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Container(
        height: 100.0,
        width: 100.0,
        color: Colors.blueAccent,
        child: Text(seleccion),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }
    return FutureBuilder(
      future: peliculasProvider.buscarPelicula(query),
      builder: (BuildContext context, AsyncSnapshot<List<Pelicula>> snapshot) {
        if (snapshot.hasData) {
          final peliculas = snapshot.data;
          print(peliculas);
          return ListView(
            children: peliculas.map(
              (e) => ListTile(
                leading: FadeInImage(
                  placeholder: AssetImage('assets/image-not-available.jpg'),
                  image: NetworkImage(e.getBackgroundImg()),
                  width: 50.0,
                  fit: BoxFit.contain,
                ),
                title: Text(e.title),
                subtitle: Text(e.originalTitle),
                onTap: () {
                  close(context, null);
                  e.uniqueId = '';
                  Navigator.pushNamed(context, 'detalle', arguments: e);
                },
              ),
            ).toList(),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
