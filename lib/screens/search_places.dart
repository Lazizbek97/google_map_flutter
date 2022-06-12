import 'package:flutter/material.dart';
import 'package:google_map_app/repository/suggestions_repository.dart';
import 'package:geocoding/geocoding.dart';

class AddressSearch extends SearchDelegate<Location?> {
  final sessionToken;
  PlaceApiProvider? apiClient;
  String queryType;

  AddressSearch(this.sessionToken, this.queryType) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      // We will put the api call here
      future: query == ""
          ? null
          : apiClient!.fetchSuggestions(
              query, Localizations.localeOf(context).languageCode, queryType),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: const EdgeInsets.all(16.0),
              child:
                  const Center(child: Text('Search restaurants or cafes...')),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    // we will display the data returned from our future here
                    title: Text(
                        (snapshot.data as List<Suggestion>)[index].description),
                    onTap: () async {
                      List<Location> locations = await locationFromAddress(
                          (snapshot.data as List<Suggestion>)[index]
                              .description);
                      var location = locations.first;
                      close(context, location);
                    },
                  ),
                  itemCount: (snapshot.data as List).length,
                )
              : const Center(
                  child: Text("No data found..."),
                ),
    );
  }
}
